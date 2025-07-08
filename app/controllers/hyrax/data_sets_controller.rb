# frozen_string_literal: true

module Hyrax

  class DataSetsController < DeepblueController

    PARAMS_KEY = 'data_set'

    include Deepblue::WorksControllerBehavior
    include Datacore::DoiControllerBehavior

    self.curation_concern_type = ::DataSet
    self.show_presenter = Hyrax::DataSetPresenter
    delegate :show_presenter, to: :class

    before_action :assign_date_coverage,         only: [:create, :update]
    before_action :assign_admin_set,             only: [:create, :update]
    before_action :workflow_destroy,             only: [:destroy]

    after_action :workflow_create,               only: [:create]

    # FIXME: review behavior
    # Create EDTF::Interval from form parameters
    # Replace the date coverage parameter prior with serialization of EDTF::Interval
    def assign_date_coverage
      cov_interval = Dataset::DateCoverageService.params_to_interval params
      params[PARAMS_KEY]['date_coverage'] = cov_interval ? cov_interval.edtf : ""
    end

    # FIXME: review behavior
    def assign_admin_set
      admin_sets = Hyrax::AdminSetService.new(self).search_results(:deposit)
      admin_sets.each do |admin_set|
        if admin_set.id != "admin_set/default"
          params[PARAMS_KEY]['admin_set_id'] = admin_set.id
        end
      end
    end

    private

      # FIXME: never called
      def get_date_uploaded_from_solr(file_set)
        field = file_set.solr_document[Solrizer.solr_name('date_uploaded', :stored_sortable, type: :date)]
        return if field.blank?
        begin
          Time.parse(field)
        rescue
          Rails.logger.info "Unable to parse date: #{field.first.inspect} for #{self['id']}"
        end
      end
  end
end
