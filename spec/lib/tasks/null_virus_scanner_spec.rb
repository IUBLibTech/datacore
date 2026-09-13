require 'rails_helper'


RSpec.describe NullVirusScanner do

  describe "#initialize" do
    before {
      allow(AbstractVirusScanner).to receive(:new).with "the file"
    }
    it "calls parent initialize method" do
      expect(AbstractVirusScanner).to receive(:new).with "the file"

      NullVirusScanner.new("the file")
    end
  end


end