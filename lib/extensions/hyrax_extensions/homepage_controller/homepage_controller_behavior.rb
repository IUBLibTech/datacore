module Extensions
  module HyraxExtensions
    module HomepageController
      module HomepageControllerBehavior

        def index
          @featured_collection_list = FeaturedCollectionList.new
          super
        end

      end
    end
  end
end
