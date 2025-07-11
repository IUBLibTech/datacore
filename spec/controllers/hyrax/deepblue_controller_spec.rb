require 'rails_helper'

RSpec.describe Hyrax::DeepblueController do

  describe "#box_enabled?" do
    it "returns false" do
      expect(subject.box_enabled?).to eq false
    end
  end

  describe "#display_provenance_log_enabled?" do
    it "returns false" do
      expect(subject.display_provenance_log_enabled?).to eq false
    end
  end

  describe "#doi_minting_enabled?" do
    it "returns service value (#{Datacore::DoiMintingService.enabled?}" do
      expect(subject.doi_minting_enabled?).to eq Datacore::DoiMintingService.enabled?
    end
  end

  describe "#globus_download_enabled?" do
    it "returns false" do
      expect(subject.globus_download_enabled?).to eq false
    end
  end

  describe "#tombstone_enabled?" do
    it "returns false" do
      expect(subject.tombstone_enabled?).to eq false
    end
  end

  describe "#zip_download_enabled?" do
    it "returns false" do
      expect(subject.zip_download_enabled?).to eq false
    end
  end

end
