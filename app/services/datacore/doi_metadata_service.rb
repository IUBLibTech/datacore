# frozen_string_literal: true

module Datacore
  class DoiMetadataService

    PUBLISHER = "Indiana University".freeze
    RESOURCE_TYPE = "Dataset".freeze
    BASIC_KEYS = [:creators, :titles, :publisher, :publicationYear, :types, :url]
    ADDITIONAL_KEYS = [:descriptions, :subjects, :contributors, :dates, :geoLocations, :fundingReferences, :language, :alternateIdentifiers, :rightsList]
    # uses datacite metadata schema 4.5
    # https://datacite-metadata-schema.readthedocs.io/en/4.5/properties/

    attr_reader :work

    # @param work DataSet 
    def initialize(work:)
      @work = work
    end

    # @return Hash all available work metadata
    def metadata
      @metadata ||= full_metadata
    end

    # @return nil
    # reloads work and metadata
    def reload
      work.reload
      @metadata = nil
    end

    # @return [Hash] work minimal required metadata for remote record creation or update
    def basic_metadata
      { creators: work.creator.map { |c| { name: c } },
        titles: work.title.map { |t| { title: t } },
        publisher: PUBLISHER,
        publicationYear: Date.today.year.to_s,
        types: { resourceTypeGeneral: RESOURCE_TYPE },
        url: Rails.application.routes.url_helpers.hyrax_data_set_url(id: work.id)
      }
    end

    # @return [Hash] expanded work metadata
    def expanded_metadata(include_empty: false)
      {
        descriptions: descriptions,
        subjects: work.subject.map { |s| { subject: s} },
        contributors: work.contributor.map { |c| { contributorType: 'Researcher', name: c} },
        dates: dates,
        geoLocations: geo_location,
        fundingReferences: funding,
        language: language,
        alternateIdentifiers: { alternateIdentifierType: 'DataCORE internal ID', alternateIdentifier: work.id },
        rightsList: rights_license,
        # below held in abeyance pending determination of relationType [IULRDC-174]
        # relatedIdentifiers: work.related_url.map { |url| { relatedIdentifierType: 'URL', relationType: 'IsDescribedBy', relatedIdentifier: url } }
      }.select { |k,v| v.present? || include_empty }
    end

    # @return [Hash] all work metadata
    def full_metadata
      basic_metadata.merge(expanded_metadata)
    end

    # @return Array
    def dates
      dates = []
      dates << { dateType: 'Submitted', date: work.date_uploaded.strftime('%Y-%m-%d') } if work.date_uploaded.present?
      dates << { dateType: 'Updated', date: work.date_modified.strftime('%Y-%m-%d') } if work.date_modified.present?
      dates << { dateType: 'Collected', date: work.date_coverage } if work.date_coverage.present?
      return dates
    end

    # @return Array
    def descriptions
      descriptions = []
      descriptions += work.description.map { |desc| { lang: language, description: desc, descriptionType: 'Other' } }
      descriptions += work.description_abstract.map { |desc| { lang: language, description: desc, descriptionType: 'Abstract' } }
      descriptions << { lang: language, description: work.methodology, descriptionType: 'Methods' } if work.methodology.present?
      return descriptions
    end

    # @return Array
    def funding
      (work.fundedby.to_a + work.fundedby_other.to_a).reject { |fund| fund == 'Other Funding Agency' }.map { |fund| { funderName: fund } }
    end

    def geo_location
      geo_location = []
      geo_location << { geoLocationPlace: work.geo_location_place } if work.geo_location_place.present?
      geo_location << { geoLocationBox: geo_location_box } if geo_location_box.present?
      return geo_location
    end

    def geo_location_box
      return nil unless work.geo_location_box.present?
      points = work.geo_location_box.gsub(/[^- .0-9]/, ' ').split(' ').select { |p| Float(p, exception: false) }
      return nil unless points.size == 4
      return [:southBoundLatitude, :westBoundLongitude, :northBoundLatitude, :eastBoundLongitude].zip(points).to_h
    end

    def language
      work.language&.first || 'en'
    end

    def rights_license
      rights = []
      rights << { rightsUri: work.rights_license, rights: Hyrax::RightsLicenseService.new.select_active_options.map(&:reverse).to_h[work.rights_license] }
      rights << { rights: work.rights_license_other } if work.rights_license_other.present?
      return rights
    end
  end
end
