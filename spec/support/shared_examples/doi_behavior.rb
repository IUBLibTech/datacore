RSpec.shared_examples "DeepBlue::DoiBehavior" do |object_factory|
  let(:minted_doi) { 'doi:10.82028/18sn-h641' }
  let(:pending_doi) { Deepblue::DoiBehavior::DOI_PENDING }
  # assign doi value by context
  let(:work) { FactoryBot.create(object_factory, doi: doi) }

  describe "#doi_minted?" do
    context "with a nil doi" do
      it "returns false"
    end
    context "with a pending doi" do
      it "returns false"
    end
    context "with a doi" do
      it "returns true"
    end
  end

  describe "#doi_minting_enabled?" do
    it "returns server setting"
  end

  describe "#doi_pending?" do
    context "with a nil doi" do
      it "returns false"
    end
    context "with a pending doi" do
      it "returns true"
    end
    context "with a doi" do
      it "returns false"
    end
  end

  describe "#doi_minimum_files?" do
    context "without minimum files" do
      it "returns false"
    end
    context "with minimum files" do
      it "returns true"
    end
  end


  describe "#doi_mint" do
    context "when minting is disabled" do
      it "logs a warning"
      it "returns false"
    end
    context "when metadata is invalid" do
      it "logs a warning"
      it "returns false"
    end
    context "when minting is in progress" do
      it "logs a warning"
      it "returns false"
    end
    context "when already minted" do
      it "logs a warning"
      it "returns false"
    end
    context "when insufficient files" do
      it "logs a warning"
      it "returns false"
    end
    context "when no doi yet" do
      it "updates DOI to pending"
      it "calls DoiMintingJob"
      it "returns true"
    end
  end
end
