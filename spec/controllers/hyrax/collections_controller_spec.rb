require 'rails_helper'

RSpec.describe Hyrax::CollectionsController do
  let(:subject) { described_class.new }
  let(:collection) { FactoryBot.create(:collection_lw) }

  describe "#render_bookmarks_control?" do
    it "returns false" do
      expect(subject.send(:render_bookmarks_control?)).to eq false
    end
  end

  describe "#display_provenance_log" do
    it "redirects" do
      get :display_provenance_log, params: { id: collection.id }
      expect(response).to be_redirect
    end
  end
end
