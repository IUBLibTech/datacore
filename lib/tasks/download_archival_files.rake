# cronjob task to interact with SDA on behalf of ArchiveFile and ArchiveController
# reads job parameters files to request file transfer to SDA cache, then to scratch space
# <original filename>.datacore.yml files are:
# - created by file get! calls
# - updated when download is completed
# - used to track deleting files after completion
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
      logger.info("Starting archive downloads from #{directory}")
      @directory_files = directory_files(directory)
      if @directory_files.any?
        logger.info("#{@directory_files.size} files found.")
        @directory_files.each_with_index do |yaml_path, index|
          logger.info("Starting archive download #{index+1}/#{@directory_files.size} for #{yaml_path}")
          process_file(yaml_path)
          logger.info("Finished archive download #{index+1}/#{@directory_files.size} for #{yaml_path}")
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
      yaml = YAML.load_file(yaml_path)
      ArchiveFile.new(collection: yaml[:collection], object: yaml[:object])
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
      when :unstaged
        stage_file(yaml_path)
      when :staged
        download_file(yaml_path)
      else
        process_error(yaml_path, "unexpected file status: #{current_status}")
      end
    end

    def process_error(yaml_path, error)
      logger.error(error)
      yaml = YAML.load_file(yaml_path)
      yaml[:errors] ||= {}
      yaml[:errors][Time.now.to_s] = error
      File.write(yaml_path, yaml.to_yaml)
    end

    def stage_file(yaml_path)
      logger.info("Staging request for #{yaml_path}")
      yaml = YAML.load_file(yaml_path)
      yaml[:staging_requested] ||= []
      yaml[:staging_requested] << Time.now.to_s
      File.write(yaml_path, yaml.to_yaml)

      system(curl_command(yaml: yaml, output: false))

      logger.info("Staging request submitted")
    end

    def download_file(yaml_path)
      logger.info("Download initiated for #{yaml_path}")
      yaml = YAML.load_file(yaml_path)
      yaml[:download_started] = Time.now.to_s
      File.write(yaml_path, yaml.to_yaml)

      file_path = yaml[:file_path]
      download_path = yaml[:file_path] + '.datacore.download'
      system(curl_command(yaml: yaml, output: download_path))
      FileUtils.mv(download_path, file_path)

      yaml[:download_completed] = Time.now.to_s
      File.write(yaml_path, yaml.to_yaml)
      logger.info("Download completed at #{file_path}")
    end

    def curl_command(yaml:, output: nil)
      header = "Authorization: #{Settings.archive_api.username}:#{Settings.archive_api.password}"
      if output
        "curl -H '#{header}' #{yaml[:url]} --output #{output}"
      else
        "curl -I -H '#{header}' #{yaml[:url]}"
      end
    end

    def clean_local_file(yaml_path)
      yaml = YAML.load_file(yaml_path)
      if delete_file?(yaml_path)
        yaml[:deleted] = Time.now.to_s
        FileUtils.rm(yaml[:file_path])
        logger.info("Deleted #{yaml[:file_path]}")
        File.write(yaml_path, yaml.to_yaml)
        FileUtils.mv(yaml_path, yaml_path + '.deleted')
      end
    end

    def delete_file?(yaml_path)
      yaml = YAML.load_file(yaml_path)
      return false unless yaml[:user_downloaded] || yaml[:download_completed]
      return true if yaml[:user_downloaded] && ((Time.now - Time.parse(yaml[:user_downloaded])).to_i > TIMEOUT_AFTER_DOWNLOAD.to_i)
      return true if yaml[:download_completed] && ((Time.now - Time.parse(yaml[:download_completed])).to_i > TIMEOUT_BEFORE_DOWNLOAD.to_i)
    end
  end
end
