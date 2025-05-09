# frozen_string_literal: true

require 'rails_helper'

describe Hyrax::Forms::CollectionForm do

  let(:model) { Collection.new }
  let(:user) { create(:user) }
  let(:ability) { Ability.new(user) }
  let(:config) { Blacklight::Solr::Configuration.new }
  let(:repository) { Blacklight::Solr::Repository.new(:config) }
  let(:subject) { described_class.new(model, ability, repository) }


  describe "delegates methods to model:" do
    [:id, :depositor, :permissions, :human_readable_type, :member_ids, :nestable?].each do
    |method|
      it "#{method}" do
        expect(subject).to delegate_method(method).to(:model)
      end
    end
  end

  describe "delegates method to Hyrax::CollectionsController" do
    it "#blacklight_config" do
      skip "Add test here"
    end
  end

  describe "#terms" do
    subject { described_class.terms }

    it "equals array" do
      is_expected.to eq %i[
      authoremail
      based_near
      collection_type_gid
      contributor
      creator
      date_coverage
      date_created
      description
      fundedby
      grantnumber
      identifier
      keyword
      language
      license
      methodology
      publisher
      referenced_by
      related_url
      representative_id
      resource_type
      rights_license
      subject
      subject_discipline
      thumbnail_id
      title
      visibility
    ]
    end
  end

  describe "#required_fields" do
    subject { described_class.required_fields }

    it "equals array" do
      skip "Add test here"
    end
  end

  pending "#permission_template"

  pending "#select_files"

  describe "#primary_terms" do
    it "returns array" do
      skip "Add test here"
    end
  end

  describe "#secondary_terms" do
    it "returns array" do
      skip "Add test here"
    end
  end

  pending "#banner_info"

  pending "#logo_info"

  pending "#display_additional_fields?"

  describe "#thumbnail_title" do
    context "when model.thumbnail is nil" do
      before {
        allow(subject.model).to receive(:thumbnail).and_return( nil )
      }
      it "returns nil" do
        expect(subject.thumbnail_title).to be_nil
      end
    end

    context "when model.thumbnail is not nil" do
      it "returns model.thumbnail.title.first" do
        skip "Add test here"
      end
    end
  end

  pending "#list_parent_collections"

  pending "#list_child_collections"

  pending "#available_parent_collections"
end
