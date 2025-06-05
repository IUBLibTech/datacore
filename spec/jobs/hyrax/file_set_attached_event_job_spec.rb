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

end
