# frozen_string_literal: true

module Deepblue
  module ZipDownloadControllerBehavior
    extend ActiveSupport::Concern
    included do
      protect_from_forgery with: :null_session,    only: [:zip_download]
    end

    def zip_download
      require 'zip'
      require 'tempfile'

      tmp_dir = Settings.tmpdir || '/tmp'
      tmp_dir = Pathname.new tmp_dir
      # Deepblue::LoggingHelper.debug "Download Zip begin tmp_dir #{tmp_dir}"
      Deepblue::LoggingHelper.bold_debug [ "zip_download begin", "tmp_dir=#{tmp_dir}" ]
      target_dir = target_dir_name_id( tmp_dir, curation_concern.id )
      # Deepblue::LoggingHelper.debug "Download Zip begin copy to folder #{target_dir}"
      Deepblue::LoggingHelper.bold_debug [ "zip_download", "target_dir=#{target_dir}" ]
      Dir.mkdir( target_dir ) unless Dir.exist?( target_dir )
      target_zipfile = target_dir_name_id( target_dir, curation_concern.id, ".zip" )
      # Deepblue::LoggingHelper.debug "Download Zip begin copy to target_zipfile #{target_zipfile}"
      Deepblue::LoggingHelper.bold_debug [ "zip_download", "target_zipfile=#{target_zipfile}" ]
      File.delete target_zipfile if File.exist? target_zipfile
      # clean the zip directory if necessary, since the zip structure is currently flat, only
      # have to clean files in the target folder
      files = Dir.glob( (target_dir.join '*').to_s)
      Deepblue::LoggingHelper.bold_debug files, label: "zip_download files to delete:"
      files.each do |file|
        File.delete file if File.exist? file
      end
      Deepblue::LoggingHelper.debug "Download Zip begin copy to folder #{target_dir}"
      Deepblue::LoggingHelper.bold_debug [ "zip_download", "begin copy target_dir=#{target_dir}" ]
      Zip::File.open(target_zipfile.to_s, Zip::File::CREATE ) do |zipfile|
        metadata_filename = curation_concern.metadata_report( dir: target_dir )
        zipfile.add( metadata_filename.basename, metadata_filename )
        export_file_sets_to( target_dir: target_dir, log_prefix: "Zip: " ) do |target_file_name, target_file|
          zipfile.add( target_file_name, target_file )
        end
      end
      # Deepblue::LoggingHelper.debug "Download Zip copy complete to folder #{target_dir}"
      Deepblue::LoggingHelper.bold_debug [ "zip_download", "download complete target_dir=#{target_dir}" ]
      send_file target_zipfile.to_s
    end

    def zip_download_enabled?
      Settings.zip_download_enabled
    end

    protected

      def export_file_sets_to( target_dir:,
                               log_prefix: "",
                               do_export_predicate: ->(_target_file_name, _target_file) { true },
                               quiet: false,
                               &block )
        file_sets = curation_concern.file_sets
        Deepblue::ExportFilesHelper.export_file_sets( target_dir: target_dir,
                                                      file_sets: file_sets,
                                                      log_prefix: log_prefix,
                                                      do_export_predicate: do_export_predicate,
                                                      quiet: quiet,
                                                      &block )
      end

    private

      def target_dir_name_id( dir, id, ext = '' )
        dir.join "#{DeepBlueDocs::Application.config.base_file_name}#{id}#{ext}"
      end
  end
end
