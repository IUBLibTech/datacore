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
    DataCore::DownloadArchivalFilesTask.new.run
  end

end

module DataCore
  class DownloadArchivalFilesTask
    include ActionView::Helpers::NumberHelper

    DOWNLOAD_DIR = Settings.archive_api.local % ''
    LOG_PATH  = Rails.root.join('log', 'archive_download.log')
    TIMEOUT_BEFORE_DOWNLOAD = Settings.archive_api.timeout_before_download || 24.hours
    TIMEOUT_AFTER_DOWNLOAD = Settings.archive_api.timeout_after_download || 3.hours

    def self.logger
      @@logger ||= Logger.new(LOG_PATH)
    end

    def logger
      self.class.logger
    end

    def run
      directory = DOWNLOAD_DIR
      logger.info("Starting archive job processing from #{directory}")
      @directory_files = directory_files(directory)
      if @directory_files.any?
        logger.info("#{@directory_files.size} files found.")
        @directory_files.each_with_index do |yaml_path, index|
          logger.info("Starting archive job processing #{index+1}/#{@directory_files.size} for #{yaml_path}")
          process_file(yaml_path)
          logger.info("Finished archive job processing #{index+1}/#{@directory_files.size} for #{yaml_path}")
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
      end.select do |filepath|
        filepath.match(/\.datacore.yml$/)
      end
    end

    def archive_file_for(yaml_path)
      job_yaml = YAML.load_file(yaml_path)
      ArchiveFile.new(collection: job_yaml[:collection], object: job_yaml[:object])
    end

    def process_file(yaml_path)
      # if the file is not currently open by another process
      pids = `lsof -t '#{yaml_path}'`
      if pids.present?
        logger.error("Skipping file that is in use: #{yaml_path}")
        return
      end
      current_status = archive_file_for(yaml_path).status
      case current_status
      when :local
        clean_local_file(yaml_path)
      when :staging_available
        stage_file(yaml_path)
      when :staging_requested
        stage_file(yaml_path) # TODO: reconsider?
      when :staged_after_request, :staged_without_request
        download_file(yaml_path)
      else
        process_error(yaml_path, "unexpected file status: #{current_status}")
      end
    end

    def update_job_yaml(yaml_path, hash)
      job_yaml = YAML.load_file(yaml_path)
      hash.each do |k,v|
        case v
        when Hash
          job_yaml[k] ||= {}
          job_yaml[k] = job_yaml[k].merge(v)
        when Array
          job_yaml[k] ||= []
          job_yaml[k] = job_yaml[k] + v
        else
          job_yaml[k] = v
        end
      end
      File.write(yaml_path, job_yaml.to_yaml)
    end

    def process_error(yaml_path, error)
      logger.error(error)
      update_job_yaml(yaml_path, { errors: { Time.now => error }})
    end

    def stage_file(yaml_path)
      logger.info("Staging request for #{yaml_path}")
      update_job_yaml(yaml_path, { staging_requested: [Time.now], status: :staging_requested })

      job_yaml = YAML.load_file(yaml_path)
      system(curl_command(yaml: job_yaml, output: false))

      logger.info("Staging request submitted")
    end

    def download_file(yaml_path)
      logger.info("Download initiated for #{yaml_path}")
      update_job_yaml(yaml_path, { status: :staged_after_request, download_started: Time.now })

      job_yaml = YAML.load_file(yaml_path)
      file_path = job_yaml[:file_path]
      download_path = job_yaml[:file_path] + '.datacore.download'
      system(curl_command(yaml: job_yaml, output: download_path))
      FileUtils.mv(download_path, file_path)

      update_job_yaml(yaml_path, { status: :local, download_completed: Time.now })
      logger.info("Download completed at #{file_path}")
    end

    def curl_command(yaml:, output: nil)
      header = "Authorization: #{Settings.archive_api.username}:#{Settings.archive_api.password}"
      if output
        "curl -H '#{header}' #{yaml[:url]} --output #{output}"
      else
        "curl -H '#{header}' #{yaml[:url]}"
      end
    end

    def clean_local_file(yaml_path)
      if delete_file?(yaml_path)
        logger.info("Deletion timeout met")
        job_yaml = YAML.load_file(yaml_path)
        FileUtils.rm(job_yaml[:file_path])
        logger.info("Deleted #{job_yaml[:file_path]}")
        update_job_yaml(yaml_path, { deleted_at: Time.now, status: :deleted })
        FileUtils.mv(yaml_path, yaml_path + '.deleted')
        logger.info("File deleted")
      else
        logger.info("Local file in place, leaving until deletion timeout conditions met")
      end
    end

    def delete_file?(yaml_path)
      job_yaml = YAML.load_file(yaml_path)
      return false unless job_yaml[:user_downloaded] || job_yaml[:download_completed]
      return true if job_yaml[:user_downloaded] && ((Time.now - job_yaml[:user_downloaded]).to_i > TIMEOUT_AFTER_DOWNLOAD.to_i)
      return true if job_yaml[:download_completed] && ((Time.now - job_yaml[:download_completed]).to_i > TIMEOUT_BEFORE_DOWNLOAD.to_i)
    end
  end
end
