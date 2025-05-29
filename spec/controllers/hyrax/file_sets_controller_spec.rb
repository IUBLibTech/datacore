require 'rails_helper'

RSpec.describe Hyrax::FileSetsController do

  describe 'constants' do
    it do
      expect( Hyrax::FileSetsController::PARAMS_KEY ).to eq 'file_set'
    end
  end

  before {
    allow(subject).to receive(:current_user).and_return "user1"
  }

  describe 'provenance_log_create' do
    before {
      allow(subject.curation_concern).to receive(:provenance_create).with(current_user: "user1", event_note: 'FileSetsController')
                                                                    .and_return "provenance log creation"
    }
    it "calls curation_concern.provenance_create" do
      expect(subject.curation_concern).to receive(:provenance_create).with(current_user: "user1", event_note: 'FileSetsController')
      expect(subject.provenance_log_create).to eq "provenance log creation"
    end
  end

  describe 'provenance_log_destroy' do
    before {
      allow(subject.curation_concern).to receive(:provenance_destroy).with(current_user: "user1", event_note: 'FileSetsController')
                                                                    .and_return "provenance log destruction"
    }
    it "calls curation_concern.provenance_destroy" do
      expect(subject.curation_concern).to receive(:provenance_destroy).with(current_user: "user1", event_note: 'FileSetsController')
      expect(subject.provenance_log_destroy).to eq "provenance log destruction"
    end
  end

  describe 'provenance_log_update_after' do
    before {
      subject.instance_variable_set(:@update_attr_key_values, "after key values")

      allow(subject.curation_concern).to receive(:provenance_log_update_after).with(current_user: "user1", update_attr_key_values: "after key values")
                                                                     .and_return "provenance log update after"
    }
    it "calls curation_concern.provenance_log_update_after" do
      expect(subject.curation_concern).to receive(:provenance_log_update_after).with(current_user: "user1", update_attr_key_values: "after key values")
      expect(subject.provenance_log_update_after).to eq "provenance log update after"
    end
  end

  describe 'provenance_log_update_before' do
    # NOTE:  could not resolve params[PARAMS_KEY].dup
    before {
      allow(subject.curation_concern).to receive(:provenance_log_update_before).with( anything )
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
end
