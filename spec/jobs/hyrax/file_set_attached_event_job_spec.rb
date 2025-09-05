require 'rails_helper'


RSpec.describe FileSetAttachedEventJob do

  pending "#log_event"


  describe '#action' do
    before {
      allow(subject).to receive(:link_to_profile).and_return "profilelink"
      allow(subject).to receive(:file_link).and_return "filelink"
      allow(subject).to receive(:work_link).and_return "worklink"
      # depositor is abstract since FileSetAttachedEventJob doesn't overwrite it.
    }
    it "returns string" do
      expect(subject.action).to eq "User profilelink has attached filelink to worklink"
    end
  end


  # private methods

  pending "#file_link"

  pending "#work_link"


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
