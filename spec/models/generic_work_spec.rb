require 'rails_helper'

RSpec.describe GenericWork do

  describe "presenter_class", type: :model do
    it do
      expect(GenericWork.indexer).to eq GenericWorkIndexer
    end
  end


end
