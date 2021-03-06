module Hyrax
  # Injects a search builder filter to hide documents marked as suppressed
  module FilterSuppressed
    extend ActiveSupport::Concern

    included do
      self.default_processor_chain += [:only_active_works]
    end

    def only_active_works(solr_parameters)
      # ::Deepblue::LoggingHelper.bold_debug [ ::Deepblue::LoggingHelper.here,
      #                                        ::Deepblue::LoggingHelper.called_from,
      #                                        "solr_parameters=#{solr_parameters}",
      #                                        "" ]
      if ( current_ability.admin? )
        solr_parameters[:fq] ||= []   
      elsif ( blacklight_params[:id] == nil )
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] << '-suppressed_bsi:true'        
      elsif ( depositor? )
        solr_parameters[:fq] ||= []
      else
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] << '-suppressed_bsi:true'
      end

    end


    private

      def current_work
        ::SolrDocument.find(blacklight_params[:id])
      end

      def depositor?
        # This is getting all the depositors to a collection.
        depositors = current_work["read_access_person_ssim"]

        return false if depositors.nil?
        
        found = false
        depositors.each do |depositor|
           if ( depositor == current_ability.current_user.user_key)
            found = true
          end
        end
        found
      end

  end
end
