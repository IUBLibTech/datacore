# frozen_string_literal: true

require 'rails_helper'

class CollectionMock

  def initialize (id:, title:)
    @id = id
    @title = title
  end

  def id
    return @id
  end

  def title
    return @title
  end
end

class FormMock

  def reflect_on_association
  end

  def attributes
  end
end

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


  describe "#initialize" do
    it "sets @scope" do
      subject.instance_variable_get(:@scope) == instance_of(Struct)
    end

    it "calls super" do
      skip "Add test here"
    end
  end


  describe "#permission_template" do

    context "when @permission_template is not set" do
      before {
        allow(subject).to receive(:model).and_return OpenStruct.new(id: 555)
        allow(Hyrax::PermissionTemplate).to receive(:find_or_create_by).with(source_id: 555).and_return "template model"
        allow(Hyrax::Forms::PermissionTemplateForm).to receive(:new).with("template model").and_return "permission template"
      }
      it "calls PermissionTemplate.find_or_create_by and PermissionTemplateForm.new" do
        expect(Hyrax::PermissionTemplate).to receive(:find_or_create_by).with(source_id: 555)
        expect(Hyrax::Forms::PermissionTemplateForm).to receive(:new).with("template model")
        expect(subject.permission_template).to eq "permission template"

        subject.instance_variable_get(:@permission_template) == "permission template"
      end
    end

    context "when @permission_template is set" do
      before {
        subject.instance_variable_set(:@permission_template, "set template")
      }
      it "returns @permission_template" do
        expect(Hyrax::PermissionTemplate).not_to receive(:find_or_create_by).with(source_id: anything)
        expect(Hyrax::Forms::PermissionTemplateForm).not_to receive(:new)

        expect(subject.permission_template).to eq "set template"

        subject.instance_variable_get(:@permission_template) == "set template"
      end
    end
  end

  describe "#select_files" do
    before {
      allow(subject).to receive(:all_files_with_access).and_return [["apples", 3], ["bananas", 2], ["oranges", 1]]
    }

    it "calls all_files_with_access and creates a Hash from the result" do
      expect(subject).to receive(:all_files_with_access).and_return [["apples", 3], ["bananas", 2], ["oranges", 1]]
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

    context "when @banner_info is not set" do
      before {
        allow(subject).to receive(:id).and_return 202
        allow(subject).to receive(:branding_banner_info).with(id: 202).and_return "branding"
      }
      it "calls branding_banner_info" do
        expect(subject).to receive(:branding_banner_info).with(id: 202)
        expect(subject.banner_info).to eq "branding"

        subject.instance_variable_get(:@banner_info) == "branding"
      end
    end

    context "when @banner_info is set" do
      before {
        allow(subject).to receive(:id).and_return 202
        subject.instance_variable_set(:@banner_info, "banner information")
      }
      it "returns @banner_info" do
        expect(subject).not_to receive(:branding_banner_info)
        expect(subject.banner_info).to eq "banner information"
      end
    end
  end

  describe "#logo_info" do
    context "when @logo_info is not set" do
      before {
        allow(subject).to receive(:id).and_return 303
        allow(subject).to receive(:branding_logo_info).with(id: 303).and_return "logo"
      }
      it "calls branding_logo_info" do
        expect(subject).to receive(:branding_logo_info).with(id: 303)
        expect(subject.logo_info).to eq "logo"

        subject.instance_variable_get(:@logo_info) == "logo"
      end
    end

    context "when @logo_info is set" do
      before {
        allow(subject).to receive(:id).and_return 303
        subject.instance_variable_set(:@logo_info, "information")
      }

      it "returns @logo_info" do
        expect(subject).not_to receive(:branding_logo_info)
        expect(subject.logo_info).to eq "information"
      end
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

    context "when model.thumbnail has value" do
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
    it "calls collection.member_of_collections" do
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

  describe "#available_parent_collections" do
    context "available_parents is present" do
      before {
        subject.instance_variable_set(:@available_parents, "available parents")
      }
      it "returns @available_parents" do
        expect(subject.available_parent_collections scope: "scope").to eq "available parents"
      end
    end

    context "available_parents is not present" do
      before {
        allow(subject).to receive(:id).and_return "ZZ101"
        collectionObj = CollectionMock.new id: "ZZ101", title: "Entitled Collection"
        allow(Collection).to receive(:find).and_return(collectionObj)
        allow(Hyrax::Collections::NestedCollectionQueryService).to receive(:available_parent_collections)
              .with(child: collectionObj, scope: "scope", limit_to_id: nil)
              .and_return [(CollectionMock.new id: "XX202", title: ["Bingo"]), (CollectionMock.new id: "YY303", title: ["Yahtzee"])]
      }

      it "calls NestedCollectionQueryService.available_parent_collections" do
        expect(subject.available_parent_collections scope: "scope")
          .to eq "[{\"id\":\"XX202\",\"title_first\":\"Bingo\"},{\"id\":\"YY303\",\"title_first\":\"Yahtzee\"}]"
        subject.instance_variable_get(:@available_parents) == [{id:"XX202",title_first:"Bingo"},{id:"YY303","title_first":"Yahtzee"}]
      end
    end
  end

end
