module Extensions
  module Hyrax
    module CollectionsController
      module RenderBookmarksControl
        protected
        # disable the bookmark control from displaying in gallery view
        # Hyrax doesn't show any of the default controls on the list view, so
        # this method is not called in that context.
        def render_bookmarks_control?
          false
        end
      end
    end
  end
end
