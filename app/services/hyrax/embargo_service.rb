# frozen_string_literal: true

module Hyrax

  class EmbargoService < RestrictionService

    class << self
      #
      # Methods for Querying Repository to find Embargoed Objects
      #

      # Returns all assets with embargo release date set to a date in the past
      def assets_with_expired_embargoes
        ::Deepblue::LoggingHelper.bold_debug [ ::Deepblue::LoggingHelper.here,
                                               ::Deepblue::LoggingHelper.called_from,
                                               "" ]
        builder = Hyrax::ExpiredEmbargoSearchBuilder.new(self)
        presenters(builder)
      end

      # Returns all assets with embargo release date set
      #   (assumes that when lease visibility is applied to assets
      #    whose leases have expired, the lease expiration date will be removed from its metadata)
      def assets_under_embargo
        ::Deepblue::LoggingHelper.bold_debug [ ::Deepblue::LoggingHelper.here,
                                               ::Deepblue::LoggingHelper.called_from,
                                               "" ]
        builder = Hyrax::EmbargoSearchBuilder.new(self)
        presenters(builder)
      end

      # Returns all assets that have had embargoes deactivated in the past.
      def assets_with_deactivated_embargoes
        ::Deepblue::LoggingHelper.bold_debug [ ::Deepblue::LoggingHelper.here,
                                               ::Deepblue::LoggingHelper.called_from,
                                               "" ]
        builder = Hyrax::DeactivatedEmbargoSearchBuilder.new(self)
        presenters(builder)
      end

      private

        def presenter_class
          Hyrax::EmbargoPresenter
        end

    end

  end

end
