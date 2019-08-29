# frozen_string_literal: true
#
module Hyrax

  module My

    # Finds embargoed objects with release dates in the past
    class ExpiredEmbargoSearchBuilder < My::EmbargoSearchBuilder
      self.default_processor_chain += [:only_expired_embargoes]

      def only_expired_embargoes(solr_params)
        solr_params[:fq] ||= []
        solr_params[:fq] = 'embargo_release_date_dtsi:[* TO NOW]'
      end
    end

  end

end
