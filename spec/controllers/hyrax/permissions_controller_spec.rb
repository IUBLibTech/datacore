require 'rails_helper'

class MockCurationConcern
  def embargo_release_date()
    "embargo release date"
  end
end



RSpec.describe Hyrax::PermissionsController, type: :controller do
  before {
    allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
    allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
    allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", ""]
  }

  describe '#confirm' do
    before {
      allow(subject).to receive(:curation_concern).and_return MockCurationConcern.new
      allow(subject).to receive(:copy)
    }

    context "embargo_allow_children_unembargo_choice is false" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:embargo_allow_children_unembargo_choice).and_return false
      }
      it "calls copy" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", ""]
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "curation_concern.embargo_release_date=embargo release date", ""]

        expect(subject).to receive(:copy)
        subject.confirm
      end
    end

    context "embargo_allow_children_unembargo_choice is true" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:embargo_allow_children_unembargo_choice).and_return true
      }
      it "does NOT call copy" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", ""]
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "curation_concern.embargo_release_date=embargo release date", ""]

        expect(subject).not_to receive(:copy)
        subject.confirm
      end
    end
  end


  describe "#copy" do
    skip "Add a test"
  end


  describe "#confirm_access" do
    it "calls LoggingHelper.bold_debug" do
      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", ""]
      subject.confirm_access
    end
  end


  describe "#copy_access" do
    skip "Add a test"
  end


  describe "#curation_concern" do
    context "instance variable has a value" do
      before {
        subject.instance_variable_set(:@curation_concern, "curation of concern")
      }
      it "gets instance variable" do
        expect(subject.curation_concern).to eq "curation of concern"
      end
    end

    context "instance variable does not have a value" do
      before {
        allow(subject).to receive(:params).and_return :id => "found"
        allow(ActiveFedora::Base).to receive(:find).with("found").and_return "concern curator"
      }
      it "calls Base.Find and sets instance variable" do
        expect(subject.curation_concern).to eq "concern curator"

        subject.instance_variable_get(:@curation_concern) == "concern curator"
      end
    end
  end
end
