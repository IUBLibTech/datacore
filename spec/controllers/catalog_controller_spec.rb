require 'rails_helper'

RSpec.describe CatalogController do
  describe "#facet" do
    it "renders a response" do
      get :facet, params: { id: 'resource_type_sim', q: '', search_fields: 'all_fields' }
      expect(response.status).to eq 200
    end
  end

  describe '#render_bookmarks_control?' do
      it 'returns false' do
        expect(controller.render_bookmarks_control?).to eq false
      end
  end

end
