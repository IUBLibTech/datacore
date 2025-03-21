require 'rails_helper'

RSpec.describe Hyrax::Dashboard::CollectionsController do
  let(:subject) { described_class.new }
  let(:collection) { FactoryBot.create(:collection_lw) }

  describe "#default_event_note" do
    it "returns string" do
      expect(subject.default_event_note).to eq 'Hyrax::Dashboard::CollectionsController'
    end
  end

  describe "#params_key" do
    it "returns string" do
      expect(subject.params_key).to eq 'collection'
    end
  end


end
