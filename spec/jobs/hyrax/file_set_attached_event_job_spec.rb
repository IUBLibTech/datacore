require 'rails_helper'

class MockRepoObject
  def log_event(event)
  end
end

class MockCuratingConcern
  def log_event(event)
  end
end




RSpec.describe FileSetAttachedEventJob do
  # depositor is abstract since FileSetAttachedEventJob doesn't overwrite it.

  describe "#log_event" do
    mock_repo = MockRepoObject.new
    mock_curating_concern = MockCuratingConcern.new
    before {
      allow(subject).to receive(:event).and_return "event"
      allow(subject).to receive(:curation_concern).and_return mock_curating_concern
    }
    it "calls parameter repo_object log_event and curation_concern log_event" do
      expect(mock_repo).to receive(:log_event).with("event")
      expect(subject).to receive(:curation_concern)
      expect(mock_curating_concern).to receive(:log_event).with("event")

      subject.log_event(mock_repo)
    end

    skip "Add a test for Deepblue::EventHelper.after_create_fileset_callback"
  end


  describe '#action' do
    before {
      allow(subject).to receive(:link_to_profile).and_return "profilelink"
      allow(subject).to receive(:file_link).and_return "filelink"
      allow(subject).to receive(:work_link).and_return "worklink"
    }
    it "returns string" do
      expect(subject.action).to eq "User profilelink has attached filelink to worklink"
    end
  end


  # private methods

  describe "#file_link" do
    before {
      allow(subject).to receive(:file_title).and_return("file title")
      allow(subject).to receive(:repo_object).and_return "repo object"
      allow(subject).to receive(:polymorphic_path).with("repo object").and_return "polymorphic path"
      allow(subject).to receive(:link_to).with("file title", "polymorphic path").and_return "file link result"
    }
    it "returns link" do
      expect(subject.send(:file_link)).to eq "file link result"
    end
  end


  describe "#work_link" do
    before {
      allow(subject).to receive(:work_title).and_return("work title")
      allow(subject).to receive(:curation_concern).and_return "curation concern"
      allow(subject).to receive(:polymorphic_path).with("curation concern").and_return "polymorphic path"
      allow(subject).to receive(:link_to).with("work title", "polymorphic path").and_return "work link result"
    }
    it "returns link" do
      expect(subject.send(:work_link)).to eq "work link result"
    end
  end


  describe "#file_title" do
    before {
      allow(subject).to receive(:repo_object).and_return OpenStruct.new(title: ["First Title", "Second Title"])
    }
    it "returns first title of repo object" do
      expect(subject.send(:file_title)).to eq "First Title"
    end
  end


  describe "#work_title" do
    before {
      allow(subject).to receive(:curation_concern).and_return OpenStruct.new(title: ["Title One", "Title Two"])
    }
    it "returns first title of curation_concern" do
      expect(subject.send(:work_title)).to eq "Title One"
    end
  end


  describe "#curation_concern" do
    before {
      allow(subject).to receive(:repo_object).and_return OpenStruct.new(in_works: ["First Work", "Second Work"])
    }
    it "returns first work in repo_object" do
      expect(subject.send(:curation_concern)).to eq "First Work"
    end
  end

end
