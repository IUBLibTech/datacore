# frozen_string_literal: true

# Converts UploadedFiles into FileSets and attaches them to works.
class AttachFilesToWorkJob < ::Hyrax::ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as Hyrax.config.ingest_queue_name

  ATTACH_FILES_TO_WORK_JOB_IS_VERBOSE = true
  ATTACH_FILES_TO_WORK_UPLOAD_FILES_ASYNCHRONOUSLY = false

  # @param [ActiveFedora::Base] work - the work object
  # @param [Array<Hyrax::UploadedFile>] uploaded_files - an array of files to attach
  def perform( work, uploaded_files, user_key, **work_attributes )
    @processed = []
    Deepblue::LoggingHelper.bold_debug [ Deepblue::LoggingHelper.here,
                                         Deepblue::LoggingHelper.called_from,
                                         "work=#{work}",
                                         "user_key=#{user_key}",
                                         "uploaded_files=#{uploaded_files}",
                                         "uploaded_files.count=#{uploaded_files.count}",
                                         "work_attributes=#{work_attributes}" ] if ATTACH_FILES_TO_WORK_JOB_IS_VERBOSE
    depositor = proxy_or_depositor( work )
    # user = User.find_by_user_key( depositor ) # Wrong!, it's actually on the upload file record.
    user = User.find_by_user_key( user_key )
    uploaded_file_ids = uploaded_files.map { |u| u.id }
    Deepblue::UploadHelper.log( class_name: self.class.name,
                                event: "attach_files_to_work",
                                event_note: "starting",
                                id: work.id,
                                uploaded_file_ids: uploaded_file_ids,
                                uploaded_file_ids_count: uploaded_file_ids.size,
                                user: user.to_s,
                                work_id: work.id,
                                work_file_set_count: work.file_set_ids.count,
                                asynchronous: ATTACH_FILES_TO_WORK_UPLOAD_FILES_ASYNCHRONOUSLY)
    validate_files!(uploaded_files)
    work_permissions = work.permissions.map( &:to_hash )
    bypass_fedora = work_attributes.delete(:bypass_fedora)
    metadata = visibility_attributes( work_attributes )
    uploaded_files.each do |uploaded_file|
      upload_file( work, uploaded_file, user, work_permissions, metadata, uploaded_file_ids: uploaded_file_ids, bypass_fedora: bypass_fedora )
    end
    failed = uploaded_files - @processed
    if failed.empty?
      Deepblue::UploadHelper.log( class_name: self.class.name,
                                  event: "attach_files_to_work",
                                  event_note: "finished",
                                  id: work.id,
                                  uploaded_file_ids: uploaded_file_ids,
                                  uploaded_file_ids_count: uploaded_file_ids.size,
                                  user: user.to_s,
                                  work_id: work.id,
                                  work_file_set_count: work.file_set_ids.count,
                                  asynchronous: ATTACH_FILES_TO_WORK_UPLOAD_FILES_ASYNCHRONOUSLY)
    else
      Rails.logger.error "FAILED to process all uploaded files at #{caller_locations(1, 1)[0]}, count of unprocessed files = #{failed.count}"
      Deepblue::UploadHelper.log( class_name: self.class.name,
                                  event: "attach_files_to_work",
                                  event_note: "finished_with_failed_files",
                                  id: work.id,
                                  uploaded_file_ids: uploaded_file_ids,
                                  uploaded_file_ids_count: uploaded_file_ids.size,
                                  user: user.to_s,
                                  work_id: work.id,
                                  work_file_set_count: work.file_set_ids.count,
                                  failed: failed,
                                  asynchronous: ATTACH_FILES_TO_WORK_UPLOAD_FILES_ASYNCHRONOUSLY )
    end
    notify_attach_files_to_work_job_complete( failed_to_upload: failed, uploaded_files: uploaded_files, user: user, work: work )
  rescue Exception => e # rubocop:disable Lint/RescueException
    Rails.logger.error "#{e.class} work_id=#{work.id} -- #{e.message} at #{e.backtrace[0]}"
    Deepblue::UploadHelper.log( class_name: self.class.name,
                                event: "attach_files_to_work",
                                event_note: "failed",
                                id: work.id,
                                user: user.to_s,
                                work_id: work.id,
                                exception: e.to_s,
                                backtrace0: e.backtrace[0],
                                asynchronous: ATTACH_FILES_TO_WORK_UPLOAD_FILES_ASYNCHRONOUSLY )
    raise
  end

  private

    def attach_files_to_work_job_complete_email_user( email: nil, lines: [], subject:, work: )
      return if email.blank?
      return if lines.blank?
      # Deepblue::LoggingHelper.debug "attach_files_to_work_job_complete_email_user: work id: #{work.id} email: #{email}"
      body = lines.join( "\n" )
      to = email
      from = email
      Deepblue::EmailHelper.log( class_name: self.class.name,
                                 current_user: nil,
                                 event: Deepblue::AbstractEventBehavior::EVENT_UPLOAD,
                                 event_note: 'files attached to work',
                                 id: work.id,
                                 to: to,
                                 from: from,
                                 subject: subject,
                                 body: lines )
      Deepblue::EmailHelper.send_email( to: to, from: from, subject: subject, body: body )
    end

    def data_set_url( work )
      Deepblue::EmailHelper.data_set_url( data_set: work )
    rescue Exception => e # rubocop:disable Lint/RescueException
      Rails.logger.error "#{e.class} #{e.message} at #{e.backtrace[0]}"
      return e.to_s
    end

    def file_stats( uploaded_file )
      begin
        if uploaded_file.file_set_uri
          file_set_id = ActiveFedora::Base.uri_to_id uploaded_file.file_set_uri
          file_set = FileSet.find(file_set_id)
          file_name = file_set.original_name_value
          file_size = file_set.file_size_value
        else
          file_path = uploaded_file.uploader.path
          file_name = "#{Pathname.new(file_path).basename} (large file still processing)"
          file_size = File.exist?(file_path) ? File.size(file_path) : '(size TBD)'
        end
        return file_name, file_size
      rescue Exception => e # rubocop:disable Lint/RescueException
        Rails.logger.error "#{e.class} #{e.message} at #{e.backtrace[0]}"
        return e.to_s, ''
      end
    end
  
    def notify_attach_files_to_work_job_complete( failed_to_upload:, uploaded_files:, user:, work: )
      notify_user = DeepBlueDocs::Application.config.notify_user_file_upload_and_ingest_are_complete
      notify_managers = DeepBlueDocs::Application.config.notify_managers_file_upload_and_ingest_are_complete
      return unless notify_user || notify_managers
      title = work.title.first
      lines = []
      file_count = @processed.size
      file_count_phrase = if 1 == file_count
                            Deepblue::EmailHelper.t( "hyrax.email.notify_attach_files_to_work_job_complete.one_file_count_phrase" )
                          else
                            Deepblue::EmailHelper.t( "hyrax.email.notify_attach_files_to_work_job_complete.many_files_count_phrase",
                                                     file_count: file_count )
                          end
      work_url = data_set_url( work )
      lines << Deepblue::EmailHelper.t( "hyrax.email.notify_attach_files_to_work_job_complete.finished",
                                        file_count_phrase: file_count_phrase,
                                        title: title,
                                        work_url: work_url )

      unless failed_to_upload.empty?
        lines << Deepblue::EmailHelper.t( "hyrax.email.notify_attach_files_to_work_job_complete.total_failed",
                                          file_count: failed_to_upload.size )
        lines << Deepblue::EmailHelper.t( "hyrax.email.notify_attach_files_to_work_job_complete.files_failed" )
        count = 0
        failed_to_upload.each do |uploaded_file|
          count += 1
          file_name, file_size = file_stats( uploaded_file )
          lines << Deepblue::EmailHelper.t( "hyrax.email.notify_attach_files_to_work_job_complete.file_line",
                                            line_count: count,
                                            file_name: file_name,
                                            file_size: file_size )
        end

      end
      file_list = []
      @processed.each do |uploaded_file|
        file_name, file_size = file_stats( uploaded_file )
        file_list << Deepblue::EmailHelper.t( "hyrax.email.notify_attach_files_to_work_job_complete.file_list_item",
                                              file_name: file_name,
                                              file_size: file_size )
      end
      file_list.sort!
      count = 0
      file_list.each do |file_item|
        count += 1
        lines << Deepblue::EmailHelper.t( "hyrax.email.notify_attach_files_to_work_job_complete.file_list_line",
                                          line_count: count,
                                          file_item: file_item )
      end
      subject = Deepblue::EmailHelper.t( "hyrax.email.notify_attach_files_to_work_job_complete.subject", title: title )
      attach_files_to_work_job_complete_email_user( email: user.email, lines: lines, subject: subject, work: work ) if notify_user
      attach_files_to_work_job_complete_email_user( email: Deepblue::EmailHelper.notification_email,
                                                    lines: lines,
                                                    subject: subject + " (RDS)",
                                                    work: work ) if notify_managers
    rescue Exception => e # rubocop:disable Lint/RescueException
      Rails.logger.error "#{e.class} #{e.message} at #{e.backtrace[0]}"
      Deepblue::LoggingHelper.bold_debug [ Deepblue::LoggingHelper.here,
                                           Deepblue::LoggingHelper.called_from ] + e.backtrace
    end

    ##
    # A work with files attached by a proxy user will set the depositor as the intended user
    # that the proxy was depositing on behalf of. See tickets #2764, #2902.
    def proxy_or_depositor(work)
      work.on_behalf_of.blank? ? work.depositor : work.on_behalf_of
    end

    def upload_file( work, uploaded_file, user, work_permissions, metadata, uploaded_file_ids: [], bypass_fedora: false)
      Deepblue::LoggingHelper.bold_debug [ Deepblue::LoggingHelper.here,
                                           Deepblue::LoggingHelper.called_from,
                                           "work.id=#{work.id}",
                                           "uploaded_file.file=#{uploaded_file.file.path}",
                                           "uploaded_file.file_set_uri=#{uploaded_file.file_set_uri}",
                                           # Deepblue::LoggingHelper.obj_methods( "uploaded_file", uploaded_file ),
                                           # Deepblue::LoggingHelper.obj_instance_variables( "uploaded_file", uploaded_file ),
                                           Deepblue::LoggingHelper.obj_attribute_names( "uploaded_file", uploaded_file ),
                                           Deepblue::LoggingHelper.obj_to_json( "uploaded_file", uploaded_file ),
                                           "uploaded_file.id=#{Deepblue::UploadHelper.uploaded_file_id( uploaded_file )}",
                                           "user=#{user}",
                                           "work_permissions=#{work_permissions}",
                                           "metadata=#{metadata}",
                                           "uploaded_file_ids=#{uploaded_file_ids}",
                                           "" ] if ATTACH_FILES_TO_WORK_JOB_IS_VERBOSE
      Deepblue::UploadHelper.log( class_name: self.class.name,
                                  event: "upload_file",
                                  id: "NA",
                                  path: Deepblue::UploadHelper.uploaded_file_path( uploaded_file ),
                                  size: Deepblue::UploadHelper.uploaded_file_size( uploaded_file ),
                                  uploaded_file_id: Deepblue::UploadHelper.uploaded_file_id( uploaded_file ),
                                  user: user.to_s,
                                  work_id: work.id,
                                  work_file_set_count: work.file_set_ids.count,
                                  asynchronous: ATTACH_FILES_TO_WORK_UPLOAD_FILES_ASYNCHRONOUSLY)
      case file_size_category(uploaded_file)
      when :standard
        copy_to_outbox!(uploaded_file, work) # for SDA archiving, as in final step of dropbox ingest
        actor = Hyrax::Actors::FileSetActor.new( FileSet.create, user )
        actor.file_set.permissions_attributes = work_permissions
        actor.create_metadata( metadata )
        # when actor.create content is here, and the processing is synchronous, then it fails to add size to the file_set
        # actor.create_content( uploaded_file, continue_job_chain_later: ATTACH_FILES_TO_WORK_UPLOAD_FILES_ASYNCHRONOUSLY )
        actor.attach_to_work( work, uploaded_file_id: Deepblue::UploadHelper.uploaded_file_id( uploaded_file ) )
        uploaded_file.update( file_set_uri: actor.file_set.uri )
        actor.create_content( uploaded_file,
                             continue_job_chain_later: ATTACH_FILES_TO_WORK_UPLOAD_FILES_ASYNCHRONOUSLY,
                             uploaded_file_ids: uploaded_file_ids,
                             bypass_fedora: bypass_fedora)
      when :large
        move_to_inbox!(uploaded_file, work) # for large workflow dropbox ingest, FileSet creation bypassing Fedora storage
      when :excessive
        move_to_inbox!(uploaded_file, work) # @todo handle very-large case
      when :error
        raise StandardError, 'Error sizing uploaded file'
      end
      @processed << uploaded_file
    rescue Exception => e # rubocop:disable Lint/RescueException
      Rails.logger.error "#{e.class} work.id=#{work.id} -- #{e.message} at #{e.backtrace[0]}"
      file_size = File.size( uploaded_file.file.path ) rescue -1 # in case the file has already disappeared
      Deepblue::UploadHelper.log( class_name: self.class.name,
                                  event: "upload_file",
                                  event_note: "failed",
                                  id: work.id,
                                  path: uploaded_file.file.path,
                                  size: file_size,
                                  user: user,
                                  work_id: work.id,
                                  exception: e.to_s,
                                  backtrace0: e.backtrace[0],
                                  asynchronous: ATTACH_FILES_TO_WORK_UPLOAD_FILES_ASYNCHRONOUSLY )
    end

    # The attributes used for visibility - sent as initial params to created FileSets.
    def visibility_attributes(attributes)
      attributes.slice(:visibility, :visibility_during_lease,
                       :visibility_after_lease, :lease_expiration_date,
                       :embargo_release_date, :visibility_during_embargo,
                       :visibility_after_embargo)
    end

    def validate_files!(uploaded_files)
      uploaded_files.each do |uploaded_file|
        next if uploaded_file.is_a? Hyrax::UploadedFile
        msg = "Hyrax::UploadedFile required, but #{uploaded_file.class} received: #{uploaded_file.inspect}"
        Rails.logger.error msg
        raise ArgumentError, msg
      end
    end

    def file_size_category(uploaded_file)
      size = begin 
               Rails.application.load_tasks unless defined?(Datacore::IngestFilesFromDirectoryTask)
               File.size(uploaded_file.uploader.path)
             rescue => e
               Rails.logger.error("Error reading file size from #{uploaded_file.inspect} at #{uploaded_file.uploader.path}: #{e.inspect}")
               -1
             end
      if size < 0
        :error
      elsif size <= Datacore::IngestFilesFromDirectoryTask::FEDORA_SIZE_LIMIT
        :standard
      elsif size <= Datacore::IngestFilesFromDirectoryTask::INGEST_SIZE_LIMIT
        :large
      else
        :excessive
      end
    end

    def copy_to_outbox!(uploaded_file, work)
      dropbox_action!(uploaded_file, work, Settings.ingest.outbox, :cp)
    end

    def move_to_inbox!(uploaded_file, work)
      dropbox_action!(uploaded_file, work, Settings.ingest.large_inbox, :mv)
    end

    def dropbox_action!(uploaded_file, work, destination_dir, action)
      origin_path = uploaded_file.uploader.path 
      origin_file = Pathname.new(origin_path).basename
      destination_file = "#{work.id}_#{origin_file}"
      destination_path = Pathname.new(destination_dir).join(destination_file)
      FileUtils.send(action, origin_path, destination_path)
    end
end
