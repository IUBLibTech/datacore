require 'rails_helper'

class MockActor
  def revert_content(params)
  end

  def update_content(params)
  end

  def update_metadata(params)
  end
end



RSpec.describe Hyrax::FileSetsController, type: :controller do

  describe 'constants' do
    it do
      expect( Hyrax::FileSetsController::PARAMS_KEY ).to eq 'file_set'
    end
  end

  describe "#self.show_presenter" do
    it do
      expect( Hyrax::FileSetsController.show_presenter ).instance_of? Hyrax::DsFileSetPresenter
    end
  end


  before {
    allow(subject).to receive(:current_user).and_return "user1"
  }

  describe 'provenance_log_create' do
    before {
      allow(subject.curation_concern).to receive(:provenance_create).with(current_user: "user1", event_note: 'FileSetsController')
    }
    it "calls curation_concern.provenance_create" do
      expect(subject.curation_concern).to receive(:provenance_create).with(current_user: "user1", event_note: 'FileSetsController')
      subject.provenance_log_create
    end
  end

  describe 'provenance_log_destroy' do
    before {
      allow(subject.curation_concern).to receive(:provenance_destroy).with(current_user: "user1", event_note: 'FileSetsController')
    }
    it "calls curation_concern.provenance_destroy" do
      expect(subject.curation_concern).to receive(:provenance_destroy).with(current_user: "user1", event_note: 'FileSetsController')
      subject.provenance_log_destroy
    end
  end

  describe 'provenance_log_update_after' do
    before {
      subject.instance_variable_set(:@update_attr_key_values, "after key values")

      allow(subject.curation_concern).to receive(:provenance_log_update_after).with(current_user: "user1", update_attr_key_values: "after key values")
    }
    it "calls curation_concern.provenance_log_update_after" do
      expect(subject.curation_concern).to receive(:provenance_log_update_after).with(current_user: "user1", update_attr_key_values: "after key values")
      subject.provenance_log_update_after
    end
  end

  describe 'provenance_log_update_before' do
    before {
      allow(subject).to receive(:params).and_return "file_set" => "form params file set"
      allow(subject.curation_concern).to receive(:provenance_log_update_before).with( form_params: "form params file set" )
                                                                              .and_return "provenance log update before"
    }
    it "sets instance variable to curation_concern.provenance_log_update_before" do
      expect(subject.curation_concern).to receive(:provenance_log_update_before)

      expect(subject.provenance_log_update_before).to eq "provenance log update before"
      subject.instance_variable_get(:@update_attr_key_values) == "provenance log update before"
    end
  end


  describe "display_provenance_log" do
    curation = OpenStruct.new(id: 300)
    main = "main app"

    before {
      allow(subject).to receive(:curation_concern).and_return curation
      allow(subject).to receive(:main_app).and_return main

      allow(Deepblue::ProvenancePath).to receive(:path_for_reference).with( 300 ).and_return "file path"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["DataSetsController", "display_provenance_log", "file path"]
      allow(Deepblue::ProvenanceLogService).to receive(:entries).with 300, refresh: true

      allow(subject).to receive(:redirect_to).with [main, curation]
    }
    it "calls Deepblue methods and then redirects" do
      expect(subject).to receive(:redirect_to).with [main, curation]

      subject.display_provenance_log
    end
  end


  describe "display_provenance_log_enabled?" do
    it "returns true" do
      expect(subject.display_provenance_log_enabled?).to eq true
    end
  end


  describe "provenance_log_entries_present?" do
    context "provenance_log_entries has a value" do
      it "returns true" do
        skip "Add a test"
      end
    end

    context "provenance_log_entries does not have a value" do
      it "returns false" do
        skip "Add a test"
      end
    end
  end


  # protected methods

  describe "#attempt_update" do
    thespian = MockActor.new
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(subject).to receive(:current_user).and_return "Current User"
      allow(subject).to receive(:actor).and_return thespian
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with("actor", thespian).and_return "castmember"
    }

    context "if wants_to_revert? is true" do
      before {
        allow(subject).to receive(:wants_to_revert?).and_return true

        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "current_user=Current User", "castmember", "wants to revert"]
        allow(subject).to receive(:params).and_return :revision => "revised"
      }
      it "calls revert_content" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "current_user=Current User", "castmember", "wants to revert"]
        expect(thespian).to receive(:revert_content).with "revised"

        subject.send(:attempt_update)
      end
    end

    context "if wants_to_revert? is false" do
      before {
        allow(subject).to receive(:wants_to_revert?).and_return false
      }
      context "if params has file_set" do
        before{
          allow(subject).to receive(:params).and_return :file_set => {:files => ["files"]}
          allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "current_user=Current User", "castmember", "actor.update_content"]
        }

        it "calls update_content" do
          expect(subject).to receive(:params).and_return :file_set => {:files => ["files"]}

          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "current_user=Current User", "castmember", "actor.update_content"]
          expect(thespian).to receive(:update_content).with "files"
          subject.send(:attempt_update)
        end
      end

      context "if params does not have file_set" do
        before {
          allow(subject).to receive(:params).and_return :file_set => {:unknown => ["unknowable"]}
          allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "current_user=Current User", "update_metadata"]
          allow(subject).to receive(:update_metadata)
        }

        it "calls update_metadata" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "current_user=Current User", "update_metadata"]
          expect(subject).to receive(:update_metadata)
          subject.send(:attempt_update)
        end
      end
    end
  end

end
