require 'rails_helper'

RSpec.describe Hyrax::WorkShowPresenter do
  let(:user) { FactoryBot.create :user }
  let(:attributes) do {} end
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:current_ability) { instance_double(Ability, current_user: user ) }
  let(:request) { double(host: 'example.org', base_url: 'http://example.org') }

  subject { described_class.new(solr_document, current_ability, request) }

  before do
    allow(subject).to receive(:id).and_return("XYZ")
    allow(subject).to receive(:title).and_return(["Fantastic Title", "Descriptive Title"])
  end

  # NOTE:  relative_url_root function exactly the same in collection_presenter, work_show_presenter
  describe "#relative_url_root" do
    context "when DeepBlueDocs::Application.config.relative_url_root has value" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:relative_url_root).and_return "site root"
      }
      it "returns value" do
        expect(DeepBlueDocs::Application.config).to receive(:relative_url_root)
        expect(subject.relative_url_root).to eq "site root"
      end
    end

    context "when DeepBlueDocs::Application.config.relative_url_root is nil or false" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:relative_url_root).and_return false
      }
      it "returns empty string" do
        expect(DeepBlueDocs::Application.config).to receive(:relative_url_root)
        expect(subject.relative_url_root).to be_blank
      end
    end
  end

  describe '#page_title' do
    before {
      allow(I18n).to receive(:t).with( "hyrax.product_name").and_return "the best of the best"
    }

    context "human_readable_type returns \'Work\'" do
      before {
        allow(subject).to receive(:human_readable_type).and_return("Work")
      }
      it 'returns page title when Work' do
        expect(subject.page_title).to eq 'Data Set | Fantastic Title | ID: XYZ | the best of the best'
      end
    end

    context "human_readable_type returns \'Not Work\'" do
      before {
        allow(subject).to receive(:human_readable_type).and_return("Not Work")
      }
      it 'returns page title when not Work' do
        expect(subject.page_title).to eq 'Not Work | Fantastic Title | ID: XYZ | the best of the best'
      end
    end

    after {
      expect(I18n).to have_received(:t)
    }
  end


  describe "#tombstone" do
    before {
      allow(Solrizer).to receive(:solr_name).with("tombstone", :symbol).and_return "mausoleum"
    }

    context "when tombstone solr_name is blank" do
      before {
        subject.instance_variable_set(:@solr_document, {"mausoleum" => []})
      }
      it "returns nil" do
        expect(subject.tombstone.nil?) == true
      end
    end

    context "when tombstone solr_name has at least one value" do
      before {
        subject.instance_variable_set(:@solr_document, {"mausoleum" => ["raven", "crow"]})
      }
      it "returns the first value" do
        expect(subject.tombstone).to eq "raven"
      end
    end
  end


  describe "#tombstone_enabled?" do
    it "returns true" do
      expect(subject.tombstone_enabled?).to eq true
    end
  end
end
