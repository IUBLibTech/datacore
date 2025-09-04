require 'rails_helper'

class MockFileWorker

  def update_job_yaml(new_params)
  end
end

class MockStatusRequest

  def initialize(code)
    @code = code
  end
  # def code
  #   @code
  # end

  def try(code)
    @code
  end

end

class MockHTTP

  def request(hash)
  end
end

RSpec.describe ArchiveFile do

  subject { described_class.new(collection: "collection", object: "objectify") }


  describe "#initialize" do
    it 'sets instance variables' do
      archive_file = ArchiveFile.new(collection: "collective", object: "objective")
      expect(archive_file.instance_variable_get :@collection).to eq "collective"
      expect(archive_file.instance_variable_get :@object).to eq "objective"
    end
  end


  describe "to_s" do
    before {
      allow(subject).to receive(:status).and_return "status"
    }
    it "returns string representation of the archive file" do
      expect(subject.to_s).to eq "collection: collection, object: objectify, status: status"
    end
  end


  describe "#status" do
    before {
      allow(subject).to receive(:virtual_status).and_return "virtual status"
    }

    context "when downloaded" do
      before {
        allow(subject).to receive(:downloaded?).and_return true
      }
      it "returns :local symbol" do
        expect(subject.status).to eq :local
      end
    end

    context "when not downloaded" do
      before {
        allow(subject).to receive(:downloaded?).and_return false
      }
      it "calls virtual_status" do
        expect(subject.status).to eq "virtual status"
      end
    end
  end


  describe "#description_for_status" do
    context "when lookup_status parameter is in lookup_hash parameter" do
      it "returns lookup_hash value of lookup_status key" do
        expect(subject.description_for_status method: "methodical", lookup_status: "lookup status", lookup_hash: {"lookup status" => "allegorical"}).to eq "allegorical"
      end
    end

    context "when lookup_status parameter is not in lookup_hash parameter" do
      before {
        allow(Rails.logger).to receive(:error).with "#methodical called with invalid key: lookup status"
      }
      it "calls Rails.logger.error, returns nil" do
        expect(Rails.logger).to receive(:error).with "#methodical called with invalid key: lookup status"
        expect(subject.description_for_status method: "methodical", lookup_status: "lookup status", lookup_hash: {"lookup unstatus" => "practical"}).to be_blank
      end
    end
  end


  describe "#display_status" do
    before {
      allow(subject).to receive(:status).and_return "status"
      allow(Settings.archive_api).to receive(:status_messages).and_return "lookup hash"
      allow(subject).to receive(:description_for_status).with(method: :display_status, lookup_status: "status", lookup_hash: "lookup hash")
                                                        .and_return "description for status- display status"
    }
    it "calls description_for_status for display_status" do
      expect(subject.display_status).to eq "description for status- display status"
    end
  end


  describe "#request_action" do
    before {
      allow(subject).to receive(:status).and_return "status"
      allow(Settings.archive_api).to receive(:request_actions).and_return "lookup hash"
      allow(subject).to receive(:description_for_status).with(method: :request_action, lookup_status: "status", lookup_hash: "lookup hash")
                                                        .and_return "description for status- request action"
    }
    it "calls description_for_status for request_action" do
      expect(subject.request_action).to eq "description for status- request action"
    end
  end


  describe "#status_in_ui" do
    before {
      allow(subject).to receive(:status).and_return "status"
      allow(Settings.archive_api).to receive(:status_codes_in_ui).and_return "lookup hash"
      allow(subject).to receive(:description_for_status).with(method: :status_code, lookup_status: "status", lookup_hash: "lookup hash")
                                                        .and_return "description for status- status in ui"
    }
    it "calls description_for_status for status_code" do
      expect(subject.status_in_ui).to eq "description for status- status in ui"
    end
  end


  describe "#request_actionable?" do
    request_actions = [{:staging_available => true}, {:staged_without_request => true}, {:local => true}, {:other => false }]

    request_actions.each do |request_action|
      context "when request_status is #{request_action.keys[0]}" do
        before {
          allow(subject).to receive(:status).and_return request_action.keys[0]
        }
        it "returns #{request_action.values[0]}" do
          expect(subject.request_actionable?).to eq request_action.values[0]
        end
      end
    end
  end


  describe "#request_for_staging?" do
    request_stages = [{:staging_available => true}, {:staged_without_request => true}, {:another => false }]

    request_stages.each do |request_stage|
      context "when request_status is #{request_stage.keys[0]}" do
        before {
          allow(subject).to receive(:status).and_return request_stage.keys[0]
        }
        it "returns #{request_stage.values[0]}" do
          expect(subject.request_for_staging?).to eq request_stage.values[0]
        end
      end
    end
  end


  describe "#flash_message" do
    before {
      allow(subject).to receive(:status).and_return "current status"
      allow(Settings.archive_api).to receive(:flash_messages).and_return "flash messages" => true
      allow(subject).to receive(:description_for_status).with(method: :flash_message, lookup_status: "current status",
                                                              lookup_hash: {"flash messages" => true}).and_return "description for flash message"
    }
    it "calls description_for" do
      expect(subject.flash_message).to eq "description for flash message"
    end
  end


  describe "#get!" do
    context "when status is :local" do
      before {
        allow(subject).to receive(:status).and_return :local
        allow(Time).to receive(:now).and_return "Right now!"
        allow(subject).to receive(:create_or_update_job_file!).with(new_params: {latest_user_download: "Right now!"})
        allow(subject).to receive(:local_path).and_return "local path"
        allow(subject).to receive(:local_filename).and_return "local filename"
        allow(subject).to receive(:display_status).with(:local).and_return "current status local"
      }
      it "create_or_update_job_file! and returns hash with file path" do
        expect(subject).to receive(:create_or_update_job_file!).with(new_params: {latest_user_download: "Right now!"})
        expect(subject.get!).to eq status: :local, action: nil, file_path: "local path", filename: "local filename", message: "current status local"
      end
    end

    requested_staging = [:staging_available, :staged_without_request]
    requested_staging.each do |requested_stage|
      context "when status is #{requested_stage}" do
        before {
          allow(subject).to receive(:status).and_return requested_stage
          allow(subject).to receive(:stage_request!).with staging: "phantasmagorical", status: requested_stage
        }
        it "calls stage_request!" do
          expect(subject).to receive(:stage_request!).with staging: "phantasmagorical", status: requested_stage
          expect(subject.get! staging: "phantasmagorical")
        end
      end
    end

    stage_requests = [[:staging_requested, :staging_requested], [:staged_after_request, :staging_requested],
                      [:not_found, :not_found], [:no_response, :no_response], [:unexpected, :unexpected]]
    stage_requests.each do |stage_request|
      context "when status is #{stage_request[0]}" do
        before {
          allow(subject).to receive(:status).and_return stage_request[0]
          allow(subject).to receive(:create_or_update_job_file!).with(new_params: {requests: [compliance: "theoretical", status: stage_request[0]]})
          allow(subject).to receive(:display_status).with(stage_request[1]).and_return "display status"
        }
        it "calls create_or_update_job_file! and returns hash" do
          expect(subject).to receive(:create_or_update_job_file!).with(new_params: {requests: [compliance: "theoretical", status: stage_request[0]]})
          expect(subject).to receive(:display_status).with(stage_request[1])
          expect(subject.get! compliance: "theoretical").to eq status: stage_request[0], action: nil, message: "display status"
        end
      end
    end

    context "when status is unknown" do
      before {
        allow(subject).to receive(:status).and_return "other"
        allow(Rails.logger).to receive(:warn).with "Unexpected archive file status: other"
        allow(subject).to receive(:create_or_update_job_file!).with(new_params: {requests: [submission: "batrachian", status: "other"]})
      }
      it "calls Rails.logger.warn, calls create_or_update_job_file! and returns hash" do
        expect(Rails.logger).to receive(:warn).with "Unexpected archive file status: other"
        expect(subject).to receive(:create_or_update_job_file!).with(new_params: {requests: [submission: "batrachian", status: "other"]})
        expect(subject).not_to receive(:display_status)
        expect(subject.get! submission: "batrachian").to eq status: "other", action: nil, message: "Unknown file status"
      end
    end
  end


  describe "#log_denied_attempt!" do
    before {
      allow(subject).to receive(:create_or_update_job_file!).with(new_params: {denials: [concession: "gibbous"]}, update_only: true)
    }
    it "calls create_or_update_job_file!" do
      expect(subject).to receive(:create_or_update_job_file!).with(new_params: {denials: [concession: "gibbous"]}, update_only: true)
      subject.log_denied_attempt!(request_hash: {concession: "gibbous"})
    end
  end


  describe "#downloaded?" do
    before {
      allow(subject).to receive(:local_path).and_return :locality
      allow(File).to receive(:exist?).with("locality").and_return true
    }
    it "returns result of File.exist?" do
      expect(subject).to receive(:local_path)
      expect(File).to receive(:exist?).with("locality")
      expect(subject.downloaded?).to eq true
    end
  end


  describe "#staged?" do
    staged = [:staged_without_request => true, :staged_after_request => true, :staged_only_in_fiction => false]
    staged.each do |stage|
      context "when archive_status is #{stage.keys.first}" do
        before {
          allow(subject).to receive(:archive_status).and_return stage.keys.first
        }
        it "returns #{stage.values.first}" do
          expect(subject.staged?).to eq stage.values.first
        end
      end
    end
  end


  describe "#unstaged?" do
    unstaged = [:staging_available => true, :staging_requested => true, :staged_in_the_afterlife => false]
    unstaged.each do |unstage|
      context "when archive_status is #{unstage.keys.first}" do
        before {
          allow(subject).to receive(:archive_status).and_return unstage.keys.first
        }
        it "returns #{unstage.values.first}" do
          expect(subject.unstaged?).to eq unstage.values.first
        end
      end
    end
  end


  # private methods

  describe "#local_path" do
    before {
      allow(ArchiveFileWorker).to receive(:jobs_dir).and_return "jobs directory "
      allow(subject).to receive(:local_filename).and_return "local file name"
    }

    context "when jobs directory does not exist" do
      before {
        allow(Dir).to receive(:exists?).with("jobs directory ").and_return false
      }
      it "returns blank" do
        expect(subject.send(:local_path)).to be_blank
      end
    end

    context "when jobs directory exists" do
      before {
        allow(Dir).to receive(:exists?).with("jobs directory ").and_return true
      }

      context "when @local_path instance variable has a value" do
        before {
          subject.instance_variable_set :@local_path, "locality"
        }
        it "returns @local_path" do
          expect(subject.send(:local_path)).to eq "locality"
        end
      end

      context "when @local_path instance variable does not have a value" do
        it "sets @local_path and returns it" do
          expect(subject.send(:local_path)).to eq "jobs directory local file name"
          expect(subject.instance_variable_get(:@local_path)).to eq "jobs directory local file name"
        end
      end
    end
  end


  describe "#local_filename" do
    before {
      allow(Addressable::URI).to receive(:normalized_encode).with("objectify").and_return "objective/objection"
    }

    context "when @local_filename instance variable has a value" do
      before {
        subject.instance_variable_set :@local_filename, "locale finality"
      }
      it "returns @local_filename" do
        expect(Addressable::URI).not_to receive(:normalized_encode)

        expect(subject.send(:local_filename)).to eq "locale finality"
      end
    end

    context "when @local_filename instance variable does not have a value" do
      it "sets @local_filename and returns it" do
        expect(Addressable::URI).to receive(:normalized_encode)
        expect(subject.send(:local_filename)).to eq "objection"
        expect(subject.instance_variable_get :@local_filename).to eq "objection"
      end
    end
  end


  describe "#archive_url" do
    context "when @archive_url has a value" do
      before {
        subject.instance_variable_set :@archive_url, "archival url"
      }
      it "returns @archive_url" do
        expect(Settings.archive_api).not_to receive(:url)
        expect(subject.send(:archive_url)).to eq "archival url"
      end
    end

    context "when @archive_url has no value" do
      before {
        allow(Settings.archive_api).to receive(:url).and_return "%s %s"
      }
      it "calls Settings.archive_api.url, sets @archive_status, and returns the value" do
        expect(Settings.archive_api).to receive(:url)
        expect(subject.send(:archive_url)).to eq "collection objectify"
        expect(subject.instance_variable_get :@archive_url).to eq "collection objectify"
      end
    end
  end


  describe "#request_url" do
    context "when @request_url instance variable has a value" do
      before {
        subject.instance_variable_set :@request_url, "total request url"
      }
      it "returns @request_url" do
        expect(subject.send(:request_url)).to eq "total request url"
      end
    end

    context "when @request_url instance variable does not have a value" do
      it "sets @request_url and returns it" do
        expect(subject.send(:request_url)).to eq "/sda/request/collection/objectify"
        expect(subject.instance_variable_get :@request_url).to eq "/sda/request/collection/objectify"
      end
    end
  end


  describe "#archive_status" do
    context "when status_request is invalid" do
      before {
        allow(subject).to receive(:status_request).and_return MockStatusRequest.new("101")
        allow(Rails.logger).to receive(:warn).with "Unexpected archives server response: 101"
      }

      it "code is :unexpected" do
        expect(Rails.logger).to receive(:warn).with "Unexpected archives server response: 101"
        expect(subject.send(:archive_status)).to eq :unexpected
      end
    end

    skip "Add a test for status_request.try returns blank"

    skip "Add a test for valid ARCHIVE_STATUS_CODES"
  end


  describe "#virtual_status" do
    context "when archive_status is :unstaged" do
      before {
        allow(subject).to receive(:archive_status).and_return :unstaged
      }

      context "when job_status implies forthcoming update" do
        unstaged_job_statuses = [:staging_requested, :staging_available, :staged_without_request]
        unstaged_job_statuses.each do |job_status|
          before {
            allow(subject).to receive(:job_status).and_return job_status
          }
          it "returns :staging_requested" do
            expect(subject.send(:virtual_status)).to eq :staging_requested
          end
        end
      end

      context "when job possibly absent" do
        before {
          allow(subject).to receive(:job_status).and_return :absent
        }
        it "returns :staging_available" do
          expect(subject.send(:virtual_status)).to eq :staging_available
        end
      end
    end

    context "when archive_status is :staged" do
      before {
        allow(subject).to receive(:archive_status).and_return :staged
      }

      context "when job_status implies forthcoming update" do
        staged_job_statuses = [:staging_requested, :staged_after_request, :local, :staged_without_request]
        staged_job_statuses.each do |status|
          before {
            allow(subject).to receive(:job_status).and_return status
          }
          it "returns :staged_after_request" do
            expect(subject.send(:virtual_status)).to eq :staged_after_request
          end
        end
      end

      context "when job possibly absent" do
        before {
          allow(subject).to receive(:job_status).and_return :foreign
        }
        it "returns :staged_without_request" do
          expect(subject.send(:virtual_status)).to eq :staged_without_request
        end
      end
    end

    context "when archive_status is not :staged or :unstaged" do
      before {
        allow(subject).to receive(:archive_status).and_return "unstage-able"
      }
      it "returns archive_status" do
        expect(subject.send(:virtual_status)).to eq "unstage-able"
      end
    end
  end


  describe "#status_request" do
    context "when archive api disabled" do
      before {
        allow(Settings.archive_api).to receive(:disabled).and_return true
      }
      it "returns new VirtualResponse" do
        expect(subject).not_to receive(:archive_request)
        virtual_response = subject.send(:status_request)
        expect(virtual_response[0]).to eq :code => "000"
      end
    end

    context "when archive api enabled" do
      before {
        allow(Settings.archive_api).to receive(:disabled).and_return false
        allow(subject).to receive(:archive_request).and_return "archive request"
      }
      it "calls archive_request" do
        expect(subject).to receive(:archive_request)
        expect(subject.send(:status_request)).to eq "archive request"
      end
    end
  end


  describe "#stage_request!" do
    before {
      allow(subject).to receive(:staged_request_warn)
    }

    context "when block_new_jobs? is true" do
      before {
        allow(subject).to receive(:block_new_jobs?).and_return true
        allow(subject).to receive(:log_denied_attempt!).with(request_hash: {status: 'budgetary constraints', reason: 'block_new_jobs'})
        allow(subject).to receive(:display_status).with(:too_many_requests).and_return "display status too many requests"
      }
      it "calls log_denied_attempt! and returns hash" do
        expect(subject).not_to receive(:create_or_update_job_file!)
        expect(subject).to receive(:log_denied_attempt!).with(request_hash: {status: 'budgetary constraints', reason: 'block_new_jobs'})
        expect(subject.send(:stage_request!, status: 'budgetary constraints')).to eq status: 'budgetary constraints',
           action: :throttled, message: "display status too many requests", alert: true
      end
    end

    context "when block_new_jobs? is false" do
      before {
        allow(subject).to receive(:block_new_jobs?).and_return false
        allow(subject).to receive(:create_or_update_job_file!).with(new_params: {requests: [status: 'going live soon', action: 'create_or_update_job_file!']})
        allow(subject).to receive(:display_status).with(:staging_requested).and_return "display status staging requested"
      }
      it "calls create_or_update_job_file! and returns hash" do
        expect(subject).not_to receive(:log_denied_attempt!)
        expect(subject.send(:stage_request!, status: 'going live soon')).to eq status: 'going live soon',
          action: :create_or_update_job_file!, message: "display status staging requested"
      end
    end

    after {
      expect(subject).to have_received(:staged_request_warn)
    }
  end


  describe "#staged_request_warn" do
    before {
      allow(subject).to receive(:archive_url).and_return "archive url"
      allow(subject).to receive(:status).and_return "statistician"
      allow(Rails.logger).to receive(:warn).with "Staging request for archive url made in status: statistician"
    }

    context "when staged? is true" do
      before {
        allow(subject).to receive(:staged?).and_return true
      }
      it "calls Rails.logger.warn" do
        expect(Rails.logger).to receive(:warn).with "Staging request for archive url made in status: statistician"
        subject.send(:staged_request_warn)
      end
    end

    context "when staged? is false" do
      before {
        allow(subject).to receive(:staged?).and_return false
      }
      it "does not call Rails.logger.warn" do
        expect(Rails.logger).not_to receive(:warn)
        subject.send(:staged_request_warn)
      end
    end
  end


  describe "#job_file_path" do
    before {
      allow(subject).to receive(:local_path).and_return "local.path"
    }

    context "instance variable has a value" do
      before {
        subject.instance_variable_set :@job_file_path, "job file path"
      }
      it "returns value of instance variable" do
        expect(subject).not_to receive(:local_path)

        expect(subject.send(:job_file_path)).to eq "job file path"
      end
    end

    context "instance variable does not have a value" do
      it "sets and returns value of instance variable" do
        expect(subject).to receive(:local_path).and_return "local.path"
        expect(subject.send(:job_file_path)).to eq "local.path.datacore.yml"
        expect(subject.instance_variable_get :@job_file_path).to eq "local.path.datacore.yml"
      end
    end
  end


  describe "#job_status" do
    context "when archive_file_worker returns a value" do
      before {
        allow(subject).to receive(:archive_file_worker).and_return OpenStruct.new(job_status: "job status")
      }
      it "returns job_status" do
        expect(subject.send(:job_status)).to eq "job status"
      end
    end

    context "when archive_file_worker returns nil" do
      before {
        allow(subject).to receive(:archive_file_worker).and_return nil
      }
      it "returns blank" do
        expect(subject.send(:job_status)).to be_blank
      end
    end
  end


  describe "#job_file?" do
    before{
      allow(subject).to receive(:job_file_path).and_return "job_file_path"
    }

    context "when job_file_path file exists" do
      before{
        allow(File).to receive(:exist?).with("job_file_path").and_return true
      }
      it "returns true" do
        expect(subject.send(:job_file?)).to eq true
      end
    end

    context "when job_file_path file does not exist" do
      before{
        allow(File).to receive(:exist?).with("job_file_path").and_return false
      }
      it "returns true" do
        expect(subject.send(:job_file?)).to eq false
      end
    end
  end


  describe "#archive_file_worker" do
    context "when @archive_worker has a value" do
      before {
        subject.instance_variable_set :@archive_worker, "job file path"
      }
      it "returns value of @archive_worker" do
        expect(subject.send(:archive_file_worker)).to eq "job file path"
      end
    end

    context "when @archive_worker has no value" do
      before {
        allow(subject).to receive(:job_file_path).and_return "job file path"
        allow(Rails).to receive(:logger).and_return "Rails logger"
        allow(ArchiveFileWorker).to receive(:new).with("job file path", logger: "Rails logger").and_return "archive file worker"
      }

      context "when job_file? evaluates to false" do
        before {
          allow(subject).to receive(:job_file?).and_return false
        }
        it "returns blank" do
          expect(ArchiveFileWorker).not_to receive(:new)
          expect(subject.send(:archive_file_worker)).to be_blank
        end
      end

      context "when job_file? evaluates to true" do
        before {
          allow(subject).to receive(:job_file?).and_return true
        }
        it "returns result of ArchiveFileWorker.new" do
          expect(ArchiveFileWorker).to receive(:new)
          expect(subject.send(:archive_file_worker)).to eq "archive file worker"
        end
      end
    end
  end


  describe "#default_job_parameters" do
    before {
      allow(subject).to receive(:archive_url).and_return "archive url"
      allow(subject).to receive(:local_filename).and_return "local filename"
      allow(subject).to receive(:local_path).and_return "local path"
      allow(subject).to receive(:status).and_return "status"
      allow(Time).to receive(:now).and_return "no time like the present"
    }
    it "returns hash" do
      expect(subject.send(:default_job_parameters)).to eq url: "archive url", filename: "local filename",
        file_path: "local path", collection: "collection", object: "objectify", status: "status", created_at: "no time like the present"
    end
  end


  describe "#create_or_update_job_file!" do
    mock_file_worker = MockFileWorker.new

    before {
      allow(subject).to receive(:archive_url).and_return "archive url"
      allow(Rails.logger).to receive(:warn).with "Ignoring duplicate call to create default job parameters file for archive url"
      allow(subject).to receive(:archive_file_worker).and_return mock_file_worker
      allow(Time).to receive(:now).and_return "now is the only time"
    }

    context "when job_file? is true" do
      before {
        allow(subject).to receive(:job_file?).and_return true
      }

      context "when called with new parameters" do
        it "updates job file" do
          expect(mock_file_worker).to receive(:update_job_yaml).with(create: "original")
          subject.send(:create_or_update_job_file!, new_params: {create: "original"})
        end
      end

      context "when called without new parameters" do
        it "calls Rails.logger.warn" do
          expect(Rails.logger).to receive(:warn).with "Ignoring duplicate call to create default job parameters file for archive url"
          subject.send(:create_or_update_job_file!)
        end
      end
    end

    context "when job_file? is false" do
      before {
        allow(subject).to receive(:job_file?).and_return false
      }

      context "when update_only parameter is true" do
        it "does not call Rails.logger or File.write" do
          expect(Rails.logger).not_to receive(:warn)
          expect(File).not_to receive(:write)
          subject.send(:create_or_update_job_file!, new_params: {update: "included"}, update_only: true)
        end
      end

      context "when update_only parameter is false" do
        before {
          allow(subject).to receive(:default_job_parameters).and_return default: "job"
          allow(subject).to receive(:job_file_path).and_return "job_file_path"
          allow(File).to receive(:write).with("job_file_path", "---\n:default: job\n:update: included\n:updated_at: now is the only time\n")
        }
        it "calls File.write" do
          expect(subject).to receive(:default_job_parameters)
          expect(File).to receive(:write).with("job_file_path", "---\n:default: job\n:update: included\n:updated_at: now is the only time\n")

          subject.send(:create_or_update_job_file!, new_params: {update: "included"})
        end
      end
    end
  end


  describe "#archive_request" do
    before {
      allow(subject).to receive(:archive_url).and_return "archive url"
      allow(URI).to receive(:parse).with('archive url').and_return OpenStruct.new(request_uri: "uri", hostname: "hostname", port: "port", scheme: "https")
      allow(Settings.archive_api).to receive(:username).and_return "archive api username"
      allow(Settings.archive_api).to receive(:password).and_return "archive api password"
    }

    context "when method parameter not Net::HTTP::Head" do
      before {
        allow(Rails.logger).to receive(:error).with "archive_request called with non-whitelisted method: Net::HTTPVersionNotSupported"
      }
      it "calls Rails.logger.error and returns blank" do
        expect(Net::HTTP::Head).not_to receive(:new).with("uri")
        expect(Rails.logger).to receive(:error).with "archive_request called with non-whitelisted method: Net::HTTPVersionNotSupported"
        expect(subject.send(:archive_request, method: Net::HTTPVersionNotSupported)).to be_blank
      end
    end

    context "when method parameter is Net::HTTP::Head" do
      request_hash = Hash.new
      before {
        allow(Net::HTTP::Head).to receive(:new).with("uri").and_return request_hash
        allow(Net::HTTP).to receive(:start).with("hostname", "port", use_ssl: true).and_return "the results"
      }
      it "makes archives http request" do
        expect(Net::HTTP::Head).to receive(:new).with("uri").and_return request_hash
        expect(Net::HTTP).to receive(:start).with("hostname", "port", use_ssl: true)
        expect(subject.send(:archive_request, method: Net::HTTP::Head)).to eq "the results"
      end

      skip "Add a test for http.request"

      context "Add a test for connection error" do
        before {
          allow(Net::HTTP::Head).to receive(:new).with("uri").and_return Hash.new
          allow(Net::HTTP).to receive(:start).and_raise("Error Message...")
        }
        it "catches error" do
          expect(Rails.logger).to receive(:error).with "Error connecting to archives archive url: Error Message..."

          expect(subject.send(:archive_request)).to be_blank
        end
      end
    end
  end
end
