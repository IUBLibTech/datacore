# frozen_string_literal: true

require 'rails_helper'

describe Datacore::DoiMetadataService do
  let(:work) { FactoryBot.create(:data_set, subject: subjects, contributor: contributors) }
  let(:subjects) { ['subject1', 'subject2'] }
  let(:contributors) { ['contributor1', 'contributor2'] }
  let(:service) { described_class.new(work: work) }

  describe "#metadata" do
    it "returns #full_metadata" do
      expect(service).to receive(:full_metadata)
      expect(service.metadata)
    end
    it "caches @metadata" do
      expect(service.instance_variable_get(:@metadata)).to be_nil
      expect(service.metadata)
      expect(service.instance_variable_get(:@metadata)).not_to be_nil
    end
  end

  describe "#reload" do
    it "reloads the work" do
      expect(work).to receive(:reload)
      service.reload
    end
    it "clears out @metadata" do
      service.metadata
      expect(service.instance_variable_get(:@metadata)).not_to be_nil
      service.reload
      expect(service.instance_variable_get(:@metadata)).to be_nil
    end
  end

  describe "#basic_metadata" do
    it "returns a schema-compliant Hash" do
      basic_metadata = service.basic_metadata
      expect(basic_metadata).to be_a Hash
      expect(basic_metadata.keys).to eq service.class.const_get(:BASIC_KEYS)
      expect(basic_metadata[:creators].first.keys).to eq [:name]
      expect(basic_metadata[:titles].first.keys).to eq [:title]
      expect(basic_metadata[:publisher]).to eq described_class.const_get(:PUBLISHER)
      expect(basic_metadata[:publicationYear]).to eq Date.today.year.to_s
      expect(basic_metadata[:types]).to eq({ resourceTypeGeneral: described_class.const_get(:RESOURCE_TYPE) })
      expect(basic_metadata[:url]).to match /http.*#{work.id}/
    end
  end

  describe "#expanded_metadata" do
    context "with implicit include_empty: false" do
      it "returns a populated Hash" do
        expanded_metadata = service.expanded_metadata
        expect(expanded_metadata).to be_a Hash
        expect(expanded_metadata.values).to be_all(&:present?)
        expect(service.class.const_get(:ADDITIONAL_KEYS)).to include(*expanded_metadata.keys)
        expect(expanded_metadata[:subjects].map(&:values).flatten.sort).to eq subjects
        expect(expanded_metadata[:contributors].map { |v| v[:name] }.flatten.sort).to eq contributors
        expect(expanded_metadata[:alternateIdentifiers][:alternateIdentifierType]).to eq 'DataCORE internal ID'
        expect(expanded_metadata[:alternateIdentifiers][:alternateIdentifier]).to eq work.id
      end
    end
    context "with explicit include_empty: true" do
      it "returns a Hash including empty values" do
        without_empty = service.expanded_metadata
        with_empty = service.expanded_metadata(include_empty: true)
        expect(with_empty.size).to be > without_empty.size
        expect(with_empty.values.any?(&:empty?)).to eq true
      end
    end
  end

  describe "#full_metadata" do
    it "returns basic and expanded metadata, merged" do
      expect(service.full_metadata).to eq service.basic_metadata.merge(service.expanded_metadata)
    end
  end

  describe "#dates" do
    context "with a date_uploaded" do
      before { work.date_uploaded = DateTime.now }
      it "includes a Submitted entry" do
        expect(work.date_uploaded).to be_present
        expect(service.dates.map { |d| d[:dateType] }).to include 'Submitted'
      end
    end
    context "with a date_modified" do
      before { work.date_modified = DateTime.now }
      it "includes an Updated entry" do
        expect(work.date_modified).to be_present
        expect(service.dates.map { |d| d[:dateType] }).to include 'Updated'
      end
    end
    context "with date_coverage" do
      before { work.date_coverage = 'date coverage' }
      it "includes a Collected entry" do
        expect(service.dates.map { |d| d[:dateType] }).to include 'Collected'
      end
    end
    context "without date values" do
      it "returns an empty Array" do
        expect(work.date_uploaded).to be_nil
        expect(work.date_modified).to be_nil
        expect(work.date_coverage).to be_nil
        expect(service.dates).to be_empty
      end
    end
  end

  describe "#descriptions" do
    context "with description values" do
      before { work.description = ['desc1', 'desc2'] }
      it "includes Other entries" do
        expect(work.description).to be_present
        expect(service.descriptions.map { |d| d[:descriptionType] }).to include 'Other'
      end
    end
    context "with description_abstract values" do
      before { work.description_abstract = ['abstract1', 'abstract2'] }
      it "includes Other entries" do
        expect(work.description_abstract).to be_present
        expect(service.descriptions.map { |d| d[:descriptionType] }).to include 'Abstract'
      end
    end
    context "with a methodology value" do
      before { work.methodology = 'methodology1' }
      it "includes a Methods entry" do
        expect(service.descriptions.map { |d| d[:descriptionType] }).to include 'Methods'
      end
    end
    context "without description values" do
      before { work.description = [] }
      before { work.methodology = nil }
      it "returns an empty Array" do
        expect(work.description).to be_empty
        expect(work.description_abstract).to be_empty
        expect(work.methodology).to be_nil
        expect(service.descriptions).to be_empty
      end
    end
  end

  describe "#funding" do
    context "with work.fundedby" do
      before { work.fundedby = ['fund1', 'fund2'] }
      it "returns funding sources" do
        expect(service.funding.map(&:values).flatten.sort).to eq work.fundedby.sort
      end
    end
    context "with work.fundedby and work.fundedby_other" do
      before { work.fundedby = ['Other Funding Agency'] }
      before { work.fundedby_other = ['other1', 'other2'] }
      it "returns funding sources, removing Other Funding Agency" do
        expect(service.funding.map(&:values).flatten.sort).to eq work.fundedby_other.sort
      end
    end
    context "without fundedby.* fields" do
      it "returns an empty Array" do
        expect(work.fundedby).to be_empty
        expect(work.fundedby_other).to be_empty
        expect(service.funding).to be_empty
      end
    end
  end

  describe "#geo_location" do
    context "with geo_location_place" do
      before { work.geo_location_place = 'a place' }
      it "returns a geoLocationPlace" do
        expect(service.geo_location.map(&:keys).flatten).to include :geoLocationPlace
      end
    end
    context "with geo_location_box" do
      before { work.geo_location_box = '1, 2, 3, 4' }
      it "returns a geoLocationBox" do
        expect(service.geo_location.map(&:keys).flatten).to include :geoLocationBox
      end
    end
    context "without geo_location values" do
      it "returns an empty Array" do
        expect(work.geo_location_place).to be_nil
        expect(work.geo_location_box).to be_nil
        expect(service.geo_location).to be_empty
      end
    end
  end

  describe "#geo_location_box" do
    context "without work.geo_location_box present" do
      before { work.geo_location_box = nil }
      it "returns nil" do
        expect(service.geo_location_box).to be_nil
      end
    end
    context "with invalid work.geo_location_box present" do
      before { work.geo_location_box = '1 2 3' }
      it "returns nil" do
        expect(service.geo_location_box).to be_nil
      end
    end
    context "with valid work.geo_location_box present" do
      let(:values) { %w[1 2.1 -3 4] }
      before { work.geo_location_box = values.join(', ') }
      it "returns a formatted Hash" do
        expect(service.geo_location_box).to be_a Hash
        expect(service.geo_location_box.keys).to eq [:southBoundLatitude, :westBoundLongitude, :northBoundLatitude, :eastBoundLongitude]
        expect(service.geo_location_box.values).to eq values
      end
    end
  end

  describe "#language" do
    context "with a work language" do
      before { work.language = ['lang1', 'lang2'] }
      it "returns the work language" do
        expect(service.language).to eq 'lang1'
      end
    end
    context "without a work language" do
      before { work.language = nil }
      it "returns default value: en" do
        expect(service.language).to eq 'en'
      end
    end
  end

  describe "#rights_license" do
    it "returns an populated array" do
      expect(service.rights_license).to be_a Array
      expect(service.rights_license).not_to be_empty
    end
    context "without a rights_license_other" do
      it "returns a single value" do
        expect(work.rights_license_other).to be_nil
        expect(service.rights_license.size).to eq 1
      end
    end
    context "with a rights_license_other" do
      before { work.rights_license_other = 'other license' }
      it "returns a second value" do
        expect(service.rights_license.size).to eq 2
      end
    end
  end
end
