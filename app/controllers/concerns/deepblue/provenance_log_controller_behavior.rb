# frozen_string_literal: true

module Deepblue
  module ProvenanceLogControllerBehavior
    extend ActiveSupport::Concern

    included do
      before_action :provenance_log_update_before, only: [:update]
      after_action :provenance_log_update_after,   only: [:update]
      protect_from_forgery with: :null_session,    only: [:display_provenance_log]
      attr_accessor :provenance_log_entries
    end

    def provenance_log_update_after
      curation_concern.provenance_log_update_after( current_user: current_user,
                                                    # event_note: 'DataSetsController.provenance_log_update_after',
                                                    update_attr_key_values: @update_attr_key_values )
    end

    def provenance_log_update_before
      @update_attr_key_values = curation_concern.provenance_log_update_before( form_params: params[params_key].dup )
    end

    def display_provenance_log
      # load provenance log for this work
      file_path = Deepblue::ProvenancePath.path_for_reference( curation_concern.id )
      Deepblue::LoggingHelper.bold_debug [ "DataSetsController", "display_provenance_log", file_path ]
      Deepblue::ProvenanceLogService.entries( curation_concern.id, refresh: true )
      # continue on to normal display
      redirect_to polymorphic_url([main_app, curation_concern], anchor: "prov_log")
    end

    def display_provenance_log_enabled?
      true
    end

    def provenance_log_entries_present?
      provenance_log_entries.present?
    end
  end
end
