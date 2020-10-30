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
      ingest_dirname = '/home/bkeese/Downloads'
      size_limit = 5 * 2**30 # 5 GB

      user = User.find_by_user_key(user_key)
      processed_dirname = File.join(ingest_dirname,'processed')

      Dir.each_child(ingest_dirname) do |filename|
        filepath = File.join(ingest_dirname, filename)
        filename.match(/^(?<work_id>([a-z]|\d){9})_(?<filenamepart>.*)$/) do |m|
          if m
            work_id = m[:work_id]
            filenamepart = m[:filenamepart]
            size = File.size(filepath)
            puts "Attempting ingest of file #{filename} as #{work_id} (#{number_to_human_size(size)})"
            if size > size_limit
              puts" - File is too big to store directly in DataCore"
            else
              begin
                w = DataSet.find(work_id)
                puts " - Found a work for #{work_id}. Performing ingest."
                # move file with work id in filename to proccessing dir, remove work id from filename
                newpath = File.join(processed_dirname, work_id)
                FileUtils.mkdir_p(newpath)
                newpath = File.join(newpath, filenamepart)
                FileUtils.mv(filepath,newpath)

                f = File.open(newpath,'r')
                uf = Hyrax::UploadedFile.new(file: f, user: user)
                AttachFilesToWorkJob.perform_now( w, [uf], user_key, work_attributes(w) )
                f.close()
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
