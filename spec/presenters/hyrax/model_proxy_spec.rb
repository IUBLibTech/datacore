require 'rails_helper'

class ModelMock
  include ::Hyrax::ModelProxy


  def initialize(solr_document)
    @solr_document = solr_document
  end
end

RSpec.describe Hyrax::ModelProxy do
  let(:attributes) do {} end
  let(:solr_document) { SolrDocument.new(attributes) }

  subject{ ModelMock.new(solr_document) }

  # TODO:  Add delegate method checks

  describe "#persisted?" do
    it 'returns true' do
      expect(subject.persisted?).to eq true
    end

  end
end