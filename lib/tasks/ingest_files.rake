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
    def run
      puts "Starting ingest."

      user_key = 'bkeese@iu.edu'
      ingest_dirname = '/N/beryllium/srv/digitize/datacore'
      sda_dropbox = '/N/beryllium/srv/digitize/Archiver_spool/datacore'
      size_limit = 5 * 2**30 # 5 GB

      user = User.find_by_user_key(user_key)

      (Dir.entries(ingest_dirname) - [".", ".."]).each do |filename|
        filepath = File.join(ingest_dirname, filename)

        # if the file is not currently open by another process
        pids = `lsof -t '#{filepath}'`
        if pids.present?
          puts "Skipping file that is in use: #{filename}"
          next
        end
        # Look for files with names matching the pattern "<workid>_<filename>"
        #   (a work_id is a string of 9 alphanumberic characters)
        filename.match(/^(?<work_id>([a-z]|\d){9})_(?<filenamepart>.*)$/) do |m|
          # if the filename matches the pattern
          if m
            work_id = m[:work_id]
            filenamepart = m[:filenamepart]
            size = File.size(filepath)
            puts "Attempting ingest of file #{filename} as #{work_id} (#{number_to_human_size(size)})"
            if size > size_limit
              #TODO: set a metadata field on the datacore fileset that points to the SDA rest api
              puts" - File is too big to store directly in DataCore"
            else
              begin
                w = DataSet.find(work_id)
                puts " - Found a work for #{work_id}. Performing ingest."
                f = File.open(filepath,'r')
                uf = Hyrax::UploadedFile.new(file: f, user: user)
                AttachFilesToWorkJob.perform_now( w, [uf], user_key, work_attributes(w) )
                f.close()

                # move file with work id in filename to sda dropbox, remove work id from filename
                newpath = File.join(sda_dropbox, filename)
                FileUtils.mv(filepath,newpath)

              rescue ActiveFedora::ObjectNotFoundError
                puts " - No work found for #{work_id}"
              end
            end
          end
        end
      end
    end

    def work_attributes (work)
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
