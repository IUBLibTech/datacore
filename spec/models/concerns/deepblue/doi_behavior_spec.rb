require 'rails_helper'

class BehaviorMock
  include ::Deepblue::DoiBehavior

  def doi
    nil
  end
end

class BehaviorDoiMock
  include ::Deepblue::DoiBehavior

  def doi
    "doi_pending"
  end
end

RSpec.describe Deepblue::DoiBehavior do

  describe 'constants' do
    it do
      expect( Deepblue::DoiBehavior::DOI_MINTING_ENABLED ).to eq true
      expect( Deepblue::DoiBehavior::DOI_PENDING ).to eq 'doi_pending'
      expect( Deepblue::DoiBehavior::DOI_MINIMUM_FILE_COUNT ).to eq 1
    end
  end

  describe "#doi_minted?" do
    context "doi is minted" do
      subject { BehaviorDoiMock.new }

      it "returns true" do
        expect(subject.doi_minted?).to eq true
      end
    end

    context "doi is not minted" do
      subject { BehaviorMock.new }

      it "returns false" do
        expect(subject.doi_minted?).to eq false
      end
    end
  end


  describe "#doi_minting_enabled?" do
    subject { BehaviorMock.new }

    it "returns true" do
      expect(subject.doi_minting_enabled?).to eq true
    end
  end

  describe "#doi_pending?" do
    context "doi is pending" do
      subject { BehaviorDoiMock.new }

      it "returns true" do
        expect(subject.doi_pending?).to eq true
      end
    end

    context "doi is not pending" do
      subject { BehaviorMock.new }

      it "returns false" do
        expect(subject.doi_pending?).to eq false
      end
    end
  end


  pending "#doi_mint"

end
