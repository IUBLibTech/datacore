# frozen_string_literal: true

require 'rails_helper'

describe Datacore::DoiMintingService do
  let(:current_user) { 'user@example.com' }
  # define doi per context
  let(:work) { FactoryBot.create(:data_set, doi: doi) }
  let(:service) { Datacore::DoiMintingService.new(current_user: current_user, work: work) }
  let(:namespaced_doi) { 'doi:10.82028/18sn-h641' }
  let(:url_doi) { 'https://doi.org/10.82028/18sn-h641' }
  let(:raw_doi) { '10.82028/18sn-h641' }
  let(:pending_doi) { Deepblue::DoiBehavior::DOI_PENDING }
  before do
    allow(Datacore::DoiMintingService).to receive(:enabled?).and_return(true)
    allow(service).to receive(:mint_doi!).and_raise(StandardError) # prevent client interactions
  end

  describe "#id" do
    context "with a nil DOI" do
      let(:doi) { nil }
      it "returns a blank string" do
        expect(service.id).to eq ''
      end
    end
    context "with a namespaced DOI" do
      let(:doi) { namespaced_doi }
      it "returns the raw DOI value" do
        expect(service.id).to eq raw_doi
      end
    end
    context "with a URL DOI" do
      let(:doi) { url_doi }
      it "returns the raw DOI value" do
        expect(service.id).to eq raw_doi
      end
    end
    context "with a raw DOI" do
      let(:doi) { raw_doi }
      it "returns the same value" do
        expect(service.id).to eq doi
      end
    end
  end

  describe "#run" do
    context "on a work with a minted DOI" do
      let(:doi) { namespaced_doi }
      it "returns false" do
        expect(service).not_to receive(:mint_doi!)
        expect(service).not_to receive(:update_work_with_doi!)
        expect(service.run).to eq false
      end
    end
    context "on a work with a nil DOI" do
      let(:doi) { nil }
      it "returns false" do
        expect(service).not_to receive(:mint_doi!)
        expect(service).not_to receive(:update_work_with_doi!)
        expect(service.run).to eq false
      end
    end
    context "on a work with a pending DOI" do
      let(:doi) { pending_doi }
      context "but invalid metadata" do
        before do
          work.creator = []
          work.save(validate: false)
          allow(service).to receive(:mint_doi!).and_return(nil) # prevent client interactions
        end
        it "returns false" do
          expect(service).not_to receive(:mint_doi!)
          expect(service).not_to receive(:update_work_with_doi!)
          expect(service.run).to eq false
        end
      end
      context "with successful minting" do
        before do
          allow(service).to receive(:mint_doi!).and_return(namespaced_doi) # stub client interaction
        end
        it "successfully calls mint_doi!" do
          expect(service).to receive(:mint_doi!)
          expect(service.run).to eq namespaced_doi
        end
        it "updates the work doi value" do
          expect(work.doi).to eq Deepblue::DoiBehavior::DOI_PENDING
          service.run
          expect(work.doi).to eq namespaced_doi
        end
      end
      context "with failed minting" do
        before do
          allow(service).to receive(:mint_doi!).and_return(nil) # stub client interaction
        end
        it "returns nil!" do
          expect(service).to receive(:mint_doi!)
          expect(service).to receive(:update_work_with_doi!)
          expect(service.run).to be_nil
        end
        it "resets the work doi value to nil" do
          expect(work.doi).to eq pending_doi
          service.run
          expect(work.doi).to be_nil
        end
      end
    end
  end
end
