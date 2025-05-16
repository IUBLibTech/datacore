# frozen_string_literal: true

require 'rails_helper'

describe Hyrax::Forms::CollectionForm do

  let(:model) { Collection.new }
  let(:user) { create(:user) }
  let(:ability) { Ability.new(user) }
  let(:config) { Blacklight::Solr::Configuration.new }
  let(:repository) { Blacklight::Solr::Repository.new(:config) }
  let(:subject) { described_class.new(model, ability, repository) }

  let( :expected_required_fields ) { %i[
      title
      creator
      description
      subject_discipline
  ] }

  let( :expected_terms ) { %i[
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
  ] }

  let( :expected_default_work_primary_terms ) { %i[
      title
      creator
      description
      keyword
      subject_discipline
      language
      referenced_by
  ] }

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
      is_expected.to eq expected_terms
    end
  end

  describe "#required_fields" do
    subject { described_class.required_fields }

    it "equals array" do
      is_expected.to eq expected_required_fields
    end
  end

  pending "#initialize"

  describe "#permission_template" do
    before {
      allow(Hyrax::PermissionTemplate).to receive(:find_or_create_by).with(source_id: anything).and_return OpenStruct.new( attributes: {} )
    }
    it "calls PermissionTemplate" do
      expect(Hyrax::PermissionTemplate).to receive(:find_or_create_by).with(source_id: anything).and_return OpenStruct.new( attributes: {} )
      subject.permission_template
    end

    it "calls PermissionTemplateForm.new" do
      skip "Add a test"
    end
  end

  describe "#select_files" do
    before {
      allow(subject).to receive(:all_files_with_access).and_return [["apples", 3], ["bananas", 2], ["oranges", 1]]
    }

    it "calls all_files_with_access and creates a Hash from the result" do
      expect(subject).to receive(:all_files_with_access)
      expect(subject.select_files).to eq Hash[[["apples", 3], ["bananas", 2], ["oranges", 1]]]
    end
  end

  describe "#primary_terms" do
    it "equals array" do
      expect(subject.primary_terms).to eq expected_default_work_primary_terms
    end
  end

  describe "#secondary_terms" do
    it "returns empty array" do
      expect(subject.secondary_terms).to be_blank
    end
  end

  describe "#relative_url_root" do
    context "when DeepBlueDocs::Application.config.relative_url_root has value" do
      before {
        allow(::DeepBlueDocs::Application.config).to receive(:relative_url_root).and_return "rootin' tootin'"
      }
      it "returns DeepBlueDocs::Application.config.relative_url_root" do
        expect(subject.relative_url_root).to eq "rootin' tootin'"
      end
    end

    context "when DeepBlueDocs::Application.config.relative_url_root has no value" do
      before {
        allow(::DeepBlueDocs::Application.config).to receive(:relative_url_root).and_return nil
      }
      it "returns empty string" do
        expect(subject.relative_url_root).to eq ""
      end
    end
  end

  describe "#banner_info" do
    before {
      allow(subject).to receive(:id).and_return 202
    }
    it "calls branding_banner_info" do
      expect(subject).to receive(:branding_banner_info).with(id: 202)
      subject.banner_info
    end
  end

  describe "#logo_info" do
    before {
      allow(subject).to receive(:id).and_return 303
    }
    it "calls branding_logo_info" do
      expect(subject).to receive(:branding_logo_info).with(id: 303)
      subject.logo_info
    end
  end

  describe "#display_additional_fields?" do
    context "secondary terms present" do
      before {
        allow(subject).to receive(:secondary_terms).and_return ["title"]
      }
      it "returns true" do
        expect(subject.display_additional_fields?).to eq true
      end
    end

    context "secondary terms not present" do
      before {
        allow(subject).to receive(:secondary_terms).and_return []
      }
      it "returns false" do
        expect(subject.display_additional_fields?).to eq false
      end
    end
  end

  describe "#thumbnail_title" do
    context "when model.thumbnail is nil" do
      before {
        allow(model).to receive(:thumbnail).and_return( nil )
      }
      it "returns nil" do
        expect(subject.thumbnail_title).to be_blank
      end
    end

    context "when model.thumbnail is not nil" do
      before {
        allow(model).to receive(:thumbnail).and_return OpenStruct.new( title: ["rutabaga", "cauliflower", "tomato"] )
      }
      it "returns model.thumbnail.title.first" do
        expect(subject.thumbnail_title).to eq "rutabaga"
      end
    end
  end

  describe "#list_parent_collections" do
    before {
      allow(model).to receive(:member_of_collections).and_return(["sunflower", "bluebell", "petunia"])
    }
    it "returns collection.member_of_collections" do
      expect(subject.list_parent_collections).to eq ["sunflower", "bluebell", "petunia"]
    end
  end

  describe "#list_child_collections" do
    before {
      allow(subject.membership_service_class).to receive(:new)
                                               .with(scope: anything, collection: model, params: anything)
                                               .and_return OpenStruct.new( available_member_subcollections: OpenStruct.new(documents: ["vanilla", "saffron", "nutmeg"]) )
    }

    it "returns documents from collection_member_service.available_member_subcollections" do
      expect(subject.list_child_collections).to eq ["vanilla", "saffron", "nutmeg"]
    end
  end

  pending "#available_parent_collections"

end
