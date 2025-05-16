require 'rails_helper'

RSpec.describe CatalogController do

  pending "#self.uploaded_field"

  pending "#self.modified_field"

  pending "configure_blacklight"

  describe '#render_bookmarks_control?' do
      it 'returns false' do
        expect(controller.render_bookmarks_control?).to eq false
      end
  end

end
