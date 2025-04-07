require 'rails_helper'

RSpec.describe Hyrax::TrophyPresenter do
  let(:attributes) do { } end
  let(:solr_document) { SolrDocument.new(attributes) }

  subject { described_class.new(solr_document) }

  describe "delegates methods to solr_document:" do
    it { is_expected.to delegate_method(:to_s).to(:solr_document) }
    it { is_expected.to delegate_method(:thumbnail_path).to(:solr_document) }
  end

  pending "#self.find_by_user"
  pending "#self.document_model"


end
