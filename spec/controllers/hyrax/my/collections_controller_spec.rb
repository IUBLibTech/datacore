require 'rails_helper'

RSpec.describe Hyrax::My::CollectionsController do
  let(:subject) { described_class.new }
  let(:collection) { FactoryBot.create(:collection_lw) }

  describe "#render_bookmarks_control?" do
    it "returns false" do
      expect(subject.send(:render_bookmarks_control?)).to eq false
    end
  end
end
