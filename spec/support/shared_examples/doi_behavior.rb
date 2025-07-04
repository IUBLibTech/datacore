RSpec.shared_examples "DeepBlue::DoiBehavior" do |object_factory|
  let(:minted_doi) { 'doi:10.82028/18sn-h641' }
  let(:pending_doi) { Deepblue::DoiBehavior::DOI_PENDING }
  let(:minted_work) { FactoryBot.create(object_factory, doi: minted_doi) }
  let(:pending_work) { FactoryBot.create(object_factory, doi: pending_doi) }
  let(:unminted_work) { FactoryBot.create(object_factory, doi: nil) }
  let(:file_set) { FactoryBot.create(:file_set) }

  describe "#doi_minted?" do
    let(:work) { unminted_work }
    context "with a nil doi" do
      it "returns false" do
        expect(work.doi).to be_nil
        expect(work.doi_minted?).to eq false
      end
    end
    context "with a pending doi" do
    let(:work) { pending_work }
      it "returns false" do
        expect(work.doi).to eq pending_doi
        expect(work.doi_minted?).to eq false
      end
    end
    context "with a doi" do
      let(:work) { minted_work }
      it "returns true" do
        expect(work.doi).to eq minted_doi
        expect(work.doi_minted?).to eq true
      end
    end
  end

  describe "#doi_minting_enabled?" do
    let(:work) { unminted_work }
    it "returns server setting" do
      expect(work.doi_minting_enabled?).to eq Deepblue::DoiMintingService.enabled?
    end
  end

  describe "#doi_pending?" do
    context "with a nil doi" do
      let(:work) { unminted_work } 
      it "returns false" do
        expect(work.doi).to be_nil
        expect(work.doi_pending?).to eq false
      end
    end
    context "with a pending doi" do
      let(:work) { pending_work }
      it "returns true" do
        expect(work.doi).to eq pending_doi
        expect(work.doi_pending?).to eq true
      end
    end
    context "with a doi" do
      let(:work) { minted_work }
      it "returns false" do
        expect(work.doi).to eq minted_doi
        expect(work.doi_pending?).to eq false
      end
    end
  end

  describe "#doi_minimum_files?" do
    let(:work) { minted_work }
    context "without minimum files" do
      it "returns false" do
        expect(work.file_sets.count).to eq 0
        expect(work.doi_minimum_files?).to eq false
      end
    end
    context "with minimum files" do
      before(:each) do
        work.ordered_members << file_set
        work.save
      end
      it "returns true" do
        expect(work.file_sets.count).to eq 1
        expect(work.doi_minimum_files?).to eq true
      end
    end
  end

  describe "#doi_mint" do
    before(:each) do
      allow(work).to receive(:doi_minting_enabled?).and_return(true)
      allow(Rails.logger).to receive(:warn)
      allow(Rails.logger).to receive(:info)
      allow(DoiMintingJob).to receive(:perform_later).and_return(true)
    end
    context "when minting is disabled" do
      let(:work) { unminted_work }
      before(:each) do
        allow(work).to receive(:doi_minting_enabled?).and_return(false)
      end
      it "logs a warning" do expect(Rails.logger).to receive(:warn); work.doi_mint end
      it "returns false" do expect(work.doi_mint).to eq false end
    end
    context "when metadata is invalid" do
      let(:work) { unminted_work }
      before(:each) do
        work.title = nil
        work.save(validate: false)
        expect(work).to be_invalid
      end
      it "logs a warning" do expect(Rails.logger).to receive(:warn); work.doi_mint end
      it "returns false" do expect(work.doi_mint).to eq false end
    end
    context "when minting is in progress" do
      let(:work) { pending_work }
      it "logs a warning" do expect(Rails.logger).to receive(:warn); work.doi_mint end
      it "returns false" do expect(work.doi_mint).to eq false end
    end
    context "when already minted" do
      let(:work) { minted_work }
      it "logs a warning" do expect(Rails.logger).to receive(:warn); work.doi_mint end
      it "returns false" do expect(work.doi_mint).to eq false end
    end
    context "when insufficient files" do
      let(:work) { unminted_work }
      before(:each) do
        allow(work).to receive(:doi_minimum_files?).and_return(false)
      end
      it "logs a warning" do expect(Rails.logger).to receive(:warn); work.doi_mint end
      it "returns false" do expect(work.doi_mint).to eq false end
    end
    context "when no doi yet" do
      let(:work) { unminted_work }
      before(:each) do
        allow(work).to receive(:doi_minimum_files?).and_return(true)
      end
      it "updates DOI to pending" do
        expect(work.doi).to be_nil
        work.doi_mint
        expect(work.doi).to eq pending_doi
      end
      it "calls DoiMintingJob" do
        expect(DoiMintingJob).to receive(:perform_later).and_return(true)
        work.doi_mint
      end
      it "logs success" do expect(Rails.logger).to receive(:info); work.doi_mint end
      it "returns true" do expect(work.doi_mint).to eq true end
    end
  end
end
