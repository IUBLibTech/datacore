module Extensions
  module HyraxExtensions
    module CollectionsController
      module RenderBookmarksControl
        protected

        # disable the bookmark control from displaying in gallery view
        def render_bookmarks_control?
          false
        end
      end
    end
  end
end
