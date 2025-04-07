require 'rails_helper'

RSpec.describe Hyrax::WorkShowPresenter do
  let(:user) { FactoryBot.create :user }
  let(:attributes) do {} end
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:current_ability) { instance_double(Ability, current_user: user ) }
  let(:request) { double(host: 'example.org', base_url: 'http://example.org') }

  subject { described_class.new(solr_document, current_ability, request) }

  describe "delegates methods to solr_document:" do
    [:has?, :first, :fetch, :export_formats, :export_as,
     :based_near_label, :related_url, :depositor, :identifier, :resource_type, :keyword, :itemtype, :admin_set,
     :stringify_keys, :human_readable_type, :collection?, :to_s].each do
    |method|
      it "#{method}" do
        expect(subject).to delegate_method(method).to(:solr_document)
      end
    end
  end

  pending "delegates title method to solr_document:"

  describe "delegates more methods to solr_document:" do
    [:date_created, :description,
     :creator, :contributor, :subject, :publisher, :language, :embargo_release_date,
     :lease_expiration_date, :license, :source, :rights_statement, :thumbnail_id, :representative_id,
     :rendering_ids, :member_of_collection_ids,].each do
    |method|
      it "#{method}" do
        expect(subject).to delegate_method(method).to(:solr_document)
      end
    end
  end

  before do
    allow(subject).to receive(:id).and_return("XYZ")
    allow(subject).to receive(:title).and_return(["Fantastic Title", "Descriptive Title"])
  end

  describe '#page_title' do
    context "human_readable_type returns \'Work\'" do
      before {
        allow(subject).to receive(:human_readable_type).and_return("Work")
      }
      it 'returns page title when Work' do
        expect(subject.page_title).to eq 'Data Set | Fantastic Title | ID: XYZ | DataCORE'
      end
    end

    context "human_readable_type returns \'Not Work\'" do
      before {
        allow(subject).to receive(:human_readable_type).and_return("Not Work")
      }
      it 'returns page title when not Work' do
        expect(subject.page_title).to eq 'Not Work | Fantastic Title | ID: XYZ | DataCORE'
      end
    end
  end

  pending "#workflow"
  pending "#inspect_work"
  pending "#download_url"
  pending "#iiif_viewer"
  pending "#representative_presenter"
  pending "#member_of_collection_presenters"
  pending "#date_modified"
  pending "#date_uploaded"
  pending "#link_name"
  pending "#export_as_nt"
  pending "#export_as_jsonld"
  pending "#date_uploaded"
  pending "#export_as_ttl"
  pending "#editor"
  pending "#tweeter"
  pending "#presenter_types"
  pending "#grouped_presenters"

  describe "#work_featurable?" do
    context "when user_can_feature_works? and solr_document.public?" do
      before {
        allow(subject).to receive(:user_can_feature_works?).and_return(true)
        allow(subject.solr_document).to receive(:public?).and_return(true)
      }

      it "returns true" do
        expect(subject.work_featurable?).to eq true
      end
    end

    context "when user_can_feature_works? and not solr_document.public?" do
      before {
        allow(subject).to receive(:user_can_feature_works?).and_return(true)
        allow(subject.solr_document).to receive(:public?).and_return(false)
      }

      it "returns false" do
        expect(subject.work_featurable?).to eq false
      end
    end

    context "when solr_document.public? and not user_can_feature_works?" do
      before {
        allow(subject).to receive(:user_can_feature_works?).and_return(false)
        allow(subject.solr_document).to receive(:public?).and_return(true)
      }

      it "returns true" do
        expect(subject.work_featurable?).to eq false
      end
    end
  end

  pending "#display_feature_link?"


  describe "#display_unfeature_link?" do

    context "when work_featurable? and featured?" do
      before {
        allow(subject).to receive(:work_featurable?).and_return(true)
        allow(subject).to receive(:featured?).and_return(true)
      }
      it "returns true" do
        expect(subject.display_unfeature_link?).to eq true
      end
    end

    context "when work_featurable? and not featured?" do
      before {
        allow(subject).to receive(:work_featurable?).and_return(true)
        allow(subject).to receive(:featured?).and_return(false)
      }
      it "returns false" do
        expect(subject.display_unfeature_link?).to eq false
      end
    end

    context "when featured? and not work_featurable?" do
      before {
        allow(subject).to receive(:work_featurable?).and_return(false)
        allow(subject).to receive(:featured?).and_return(true)
      }
      it "returns false" do
        expect(subject.display_unfeature_link?).to eq false
      end
    end
  end

  pending "#stats_path"

  describe "#model" do
    context "calls solr_document.to_model" do
      before {
        allow(subject.solr_document).to receive(:to_model).and_return("model object")
      }
      it "returns result" do
        expect(subject.model).to eq "model object"
      end
    end
  end

  pending "delegate to member_presenter_factory"
  pending "#list_of_item_ids_to_display"
  pending "#member_presenters_for"
  pending "#total_pages"
  pending "#manifest_url"

  describe "#sequence_rendering" do
    context "when solr_document.rendering_ids are not present" do
      before {
        allow(subject.solr_document).to receive(:rendering_ids).and_return( nil )
      }
      it "returns empty array" do
        expect(subject.sequence_rendering).to be_blank
      end
    end

    context "when solr_document.rendering_ids are present" do
      it "returns flattened renderings" do
        skip "Add some tests"
      end
    end
  end

  pending "#manifest_metadata"
  pending "#show_deposit_for?"

end
