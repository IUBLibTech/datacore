require 'rails_helper'

class MockLogger
  def error(message)
  end

  def info(message)
  end

  def warn(message)
  end
end


RSpec.describe ArchiveFileWorker do

  subject { described_class.new("path of yaml", logger: MockLogger.new) }


  pending "constants"


  describe "#initialize" do
    it "sets instance variables" do
      archive_file_worker = ArchiveFileWorker.new("yaml path", logger: "logger")
      expect(archive_file_worker.instance_variable_get(:@yaml_path)).to eq "yaml path"
      expect(archive_file_worker.instance_variable_get(:@logger)).to eq "logger"
    end
  end


  describe "#job_yaml" do
    before {
      allow(YAML).to receive(:load_file).with "path of yaml"
    }
    it "loads file with current data" do
      expect(YAML).to receive(:load_file).with "path of yaml"
      subject.job_yaml
    end
  end


  describe "#job_status" do
    before {
      allow(subject).to receive(:job_yaml).and_return :status => "job status yaml"
    }
    it "returns :status of job_yaml" do
      expect(subject.job_status).to eq "job status yaml"
    end
  end


  describe "#archive_file" do
    context "instance variable has a value" do
      before {
        subject.instance_variable_set :@archive_file, "ancient archive"
      }
      it "returns value" do
        expect(subject.archive_file).to eq "ancient archive"
      end
    end

    context "instance variable has no value" do
      before {
        allow(subject).to receive(:job_yaml).and_return :collection => "collectively", object: "objectively"
        allow(::ArchiveFile).to receive(:new).with(collection: "collectively", object: "objectively").and_return "librarians catalog and shelve the receipts"
      }
      it "sets instance variable to new archive file, returns variable" do
        expect(subject.archive_file).to eq "librarians catalog and shelve the receipts"
        expect(subject.instance_variable_get :@archive_file).to eq "librarians catalog and shelve the receipts"
      end
    end
  end


  describe "#self.jobs_dir" do
    before {
      allow(Settings.archive_api).to receive(:local).and_return "archive api local setting"
    }
    it "returns setting" do
      expect(ArchiveFileWorker.jobs_dir).to eq "archive api local setting"
    end
  end


  describe "#self.job_files" do
    context "when jobs directory does NOT exist" do
      before{
        allow(ArchiveFileWorker).to receive(:jobs_dir).and_return "jobs directory"
        allow(Dir).to receive(:exists?).with("jobs directory").and_return false
      }
      it "returns empty array" do
        expect(ArchiveFileWorker.job_files).to be_empty
      end
    end

    context "when jobs directory does exist" do
      before{
        allow(ArchiveFileWorker).to receive(:jobs_dir).and_return "jobs directory"
        allow(Dir).to receive(:exists?).with("jobs directory").and_return true
        allow(Dir).to receive(:glob).with("jobs directory*.datacore.yml").and_return ["b_file", "a_file", "c_file"]
        allow(YAML).to receive(:load_file).with("a_file").and_return :created_at => 1
        allow(YAML).to receive(:load_file).with("b_file").and_return :created_at => 2
        allow(YAML).to receive(:load_file).with("c_file").and_return :created_at => 3
      }
      it "sorts and returns the files from the job directory" do
        expect(ArchiveFileWorker.job_files).to eq ["a_file", "b_file", "c_file"]
      end
    end
  end


  describe "#self.too_many_jobs?" do
    before {
      allow(Settings.archive_api).to receive(:maximum_concurrent_jobs).and_return [{:statuses => ["Public", "Private", "Restricted"], :limit => 2}]
    }

    context "when no job files have a status listed in max settings" do
      before {
        allow(ArchiveFileWorker).to receive(:job_files).and_return ["job_file1", "job_file2"]
        allow(YAML).to receive(:load_file).with("job_file1").and_return :status => "Open"
        allow(YAML).to receive(:load_file).with("job_file2").and_return :status => "Unrestricted"
      }
      it "returns false" do
        expect(ArchiveFileWorker.too_many_jobs?).to eq false
      end
    end

    context "when no job files with a valid status have a count over the limit" do
      before {
        allow(ArchiveFileWorker).to receive(:job_files).and_return ["job_file"]
        allow(YAML).to receive(:load_file).with("job_file").and_return :status => "Public"
      }
      it "returns false" do
        expect(ArchiveFileWorker.too_many_jobs?).to eq false
      end
    end

    context "when job files with a valid status have a count over the limit" do
      before {
        allow(ArchiveFileWorker).to receive(:job_files).and_return ["job_file1", "job_file2"]
        allow(YAML).to receive(:load_file).with("job_file1").and_return :status => "Private"
        allow(YAML).to receive(:load_file).with("job_file2").and_return :status => "Restricted"
      }
      it "returns true" do
        expect(ArchiveFileWorker.too_many_jobs?).to eq true
      end
    end
  end


  describe "#self.too_much_space_used?" do
    before {
      allow(ArchiveFileWorker).to receive(:job_files).and_return ["file path one", "file path two"]
      allow(YAML).to receive(:load_file).with("file path one").and_return :file_path => "file one"
      allow(YAML).to receive(:load_file).with("file path two").and_return :file_path => "file two"

      allow(Settings.archive_api).to receive(:maximum_disk_space).and_return 30
    }

    context "when job files are not files" do
      before {
        allow(File).to receive(:file?).with("file one").and_return false
        allow(File).to receive(:file?).with("file two").and_return false

        allow(File).to receive(:size).with("file one").and_return "15"
        allow(File).to receive(:size).with("file two").and_return "16"
      }
      it "returns false" do
        expect(ArchiveFileWorker.too_much_space_used?).to eq false
      end
    end

    context "when job files are files" do
      before {
        allow(File).to receive(:file?).with("file one").and_return true
        allow(File).to receive(:file?).with("file two").and_return true
      }

      context "when sum of file sizes is greater than (or equal to) maximum allowed" do
        before {
          allow(File).to receive(:size).with("file one").and_return "15"
          allow(File).to receive(:size).with("file two").and_return "16"
        }
        it "returns true" do
          expect(ArchiveFileWorker.too_much_space_used?).to eq true
        end
      end

      context "when sum of file sizes is less than maximum allowed" do
        before {
          allow(File).to receive(:size).with("file one").and_return "14"
          allow(File).to receive(:size).with("file two").and_return "13"
        }
        it "returns false" do
          expect(ArchiveFileWorker.too_much_space_used?).to eq false
        end
      end
    end
  end


  describe "#self.block_new_jobs?" do
    context "when too_many_jobs? is true" do
      before {
        allow(ArchiveFileWorker).to receive(:too_many_jobs?).and_return true
      }
      it "returns true" do
        expect(ArchiveFileWorker).to receive(:too_many_jobs?)
        expect(ArchiveFileWorker).not_to receive(:too_much_space_used?)
        expect(ArchiveFileWorker.block_new_jobs?).to eq true
      end
    end

    context "when too_many_jobs? is false" do
      before {
        allow(ArchiveFileWorker).to receive(:too_many_jobs?).and_return false
      }

      context "when too_much_space_used? is true" do
        before {
          allow(ArchiveFileWorker).to receive(:too_much_space_used?).and_return true
        }
        it "returns true" do
          expect(ArchiveFileWorker).to receive(:too_much_space_used?)
          expect(ArchiveFileWorker).to receive(:too_many_jobs?)
          expect(ArchiveFileWorker.block_new_jobs?).to eq true
        end
      end

      context "when too_much_space_used? is false" do
        before {
          allow(ArchiveFileWorker).to receive(:too_much_space_used?).and_return false
        }
        it "returns true" do
          expect(ArchiveFileWorker).to receive(:too_much_space_used?)
          expect(ArchiveFileWorker).to receive(:too_many_jobs?)
          expect(ArchiveFileWorker.block_new_jobs?).to eq false
        end
      end
    end
  end


  pending "#process_file"


  describe "#update_job_yaml" do
    before {
      allow(subject).to receive(:job_yaml).and_return "key1" => {"last" => "zeta"}, "key2" => ["dos" => "dernier"], "key3" => "subterranean"
      allow(subject).to receive(:yaml_path).and_return "yaml path"
    }

    context "when empty hash(es) and array(s) are passed in and not all keys in the job yaml have matches" do
      before {
        allow(File).to receive(:write).with "yaml path", "---\nkey1:\n  last: zeta\nkey2:\n- dos: dernier\nkey3: subterranean\n"
      }
      it "updates job file" do
        expect(File).to receive(:write).with "yaml path", "---\nkey1:\n  last: zeta\nkey2:\n- dos: dernier\nkey3: subterranean\n"
        subject.update_job_yaml "key1" => {}, "key2" => []
      end
    end

    context "when hash(es), array(s), and/or other object(s) such as string(s) are passed in" do
      before {
        allow(File).to receive(:write).with "yaml path", "---\nkey1:\n  last: zeta\n  first: alpha\nkey2:\n- dos: dernier\n- uno: premier\nkey3: celestial\n"
      }
      it "updates job file" do
        expect(File).to receive(:write).with "yaml path", "---\nkey1:\n  last: zeta\n  first: alpha\nkey2:\n- dos: dernier\n- uno: premier\nkey3: celestial\n"
        subject.update_job_yaml "key1" => {"first" => "alpha"}, "key2" => ["uno" => "premier"], "key3" => "celestial"
      end
    end
  end


  describe "#process_error" do
    before {
      allow(Time).to receive(:now).and_return "08/05/2025"
      allow(subject).to receive(:update_job_yaml).with(errors: { "08/05/2025" => "this is in error"})
    }
    it "logs error and calls update_job_yaml" do
      expect(subject.logger).to receive(:error).with "this is in error"
      expect(subject).to receive(:update_job_yaml).with(errors: { "08/05/2025" => "this is in error"})
      subject.process_error "this is in error"
    end
  end


  describe "#stage_file" do
    before {
      allow(subject).to receive(:yaml_path).and_return "the path of yaml"
      allow(Time).to receive(:now).and_return "08/12/2025"
      allow(subject).to receive(:update_job_yaml).with staging_requested: ["08/12/2025"], status: :staging_requested
      allow(subject).to receive(:curl_command).and_return "curl command"
      allow(subject).to receive(:system).with "curl command"
    }
    it "submits staging request" do
      expect(subject.logger).to receive(:info).with "Staging request for the path of yaml"
      expect(subject).to receive(:update_job_yaml).with staging_requested: ["08/12/2025"], status: :staging_requested
      expect(subject).to receive(:system).with "curl command"
      expect(subject.logger).to receive(:info).with "Staging request submitted"
      subject.stage_file
    end
  end


  describe "#download_file" do
    before {
      allow(subject).to receive(:yaml_path).and_return "Yaml Path"
      allow(subject).to receive(:update_job_yaml).with({status: :staged_after_request})
    }

    context "when too much space used" do
      before {
        allow(subject).to receive(:too_much_space_used?).and_return true
      }
      it "log warning" do
        expect(subject.logger).to receive(:info).with "Download initiated for Yaml Path"
        expect(subject).to receive(:update_job_yaml).with status: :staged_after_request
        expect(subject.logger).to receive(:warn).with "Disk quota exceeded.  Blocking file download until space is available."
        subject.download_file
      end
    end

    context "when not too much space used" do
      before {
        allow(subject).to receive(:too_much_space_used?).and_return false
        allow(Time).to receive(:now).and_return "06/22/2025"
        allow(subject).to receive(:update_job_yaml).with({transfer_started: "06/22/2025"})
        allow(subject).to receive(:curl_command).with(output: true).and_return "curl command"
        allow(subject).to receive(:path).and_return "the path tm"
        allow(subject).to receive(:file_path).and_return "the file path tm"
        allow(FileUtils).to receive(:mv).with("the path tm", "the file path tm")
        allow(subject).to receive(:update_job_yaml).with({status: :local, transfer_completed: "06/22/2025"})
        allow(subject).to receive(:email_requesters)
      }

      context "when error occurs" do
        before {
          allow(subject).to receive(:system).with("curl command").and_raise(StandardError, "Good old-fashioned error")
        }
        it "logs info, updates job, processes error and returns" do
          expect(subject.logger).to receive(:info).with "Download initiated for Yaml Path"
          expect(subject).to receive(:update_job_yaml).with({status: :staged_after_request})
          expect(subject).to receive(:update_job_yaml).with({transfer_started: "06/22/2025"})
          expect(subject).to receive(:process_error).with "Aborting after curl error: #<StandardError: Good old-fashioned error>"
          expect(FileUtils).not_to receive(:mv).with("the path tm", "the file path tm")
          expect(subject).not_to receive(:update_job_yaml).with({status: :local, transfer_completed: "06/22/2025"})
          expect(subject).not_to receive(:email_requesters)
          expect(subject.logger).not_to receive(:info).with "Download completed at the file path tm"
          subject.download_file
        end
      end

      context "when file download successful" do
        before {
          allow(subject).to receive(:system).with "curl command"
        }
        it "downloads file, updates job, emails requesters, and logs info" do
          expect(subject.logger).to receive(:info).with "Download initiated for Yaml Path"
          expect(subject).to receive(:update_job_yaml).with({status: :staged_after_request})
          expect(subject).to receive(:update_job_yaml).with({transfer_started: "06/22/2025"})
          expect(subject).to receive(:system).with "curl command"
          expect(FileUtils).to receive(:mv).with("the path tm", "the file path tm")
          expect(subject).to receive(:update_job_yaml).with({status: :local, transfer_completed: "06/22/2025"})
          expect(subject).to receive(:email_requesters)
          expect(subject.logger).to receive(:info).with "Download completed at the file path tm"
          subject.download_file
        end
      end
    end
  end


  describe "#email_requesters" do
    before {
      allow(subject).to receive(:purge_user_emails)
      allow(Deepblue::EmailHelper).to receive(:contact_email).and_return "contact@example.com"
    }

    context "when Settings.archive_api.send_email evaluates to positive" do
      before {
        allow(Settings.archive_api).to receive(:send_email).and_return true
      }

      context "when user email present" do
        before {
          job_request = {:user_email => "user@example.com"}
          allow(subject).to receive(:job_yaml).and_return({:filename => "job file name", :requests => [job_request]})
          allow(subject).to receive(:filename_for).with({:user_email => "user@example.com"}, "job file name").and_return "name of the file"
          allow(subject).to receive(:email_body_for).with("name of the file", job_request).and_return "the email body"
        }

        context "when email sends successfully" do
          before {
            allow(Deepblue::EmailHelper).to receive(:send_email).with(to: "user@example.com", from: "contact@example.com",
              subject: "DataCORE file available for download: name of the file", body: "the email body", log: true)
          }
          it "emails user, logs email, and purges user emails" do
            expect(subject.logger).to receive(:info).with "Emailing user: user@example.com"
            expect(Deepblue::EmailHelper).to receive(:send_email).with(to: "user@example.com", from: "contact@example.com",
              subject: "DataCORE file available for download: name of the file", body: "the email body", log: true)
            expect(subject.logger).to receive(:info).with "Email sent successfully"
            subject.email_requesters
          end
        end

        context "when error occurs sending email" do
          before {
            allow(Deepblue::EmailHelper).to receive(:send_email).with(to: "user@example.com", from: "contact@example.com",
              subject: "DataCORE file available for download: name of the file", body: "the email body", log: true)
                                                                .and_raise(StandardError, "Home-grown error")
          }
          it "logs error and purges user emails" do
            expect(subject.logger).to receive(:info).with "Emailing user: user@example.com"
            expect(subject.logger).to receive(:error).with "Error emailing user: user@example.com: #<StandardError: Home-grown error>"
            expect(subject.logger).not_to receive(:info).with "Email sent successfully"
            subject.email_requesters
          end
        end

        after {
          expect(Deepblue::EmailHelper).to have_received(:contact_email)
        }
      end

      context "when user email not present" do
        job_request = {:user_email => ""}
        before {
          allow(subject).to receive(:job_yaml).and_return({:filename => "job file name", :requests => [job_request]})
        }
        it "logs warning and purges user emails" do
          expect(Deepblue::EmailHelper).to receive(:contact_email)
          expect(subject).to receive(:job_yaml).and_return({:filename => "job file name", :requests => [job_request]})
          expect(subject).not_to receive(:filename_for)
          expect(subject).not_to receive(:email_body_for)
          expect(subject.logger).to receive(:warn).with "No email address available for request; skipping notification email"
          subject.email_requesters
        end
      end
    end

    context "when Settings.archive_api.send_email evaluates to negative" do
      before {
        allow(Settings.archive_api).to receive(:send_email).and_return nil
      }
      it "purges user emails" do
        expect(Deepblue::EmailHelper).not_to receive(:contact_email)
        expect(Deepblue::EmailHelper).not_to receive(:send_email)

        subject.email_requesters
      end
    end

    after {
      expect(subject).to have_received(:purge_user_emails)
    }
  end


  describe "#email_body_for" do
    context "when email body has file link" do
      before {
        allow(subject).to receive(:file_link_for).with("request").and_return "file link"
      }
      it "returns body including file link" do
        expect(subject.email_body_for "filename", "request").to eq "The archive file you requested, filename," +
          " is now available for download:\nfile link"
      end
    end

    context "when email body has no file link" do
      before {
        allow(subject).to receive(:file_link_for).with("request").and_return nil
      }
      it "returns body without file link" do
        expect(subject.email_body_for "filename", "request").to eq "The archive file you requested, filename," +
           " is now available for download."
      end
    end
  end


  describe "#filename_for" do
    context "when the filename is found" do
      before {
        allow(FileSet).to receive(:search_with_conditions).with(id: "T-4000").and_return(["label_ssi" => "desired filename"])
      }
      it "returns filename found" do
        expect(subject.filename_for({:file_set_id => "T-4000"}, "default filename")).to eq "desired filename"
      end
    end

    context "when the filename is not found" do
      before {
        allow(FileSet).to receive(:search_with_conditions).with(id: "R-5000").and_return([])
      }
      it "returns default filename parameter" do
        expect(subject.filename_for({:file_set_id => "R-5000"}, "default filename")).to eq "default filename"
      end
    end
  end


  describe "#file_link_for" do
    context "when request parameter does not include file_set_id" do
      it "returns nil" do
        expect(subject.file_link_for(:file_set_name => "E-1000")).to be_blank
      end
    end

    context "when there are no FileSets with the file_set_id" do
      before {
        allow(FileSet).to receive(:where).with(id: "E-1000").and_return []
      }
      it "returns nil" do
        expect(FileSet).to receive(:where)
        expect(subject.file_link_for(:file_set_id => "E-1000")).to be_blank
      end
    end

    context "when there are FileSet(s) with the file_set_id" do
      before {
        allow(FileSet).to receive(:where).with(id: "E-1000").and_return [true]
        allow(FileSet).to receive(:find).with("E-1000").and_return "concern"
      }
      context "when FileSet is found" do
        before{
          allow(Deepblue::EmailHelper).to receive(:curation_concern_url).with(curation_concern: "concern").and_return "file link"
        }
        it "returns file_link" do
          expect(subject.file_link_for(:file_set_id => "E-1000")).to eq "file link"
        end
      end

      context "when FileSet is NOT found" do
        before {
          allow(Deepblue::EmailHelper).to receive(:curation_concern_url).with(curation_concern: "concern").and_raise(StandardError, "Classic Error")
        }
        it "processes error" do
          expect(subject).to receive(:process_error).with "Error generating download link for E-1000: #<StandardError: Classic Error>"
          expect(subject.file_link_for(:file_set_id => "E-1000")).to be_blank
        end
      end

      after {
        expect(FileSet).to have_received(:where)
        expect(FileSet).to have_received(:find)
        expect(Deepblue::EmailHelper).to have_received(:curation_concern_url).with(curation_concern: "concern")
      }
    end
  end


  describe "#purge_user_emails" do
    before {
      allow(subject).to receive(:job_yaml).and_return :requests => ["request1", "request2"]
      allow(subject).to receive(:sanitized_hash).with("request1").and_return "sanitized1"
      allow(subject).to receive(:sanitized_hash).with("request2").and_return "sanitized2"
      allow(subject).to receive(:yaml_path).and_return "yaml path"
      allow(File).to receive(:write).with("yaml path", "--- :sanitized1: :sanitized2:")
    }
    it "sanitizes requests and writes to a file" do
      expect(File).to receive(:write).with("yaml path", "---\n:requests:\n- sanitized1\n- sanitized2\n")
      subject.purge_user_emails
    end
  end


  describe "#sanitized_hash" do
    it "merges hash input nullifying user and user_email key values" do
      expect(subject.sanitized_hash :user => "lebaby", :user_email => "lebaby@example.com", :other => "alternate")
        .to eq :user => nil, :user_email => nil, :other => "alternate"
    end
  end


  describe "#file_path" do
    before {
      allow(subject).to receive(:job_yaml).and_return :file_path => "the path of the file"
    }
    it "returns file path" do
      expect(subject.file_path).to eq "the path of the file"
    end
  end


  describe "#path" do
    before {
      allow(subject).to receive(:file_path).and_return "the swan road"
    }
    it "returns file path as string" do
      expect(subject.path).to eq "the swan road.datacore.yml"
    end
  end


  describe "#curl_command" do
    before {
      allow(Settings.archive_api).to receive(:username).and_return "name o'user"
      allow(Settings.archive_api).to receive(:password).and_return "pass th'word"
      allow(subject).to receive(:job_yaml).and_return :url => "th'best url in town"
      allow(subject).to receive(:path).and_return "the high road"
    }
    context "when output is true" do
      it "returns string" do
        expect(subject.curl_command output: true).to eq "curl -H 'Authorization: name o'user:pass th'word' th'best url in town --output the high road"
      end
    end

    context "when output is false" do
      it "returns string" do
        expect(subject.curl_command output: false).to eq "curl -H 'Authorization: name o'user:pass th'word' th'best url in town"
      end
    end
  end


  describe "#clean_local_file" do
    context "when delete_file? is true" do
      before {
        allow(Time).to receive(:now).and_return "6/6/2025"
        allow(subject).to receive(:delete_file?).and_return true
        allow(subject).to receive(:job_yaml).and_return :file_path => "file path"
        allow(FileUtils).to receive(:rm).with("file path")
        allow(subject).to receive(:update_job_yaml).with( {deleted_at: "6/6/2025", status: :deleted} )
        allow(subject).to receive(:yaml_path).and_return "yaml path"
        allow(FileUtils).to receive(:mv).with("yaml path", "yaml path.deleted")
      }
      it "deletes file, updates job, calls logger.info" do
        expect(subject.logger).to receive(:info).with "Deletion timeout met"
        expect(FileUtils).to receive(:rm).with("file path")
        expect(subject.logger).to receive(:info).with "Deleted file path"
        expect(subject).to receive(:update_job_yaml).with( {deleted_at: "6/6/2025", status: :deleted} )
        expect(FileUtils).to receive(:mv).with("yaml path", "yaml path.deleted")
        expect(subject.logger).to receive(:info).with "File deleted"
        subject.clean_local_file
      end
    end

    context "when delete_file? is false" do
      before {
        allow(subject).to receive(:delete_file?).and_return false
      }

      it "calls logger.info" do
        expect(subject.logger).to receive(:info).with "Local file in place, leaving until deletion timeout conditions met"
        subject.clean_local_file
      end
    end
  end

  describe "#delete_file?" do
    before {
      allow(Time).to receive(:now).and_return DateTime.new(2025, 7, 4, 0, 1)
      allow(Settings.archive_api).to receive(:timeout_after_download).and_return 48.hours
      allow(Settings.archive_api).to receive(:timeout_before_download).and_return 24.hours
    }

    context "when not latest user download and transfer not completed" do
      before {
        allow(subject).to receive(:job_yaml).and_return :latest_user_download => false, :transfer_completed => false
      }
      it "returns false" do
        expect(subject.delete_file?).to eq false
      end
    end

    skip "Add a test where latest user download and 'after download' timeout over"

    skip "Add a test where transfer complete and 'before download' timeout over"

   end

end
