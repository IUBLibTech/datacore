require 'rails_helper'

class ModelMock
  include ::Hyrax::ModelProxy

end

RSpec.describe Hyrax::ModelProxy do
  let(:attributes) do {} end
  let(:solr_document) { SolrDocument.new(attributes) }

  subject{ ModelMock.new() }

  pending "delegates methods to solr_document:"


  describe "delegates methods to _delegated_to:" do
    [:model_name, :valid_child_concerns].each do
    |method|
      it "#{method}" do
        expect(subject).to delegate_method(method).to(:_delegated_to)
      end
    end
  end

  describe "#persisted?" do
    it 'returns true' do
      expect(subject.persisted?).to eq true
    end

  end

  pending "#to_model"

end