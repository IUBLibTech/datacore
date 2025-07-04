# frozen_string_literal: true

require 'rails_helper'

describe Datacore::DoiMintingService do
  let(:current_user) { 'user@example.com' }
  # define work per context
  let(:service) { Datacore::DoiMintingService.new(current_user: current_user, work: work) }
  let(:doi) { '10.82028/18sn-h641' }
  before do
    allow(Datacore::DoiMintingService).to receive(:enabled?).and_return(true)
  end

  describe "#run" do
    context "on a work with a minted DOI" do
      let(:work) { FactoryBot.create(:data_set, creator: ['creator1'], rights_license: 'foo', doi: doi) }
      before do
        allow(service).to receive(:mint_doi!).and_raise(StandardError) # prevent client interactions
      end
      it "returns nil" do
        expect(service).not_to receive(:mint_doi!)
        expect(service.run).to be_nil
      end
    end
    context "on a work with a nil DOI" do
      let(:work) { FactoryBot.create(:data_set, creator: ['creator1'], rights_license: 'foo', doi: nil) }
      before do
        allow(service).to receive(:mint_doi!).and_raise(StandardError) # prevent client interactions
      end
      it "returns nil" do
        expect(service).not_to receive(:mint_doi!)
        expect(service.run).to be_nil
      end
    end
    context "on a work with a pending DOI" do
      let(:work) { FactoryBot.create(:data_set, creator: ['creator1'], rights_license: 'foo', doi: Deepblue::DoiBehavior::DOI_PENDING) }
      before do
        allow(service).to receive(:mint_doi!).and_return(doi) # stub client interactions
      end
      it "successfully calls mint_doi!" do
        expect(service).to receive(:mint_doi!)
        expect(service.run).to eq doi
      end
      it "updates the work doi value" do
        expect(work.doi).to eq Deepblue::DoiBehavior::DOI_PENDING
        service.run
        expect(work.doi).to eq doi
      end
    end
  end
end
