# frozen_string_literal: true

module Hyrax

  class DataSetForm < DeepblueForm

    self.model_class = ::DataSet

    self.terms -= %i[ rights_statement ]
    self.terms +=
      %i[
        authoremail
        date_coverage
        description
        resource_type
        publisher
        fundedby
        fundedby_other
        doi
        description_abstract
        keyword
        methodology
        referenced_by
        rights_license
        rights_license_other
        license_other
        curation_notes_admin
        curation_notes_user
        geo_location_place
        geo_location_box
      ]

    self.default_work_primary_terms =
      %i[
        title
        creator
        authoremail
        methodology
        resource_type
        description_abstract
        description
        publisher
        date_coverage
        rights_license
        rights_license_other
        license_other
        fundedby
        fundedby_other
        keyword
        language
        referenced_by
        curation_notes_admin
        curation_notes_user
        geo_location_place
        geo_location_box
      ]

    self.default_work_secondary_terms = []

    self.required_fields =
      %i[
        title
        creator
        authoremail
        methodology
        description
        rights_license
        resource_type
        description_abstract
        publisher
      ]

    def data_set?
      true
    end

    def merge_date_coverage_attributes!(hsh)
      @attributes.merge!(hsh&.stringify_keys || {})
    end

  end

end
