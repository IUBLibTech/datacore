# frozen_string_literal: true
require 'fileutils'

namespace :datacore do

  desc "Ingest dataset files from directory for previously created datasets."
  task ingest_directory: :environment do
    Datacore::IngestFilesFromDirectoryTask.new.run
  end

end

module Datacore

  class IngestFilesFromDirectoryTask
    include ActionView::Helpers::NumberHelper

    USER_KEY = Settings.ingest.user_key
    STANDARD_INGEST_DIR = Settings.ingest.standard_inbox
    LARGE_INGEST_DIR = Settings.ingest.large_inbox
    INGEST_OUTBOX = Settings.ingest.outbox
    FEDORA_SIZE_LIMIT = Settings.ingest.size_limit.fedora || (5 * (2**30)) # 5 GB
    INGEST_SIZE_LIMIT = Settings.ingest.size_limit.ingest || (100 * (2**30)) # 100 GB
    LOG_PATH  = Rails.root.join('log', 'ingest.log')
    EMPTY_FILEPATH = 'lib/tasks/empty.txt' # TODO: refactor EMPTY_FILEPATH

    def self.logger
      @@logger ||= Logger.new(LOG_PATH)
    end

    def logger
      self.class.logger
    end

    def run
      if Settings.archive_api.disabled
        logger.info("Skipping ingest job processing, archive API is disabled")
        return
      end
      logger.info("Starting ingest.")
      user = User.find_by_user_key(USER_KEY)
      if user
        logger.info("Ingest user found for #{USER_KEY}")
      else user
        logger.error("No user found for #{USER_KEY}.  Aborting ingest.")
        return
      end
      ingest_directory(STANDARD_INGEST_DIR, user, bypass_fedora: false)
      ingest_directory(LARGE_INGEST_DIR, user, bypass_fedora: true)
    end

    def ingest_directory(directory, user, bypass_fedora: false)
      logger.info("Starting ingest from #{directory} for user #{user} with bypass_fedora: #{bypass_fedora.to_s}")
      @directory_files = directory_files(directory)
      if @directory_files.any?
        logger.info("#{@directory_files.size} files found.")
        @directory_files.each_with_index do |filepath, index|
          logger.info("Starting file ingest #{index+1}/#{@directory_files.size} for #{filepath} for user #{user} with bypass_fedora: #{bypass_fedora.to_s}")
          ingest_file(filepath, user, bypass_fedora: bypass_fedora)
          logger.info("Finished file ingest #{index+1}/#{@directory_files.size} for #{filepath}")
        end
      else
        logger.info("No files found.")
      end
      logger.info("Finished ingest from #{directory}")
    end

    def directory_files(directory)
      (Dir.entries(directory) - [".", ".."] - ['large', 'small']).map do |filename|
        File.join(directory, filename)
      end.reject do |filepath|
        File.directory?(filepath)
      end
    end

    def ingest_file(filepath, user, bypass_fedora: false)
      # if the file is not currently open by another process
      pids = `lsof -t '#{filepath}'`
      if pids.present?
        logger.error("Skipping file that is in use: #{filepath}")
        return
      end
      # Look for files with names matching the pattern "<workid>_<filename>"
      #   (a work_id is a string of 9 alphanumberic characters)
      filename = filepath.split('/').last
      if filename != URI.encode(filename)
        logger.error("Filename \"#{filename}\" requires URL encoding (to \"#{URI.encode(filename)}\"), skipping ingest.")
        return
      elsif filename.match(/^(?<work_id>([a-z]|\d){9})_(?<filenamepart>.*)$/)
        filename.match(/^(?<work_id>([a-z]|\d){9})_(?<filenamepart>.*)$/) do |m|
          work_id = m[:work_id]
          filenamepart = m[:filenamepart]
          size = File.size(filepath)
          human_size = number_to_human_size(size)
          logger.info("Attempting ingest of file #{filenamepart} as #{work_id} (#{human_size})")
          if size > INGEST_SIZE_LIMIT
            logger.error("File size (#{human_size}) exceeds maximum ingest limit.  Skipping.")
            return
          elsif bypass_fedora
            logger.info("File ingest called bypassing fedora storage")
          elsif size > FEDORA_SIZE_LIMIT
            logger.info("File ingest called for fedora storage, but triggering bypass due to excessive file size: #{number_to_human_size(size)}")
            bypass_fedora = true
          end
          begin
            w = DataSet.find(work_id)
            logger.info("Found a work for #{work_id}. Performing ingest.")
            if bypass_fedora
              #TODO: set a metadata field on the datacore fileset that points to the SDA rest api
              f = File.open(EMPTY_FILEPATH,'r')
              uf = Hyrax::UploadedFile.new(file: f, user: user)
              AttachFilesToWorkJob.perform_now( w, [uf], w.depositor || user.user_key, work_attributes(w).merge(bypass_fedora: bypass_url(w, filename)) )
              f.close()
            else
              f = File.open(filepath,'r')
              uf = Hyrax::UploadedFile.new(file: f, user: user)
              AttachFilesToWorkJob.perform_now( w, [uf], w.depositor || user.user_key, work_attributes(w) )
              f.close()
            end
            if INGEST_OUTBOX.present?
              newpath = File.join(INGEST_OUTBOX, filename)
              FileUtils.mv(filepath,newpath)
            end
          rescue ActiveFedora::ObjectNotFoundError
            logger.error("No work found for #{work_id}.  Skipping ingest.")
          end
        end
      else
        logger.error("Invalid filename for #{filename}. Skipping ingest.")
      end
    end

    def bypass_url(_work, file)
      collection = 'datacore'
      object = file
      "/sda/request/#{collection}/#{object}"
    end

    def work_attributes(work)
      {
        visibility: work.visibility,
        visibility_during_lease: work.visibility_during_lease,
        visibility_after_lease: work.visibility_after_lease,
        lease_expiration_date: work.lease_expiration_date,
        embargo_release_date: work.embargo_release_date,
        visibility_during_embargo: work.visibility_during_embargo,
        visibility_after_embargo: work.visibility_after_embargo
      }
    end
  end
end
