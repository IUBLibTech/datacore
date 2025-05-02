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
    VERY_LARGE_INGEST_DIR = Settings.ingest.very_large_inbox
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
      split_very_large_directory(VERY_LARGE_INGEST_DIR)
    end

    def split_very_large_directory(directory)
      logger.info("Splitting any very-large files from #{directory}")
      @directory_files = directory_files(directory)
      if @directory_files.any?
        logger.info("#{@directory_files.size} files found.")
        @directory_files.each_with_index do |filepath, index|
          logger.info("Starting file splitting #{index+1}/#{@directory_files.size} for #{filepath}")
          split_file(directory, filepath)
          logger.info("Finished file splitting #{index+1}/#{@directory_files.size} for #{filepath}")
        end
      else
        logger.info("No files found.")
      end
      logger.info("Finished splitting files from #{directory}")
    end

    def split_file(directory, filepath)
      # if the file is not currently open by another process
      pids = `lsof -t '#{filepath}'`
      if pids.present?
        logger.error("Skipping file that is in use: #{filepath}")
        return
      end

      validation_results = validate_filename(filepath)
      unless validation_results&.dig(:work).present?
        logger.info("File name invalid or work not found for #{filepath}, skipping file splitting.")
      end

      if validation_results[:category] == :very_large
        output_filepath = "#{filepath}.7z"
        output_basename = Pathname.new(filepath).basename
        # @todo add error catching, logging
        zip_count = ((validation_results[:size] * 1.0) / INGEST_SIZE_LIMIT).ceil
        zip_command = "7z a -v#{INGEST_SIZE_LIMIT} #{output_filepath} #{filepath}"
        begin
          logger.info("Splitting #{filepath} into #{zip_count} files.")
          system(zip_command)
          Dir.entries(directory).select { |e| e.match "#{output_basename}." }.map do |zip_file|
            FileUtils.mv(Pathname.new(directory).join(zip_file),
                         Pathname.new(LARGE_INGEST_DIR).join(zip_file))
          end
          # remove original
          FileUtils.rm(filepath)
        rescue => e
          Rails.logger.error("Error splitting #{filepath} via \"#{zip_command}\", moving results, and removing original: #{e.inspect}")
        end
      else
        logger.info("Ingestable file found in very-large directory.  Skipping file split, moving to large directory.")
        begin
          FileUtils.mv(filepath,
                       Pathname.new(LARGE_INGEST_DIR).join(output_basename))
        rescue => e
          Rails.logger.error("Error moving #{filepath} to #{LARGE_INGEST_DIR}: #{e.inspect}")
        end
      end
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

    # Look for files with names matching the pattern "<workid>_<filename>"
    #   (a work_id is a string of 9 alphanumberic characters)
    VALIDATION_REGEX = /^(?<work_id>([a-z]|\d){9})_(?<filenamepart>.*)$/

    def validate_filename(filepath)
      filename = Pathname.new(filepath).basename.to_s
      unless filename.match(VALIDATION_REGEX)
        logger.error("File #{filename} fails validation check.")
        return false
      end
      result = {}
      filename.match(VALIDATION_REGEX) do |match_result|
        result[:work_id] = match_result[:work_id]
        result[:filenamepart] = match_result[:filenamepart]
        size = File.size(filepath)
        result[:size] = size
        result[:human_size] = number_to_human_size(size)
        if size > INGEST_SIZE_LIMIT
          category = :very_large
        elsif size > FEDORA_SIZE_LIMIT
          category = :large
        else
          category = :standard
        end
        result[:category] = category
      end
      begin
        result[:work] = DataSet.find(result[:work_id])
      rescue ActiveFedora::ObjectNotFoundError
        result[:work] = nil
        logger.error("No work found for #{work_id} in #{filename}.")
      end
      result
    end

    def ingest_file(filepath, user, bypass_fedora: false)
      # if the file is not currently open by another process
      pids = `lsof -t '#{filepath}'`
      if pids.present?
        logger.error("Skipping file that is in use: #{filepath}")
        return
      end
      validation_result = validate_filename(filepath)
      if validation_result
        work = validation_result[:work]
        work_id = validation_result[:work_id]
        if work.nil? 
          logger.error("No work found for #{work_id}.  Skipping ingest.")
          return
        end
        filenamepart = validation_result[:filenamepart]
        human_size = validation_result[:human_size]
        category = validation_result[:category]
        filename = Pathname.new(filepath).basename
        if category == :very_large
          logger.warn("File size (#{human_size}) exceeds maximum ingest limit.  Skipping.")
          begin
            FileUtils.mv(filepath,
                         Pathname.new(VERY_LARGE_INGEST_DIR).join(filename))
          rescue => e
            Rails.logger.error("Error moving #{filepath} to #{VERY_LARGE_INGEST_DIR}: #{e.inspect}")
          end
          return
        end

        logger.info("Attempting ingest of file #{filenamepart} as #{work_id} (#{human_size})")
        if bypass_fedora
          logger.info("File ingest called bypassing fedora storage")
        elsif category == :large
          logger.info("File ingest called for fedora storage, but triggering bypass due to excessive file size: #{human_size}")
          bypass_fedora = true
        end

        if bypass_fedora
          f = File.open(EMPTY_FILEPATH,'r')
          uf = Hyrax::UploadedFile.new(file: f, user: user)
          AttachFilesToWorkJob.perform_now( work, [uf], work.depositor || user.user_key, work_attributes(work).merge(bypass_fedora: bypass_url(work, filename)) )
          f.close()
        else
          f = File.open(filepath,'r')
          uf = Hyrax::UploadedFile.new(file: f, user: user)
          AttachFilesToWorkJob.perform_now( work, [uf], work.depositor || user.user_key, work_attributes(work) )
          f.close()
        end
        if INGEST_OUTBOX.present?
          logger.info("File ingest called for fedora storage, but triggering bypass due to excessive file size: #{number_to_human_size(size)}")
          newpath = File.join(INGEST_OUTBOX, filename)
          begin
            FileUtils.mv(filepath,newpath)
          rescue => e
            Rails.logger.error("Error moving #{filepath} to #{newpath} for outbox processing: #{e.inspect}")
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
