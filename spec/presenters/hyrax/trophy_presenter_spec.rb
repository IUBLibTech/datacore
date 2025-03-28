require 'rails_helper'

RSpec.describe Hyrax::TrophyPresenter do
  let(:attributes) do { } end
  let(:solr_document) { SolrDocument.new(attributes) }

  subject { described_class.new(solr_document) }

  it { is_expected.to delegate_method(:to_s).to(:solr_document) }
  it { is_expected.to delegate_method(:thumbnail_path).to(:solr_document) }



end