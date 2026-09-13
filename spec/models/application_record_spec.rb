require 'rails_helper'

RSpec.describe ApplicationRecord do

  describe "#self.abstract_class" do
    it "returns true" do
      expect(ApplicationRecord.abstract_class).to eq true
    end
  end

end
