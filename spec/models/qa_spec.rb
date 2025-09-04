
RSpec.describe Qa do

  describe "#self.table_name_prefix" do
    it "returns string" do
      expect(Qa.table_name_prefix).to eq "qa_"
    end
  end
end
