require 'rails_helper'

class MockRunner

  def run
  end

  def deleted_ids
    ["456", "789"]
  end

  def deleted_id_to_key_values_map
    "00-XXX"
  end
end

class MockPathname
  def initialize(path)
    @path = path
  end

  def join(string)
    "#{@path}#{string}"
  end

  def to_s
    @path.to_s
  end
end

class MockZipfile
  def add(name1, name2)
  end
end

RSpec.describe ProvenanceLogController, type: :controller do

  before {
    allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
    allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
  }


  describe "presenter_class" do
    it do
      expect(ProvenanceLogController.presenter_class).to eq ProvenanceLogPresenter
    end
  end


  describe "#show" do
    context "when current_ability.admin is false" do
      before {
        allow(subject).to receive(:current_ability).and_return OpenStruct.new(admin?: false)
      }
      it "raises CanCan::AccessDenied exception" do
        expect(subject.show).to_raise(CanCan::AccessDenied)

        rescue CanCan::AccessDenied
          # raises Exception
      end
    end

    context "when current_ability.admin is true" do
      before {
        allow(subject).to receive(:current_ability).and_return OpenStruct.new(admin?: true)
        allow(subject).to receive(:params).and_return :id => "123"
        allow(subject).to receive(:id_check)
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "id=123", "" ]
        allow(subject).to receive(:provenance_log_entries_refresh).with(id: "123")
        allow(ProvenanceLogPresenter).to receive(:new).with(controller: anything).and_return "Provenance Log Presenter"
        allow(subject).to receive(:render).with "provenance_log/provenance_log"
      }

      context "when id_valid? returns true" do
        before {
          allow(subject).to receive(:id_valid?).and_return true
        }
        it "calls provenance_log_entries_refresh" do
          expect(subject).to receive(:provenance_log_entries_refresh).with(id: "123")
          expect(ProvenanceLogPresenter).to receive(:new).with(controller: anything)
          subject.show
        end
      end

      context "when id_deleted returns true" do
        before {
          allow(subject).to receive(:id_valid?).and_return false
          allow(subject).to receive(:id_deleted).and_return true
        }
        it "calls provenance_log_entries_refresh" do
          expect(subject).to receive(:provenance_log_entries_refresh).with(id: "123")
          expect(ProvenanceLogPresenter).to receive(:new).with(controller: anything)
          subject.show
        end
      end

      context "when id_valid? and id_deleted return false" do
        before {
          allow(subject).to receive(:id_valid?).and_return false
          allow(subject).to receive(:id_deleted).and_return false
        }
        it "does NOT call provenance_log_entries_refresh" do
          expect(subject).not_to receive(:provenance_log_entries_refresh)
          expect(ProvenanceLogPresenter).to receive(:new).with(controller: anything)
          subject.show
        end
      end

      after {
        expect(subject).to have_received(:id_check)
        expect(Deepblue::LoggingHelper).to have_received(:bold_debug).with [ "here", "called from", "id=123", "" ]
        expect(subject).to have_received(:render).with "provenance_log/provenance_log"

        expect(subject.instance_variable_get(:@id)).to eq "123"
        expect(subject.instance_variable_get(:@id_deleted)).to eq false
        expect(subject.instance_variable_get(:@id_invalid)).to eq false
        expect(subject.instance_variable_get(:@id_msg)).to eq ""
        expect(subject.instance_variable_get(:@presenter)).to eq "Provenance Log Presenter"
      }
    end
  end


  describe "#id_check" do
    context "when id is blank" do
      before {
        allow(subject).to receive(:id).and_return ""
      }
      it "returns nil" do
        expect(subject.id_check).to be_nil
      end
    end

    context "when id is NOT blank" do
      before {
        allow(subject).to receive(:id).and_return "ID"
        allow(ActiveFedora::Base).to receive(:find).with("ID").and_return "found"
      }
      it "calls Base.Find" do
        expect(subject.id_check).to eq "found"
      end
    end

    context "when Ldp::Gone error occurs" do
      before {
        allow(subject).to receive(:id).and_return "ID"
        allow(ActiveFedora::Base).to receive(:find).with("ID").and_raise(Ldp::Gone)
      }
      it "sets instance variables to deleted values" do
        subject.id_check

        expect(subject.instance_variable_get(:@id_msg)).to eq "deleted"
        expect(subject.instance_variable_get(:@id_deleted)).to eq true
        expect(subject.instance_variable_get(:@id_invalid)).to be_nil
      end
    end

    context "when ActiveFedora::ObjectNotFoundError occurs" do
      before {
        allow(subject).to receive(:id).and_return "ID"
        allow(ActiveFedora::Base).to receive(:find).with("ID").and_raise(ActiveFedora::ObjectNotFoundError)
      }
      it "sets instance variables to invalid values" do
        subject.id_check

        expect(subject.instance_variable_get(:@id_msg)).to eq "invalid"
        expect(subject.instance_variable_get(:@id_invalid)).to eq true
        expect(subject.instance_variable_get(:@id_deleted)).to be_nil
      end
    end
  end


  describe "#id_valid?" do

    context "when id is blank" do
      before {
        allow(subject).to receive(:id).and_return ""
      }
      it "returns false" do
        expect(subject.id_valid?).to eq false
      end
    end

    context "when id is NOT blank" do
      before {
        allow(subject).to receive(:id).and_return "id"
      }

      context "when id is deleted" do
        before {
          allow(subject).to receive(:id_deleted).and_return true
        }
        it "returns false" do
          expect(subject.id_valid?).to eq false
        end
      end

      context "when id is invalid" do
        before {
          allow(subject).to receive(:id_deleted).and_return false
          allow(subject).to receive(:id_invalid).and_return true
        }
        it "returns false" do
          expect(subject.id_valid?).to eq false
        end
      end

      context "when id is not deleted or invalid" do
        before {
          allow(subject).to receive(:id_deleted).and_return false
          allow(subject).to receive(:id_invalid).and_return false
        }
        it "returns true" do
          expect(subject.id_valid?).to eq true
        end
      end
    end

  end


  describe "#log_zip_download" do
    context "when current_ability admin field is false" do
      before {
        allow(subject).to receive(:current_ability).and_return OpenStruct.new(admin?: false)
      }

      it "raises CanCan::AccessDenied error" do
        subject.log_zip_download

        rescue CanCan::AccessDenied
          # raises Exception
      end
    end

    context "when current_ability admin field is true" do
      pathname_obj = MockPathname.new("pathname tmp")
      pathname_log = MockPathname.new("provenance log")
      zipfile = MockZipfile.new

      before {
        allow(subject).to receive(:current_ability).and_return OpenStruct.new(admin?: true)
        # could not stub Settings.tmpdir - returns /tmp
        allow(Pathname).to receive(:new).with("/tmp").and_return pathname_obj
        allow(Dir).to receive(:exist?).with(pathname_obj).and_return false
        allow(Dir).to receive(:mkdir).with(pathname_obj)
        allow(Rails).to receive(:env).and_return "rails_dev"

        allow(Rails.root).to receive(:join).with("log", "provenance_rails_dev.log").and_return "provenance log"
        allow(Pathname).to receive(:new).with("provenance log").and_return pathname_log
        allow(File).to receive(:exist?).and_return true
        allow(File).to receive(:delete).with("pathname tmpprovenance_rails_dev.log.zip")

        allow(Zip::File).to receive(:open).with( "pathname tmpprovenance_rails_dev.log.zip", Zip::File::CREATE).and_yield zipfile
        allow(subject).to receive(:send_file).with( "pathname tmpprovenance_rails_dev.log.zip")
      }

      it "logs the zip log download" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "" ]
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "zip_log_download begin", "tmp_dir=pathname tmp"]
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "zip_log_download", "target_dir=pathname tmp"]
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "zip_log_download", "target_zipfile=pathname tmpprovenance_rails_dev.log.zip" ]
        expect(File).to receive(:delete).with("pathname tmpprovenance_rails_dev.log.zip")

        expect(Deepblue::LoggingHelper).to receive(:debug).with "Download Zip begin copy to folder pathname tmp"
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "zip_log_download", "begin zip of src_file_name=provenance log" ]
        expect(Zip::File).to receive(:open).with( "pathname tmpprovenance_rails_dev.log.zip", Zip::File::CREATE)
        expect(zipfile).to receive(:add).with("provenance_rails_dev.log", pathname_log)
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "zip_log_download", "download complete target_dir=pathname tmp" ]
        expect(subject).to receive(:send_file).with("pathname tmpprovenance_rails_dev.log.zip")

        subject.log_zip_download
      end
    end

    skip "Add a test where Settings.tmpdir is nil"
  end


  describe "#find" do
    context "when current_ability admin field is false" do
      before {
        allow(subject).to receive(:current_ability).and_return OpenStruct.new(admin?: false)
      }

      it "raises CanCan::AccessDenied error" do
        subject.find

      rescue CanCan::AccessDenied
        # raises Exception
      end
    end

    context "when current_ability.admin is true" do
      before {
        allow(subject).to receive(:current_ability).and_return OpenStruct.new(admin?: true)
        allow(subject).to receive(:params).and_return :find_id => "123"
        allow(subject).to receive(:id_check)
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "find_id=123", "id=123", "" ]
        allow(subject).to receive(:provenance_log_entries_refresh).with(id: "123")
        allow(ProvenanceLogPresenter).to receive(:new).with(controller: anything).and_return "Provenance Log Presenter"
        allow(subject).to receive(:render).with "provenance_log/provenance_log"
      }

      context "when id_valid? returns true" do
        before {
          allow(subject).to receive(:id_valid?).and_return true
        }
        it "calls provenance_log_entries_refresh" do
          expect(subject).to receive(:provenance_log_entries_refresh).with(id: "123")
          expect(ProvenanceLogPresenter).to receive(:new).with(controller: anything)
          subject.find
        end
      end

      context "when id_deleted returns true" do
        before {
          allow(subject).to receive(:id_valid?).and_return false
          allow(subject).to receive(:id_deleted).and_return true
        }
        it "calls provenance_log_entries_refresh" do
          expect(subject).to receive(:provenance_log_entries_refresh).with(id: "123")
          expect(ProvenanceLogPresenter).to receive(:new).with(controller: anything)
          subject.find
        end
      end

      context "when id_valid? and id_deleted return false" do
        before {
          allow(subject).to receive(:id_valid?).and_return false
          allow(subject).to receive(:id_deleted).and_return false
        }
        it "does NOT call provenance_log_entries_refresh" do
          expect(subject).not_to receive(:provenance_log_entries_refresh)
          expect(ProvenanceLogPresenter).to receive(:new).with(controller: anything)
          subject.find
        end
      end

      after {
        expect(subject).to have_received(:id_check)
        expect(Deepblue::LoggingHelper).to have_received(:bold_debug).with [ "here", "called from", "find_id=123","id=123", "" ]
        expect(subject).to have_received(:render).with "provenance_log/provenance_log"

        expect(subject.instance_variable_get(:@id)).to eq "123"
        expect(subject.instance_variable_get(:@id_deleted)).to eq false
        expect(subject.instance_variable_get(:@id_invalid)).to eq false
        expect(subject.instance_variable_get(:@id_msg)).to eq ""
        expect(subject.instance_variable_get(:@presenter)).to eq "Provenance Log Presenter"
      }
    end
  end


  describe "#deleted_works" do
    context "when current_ability admin field is false" do
      before {
        allow(subject).to receive(:current_ability).and_return OpenStruct.new(admin?: false)
      }

      it "raises CanCan::AccessDenied error" do
        subject.deleted_works

      rescue CanCan::AccessDenied
        # raises Exception
      end
    end

    context "when current_ability admin field is true" do
      runner = MockRunner.new
      before {
        allow(subject).to receive(:current_ability).and_return OpenStruct.new(admin?: true)
        allow(Deepblue::ProvenanceLogService).to receive(:provenance_log_path).and_return "prov log path"
        allow(Deepblue::DeletedWorksFromLog).to receive(:new).with( input: "prov log path").and_return runner
        allow(ProvenanceLogPresenter).to receive(:new).with(controller: anything).and_return "Provenance Log Presenter"
        allow(subject).to receive(:render).with "provenance_log/provenance_log"
      }

      it "run Deepblue::DeletedWorksFromLog and set instance variables" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "" ]
        expect(runner).to receive(:run)
        expect(ProvenanceLogPresenter).to receive(:new).with(controller: anything)
        expect(subject).to receive(:render).with "provenance_log/provenance_log"

        subject.deleted_works

        expect(subject.instance_variable_get(:@deleted_ids)).to eq ["456", "789"]
        expect(subject.instance_variable_get(:@deleted_id_to_key_values_map)).to eq "00-XXX"
        expect(subject.instance_variable_get(:@presenter)).to eq "Provenance Log Presenter"
      end
    end
  end

end