# frozen_string_literal: true
require 'fileutils'

namespace :datacore do

  desc "Ingest dataset files from directory for previously created datasets."
  task ingest_directory: :environment do
    DataCore::IngestFilesFromDirectoryTask.new.run
  end

end

module DataCore

  class IngestFilesFromDirectoryTask
    include ActionView::Helpers::NumberHelper

    USER_KEY = 'bkeese@iu.edu'
    INGEST_DIR = '/N/capybara/srv/digitize/datacore'
    LARGE_INGEST_DIR = '/N/capybara/srv/digitize/datacore_large' # FIXME: if subdir, filter from Dir.entries
    SDA_DROPBOX = '/N/capybara/srv/digitize/Archiver_spool/datacore'
    SIZE_LIMIT = 5 * 2**30 # 5 GB
    LOG_PATH  = 'log/ingest.log'
    EMPTY_FILEPATH = 'lib/tasks/empty.txt' # FIXME: refactor EMPTY_FILEPATH

    def run
      $stdout.reopen(LOG_PATH, "a")
      $stdout.sync = true
      $stderr.reopen($stdout)

      puts "Starting ingest."
      return
      user = User.find_by_user_key(USER_KEY)
      ingest_directory(INGEST_DIR, user, bypass_fedora: false)
      ingest_directory(LARGE_INGEST_DIR, user, bypass_fedora: true)
    end

    def ingest_directory(directory, user, bypass_fedora: false)
      (Dir.entries(directory) - [".", ".."]).each do |filename| # FIXME: filter subdir?"
        filepath = File.join(directory, filename)
        ingest_file(filepath, user, bypass_fedora: bypass_fedora)
      end
    end

    def ingest_file(filepath, user, bypass_fedora: false)
      # if the file is not currently open by another process
      pids = `lsof -t '#{filepath}'`
      if pids.present?
        puts "Skipping file that is in use: #{filename}"
        return
      end
      # Look for files with names matching the pattern "<workid>_<filename>"
      #   (a work_id is a string of 9 alphanumberic characters)
      filename.match(/^(?<work_id>([a-z]|\d){9})_(?<filenamepart>.*)$/) do |m|
        # if the filename matches the pattern
        if m
          work_id = m[:work_id]
          filenamepart = m[:filenamepart]
          size = File.size(filepath)
          puts "Attempting ingest of file #{filenamepart} as #{work_id} (#{number_to_human_size(size)})"
          if bypass_fedora
            puts "File ingest called bypassing fedora storage"
          elsif size > SIZE_LIMIT
            puts "File ingest called for fedora stroage, but file is too big to store directly in DataCore"
            bypass_fedora = true
          end
          begin
            w = DataSet.find(work_id)
            puts " - Found a work for #{work_id}. Performing ingest."
            if bypass_fedora
              #TODO: set a metadata field on the datacore fileset that points to the SDA rest api
              f = File.open(EMPTY_FILEPATH,'r')
              uf = Hyrax::UploadedFile.new(file: f, user: user)
              AttachFilesToWorkJob.perform_now( w, [uf], user.user_key, work_attributes(w).merge(bypass_fedora: bypass_url(w, filenamepart)) )
              f.close()
            else

              f = File.open(filepath,'r')
              uf = Hyrax::UploadedFile.new(file: f, user: user)
              AttachFilesToWorkJob.perform_now( w, [uf], user.user_key, work_attributes(w) )
              f.close()
            end
            # move file with work id in filename to sda dropbox, remove work id from filename
            newpath = File.join(SDA_DROPBOX, filename)
            FileUtils.mv(filepath,newpath)
          rescue ActiveFedora::ObjectNotFoundError
            puts " - No work found for #{work_id}"
          end
        else
          puts "Invalid filename for #{filename}, skipping."
        end
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
