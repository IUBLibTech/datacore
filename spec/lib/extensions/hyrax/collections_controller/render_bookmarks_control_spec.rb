require 'rails_helper'

class BookmarkMock
  include ::Extensions::Hyrax::CollectionsController::RenderBookmarksControl

  def render_bookmarks_control_check?
    render_bookmarks_control?
  end
end


describe Extensions::Hyrax::CollectionsController::RenderBookmarksControl do

  subject { BookmarkMock.new }

  describe "#render_bookmarks_control?" do
    it "returns false" do
      expect(BookmarkMock.new.render_bookmarks_control_check?).to eq false
    end
  end
end
