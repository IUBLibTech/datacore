# frozen_string_literal: true

describe DoiMintingJob do

  describe "#perform_now" do
    context "when work is invalid" do
      it "returns nil"
    end
    context "when doi blank" do
      it "returns nil"
    end
    context "when doi minted" do
      it "returns nil"
    end
    context "when doi pending" do
      it "returns true"
    end
  end
end
