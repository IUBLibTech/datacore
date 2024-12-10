# cronjob task to interact with SDA on behalf of ArchiveFile and ArchiveController
# reads job parameters files to request file transfer to SDA cache, then to scratch space
# <original filename>.datacore.yml files are:
# - created by file get! calls
# - updated when download is completed
# - used to track deleting files after completion
# makes side-effect calls to archive server for staging request, file download
require 'fileutils'

namespace :datacore do

  desc "Download archival files"
  task download_archival_files: :environment do
    Datacore::DownloadArchivalFilesTask.new.run
  end

end

module Datacore
  class DownloadArchivalFilesTask
    include ActionView::Helpers::NumberHelper

    LOG_PATH  = Rails.root.join('log', 'archive_download.log')

    def self.logger
      @@logger ||= Logger.new(LOG_PATH)
    end

    def logger
      self.class.logger
    end

    def run
      if Settings.archive_api.disabled
        logger.info("Skipping archive job processing, archive API is disabled")
        return
      end
      logger.info("Starting archive job processing from #{ArchiveFileWorker.jobs_dir}")
      @job_files = ArchiveFileWorker.job_files
      if @job_files.any?
        logger.info("#{@job_files.size} files found.")
        @job_files.each_with_index do |yaml_path, index|
          logger.info("Starting archive job processing #{index+1}/#{@job_files.size} for #{yaml_path}")
          begin
            ArchiveFileWorker.new(yaml_path, logger: logger).process_file
          rescue => error
            logger.info("ArchiveFileWorker error: #{error.message}")
          end
          logger.info("Finished archive job processing #{index+1}/#{@job_files.size} for #{yaml_path}")
        end
      else
        logger.info("No files found.")
      end
      logger.info("Finished ingest from #{ArchiveFileWorker.jobs_dir}")
    end
  end
end
