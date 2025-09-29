module Hyrax
  # This search builder requires that a accessor named "collection" exists in the scope
  class SubcollectionMemberSearchBuilder < ::SearchBuilder
    include Hyrax::FilterByType
    attr_reader :collection, :search_includes_models

    class_attribute :collection_membership_field
    self.collection_membership_field = 'member_of_collection_ids_ssim'

    # Defines which search_params_logic should be used when searching for Collection members
    self.default_processor_chain += [:member_of_collection]

    # @param [scope] Typically the controller object
    def initialize(scope:,
                   collection:,
                   page: 0)
      @collection = collection
      @page = page.to_i
      super(scope)
    end

    def member_of_collection(solr_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "#{collection_membership_field}:#{collection.id}"

      solr_parameters[:page] ||= []
      solr_parameters[:page] << "page:#{@page}"
    end

    def models
        collection_classes
    end

  end
end
