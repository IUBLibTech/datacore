# modified from blacklight 6.25.0 Blacklight::SearchContext
module Extensions
  module CatalogController
    module BlockFindSearchSession
      # disable querying, storing blacklight Search records which are never used
      def find_search_session
        nil
      end
    end
  end 
end
