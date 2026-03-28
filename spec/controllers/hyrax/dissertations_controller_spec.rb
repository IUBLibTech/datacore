require 'rails_helper'

RSpec.describe Hyrax::DissertationsController, type: :controller do

  describe "#curation_concern_type" do
    it do
      expect(Hyrax::DissertationsController.curation_concern_type).to eq ::Dissertation
    end
  end

  describe "#show_presenter" do
    it do
      expect(Hyrax::DissertationsController.show_presenter).to eq Hyrax::DissertationPresenter
    end
  end

end
