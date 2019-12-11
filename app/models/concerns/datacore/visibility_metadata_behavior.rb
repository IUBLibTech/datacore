module Datacore
  module VisibilityMetadataBehavior
    extend ActiveSupport::Concern

    included do
      property :visibility_iu_campus, predicate: ::RDF::Vocab::DC.audience do |index|
        index.as :symbol, :facetable
      end
    end

    #def represented_visibility
    #  super + campus_visibility_service.active_ids
    #end

    # After setting standard visibility type, set campus visibility
    def registered_visibility!
      super
      set_read_groups(visibility_iu_campus.to_a, campus_visibility_service.active_ids)
    end

    def campus_visibility_service
      @campus_visibility_service ||= campus_visibility_service_class.new
    end

    def campus_visibility_service_class
      ::Datacore::CampusVisibilityService
    end

  end
end
