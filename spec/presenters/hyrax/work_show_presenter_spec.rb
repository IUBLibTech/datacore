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

end
