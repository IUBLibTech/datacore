require 'rails_helper'

RSpec.describe Hyrax::InspectWorkPresenter do
  let(:user) { FactoryBot.create :user }
  let(:attributes) do {} end
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:current_ability) { instance_double(Ability, current_user: user ) }

  subject { described_class.new(solr_document, current_ability) }

  pending "#initialize"

  pending "#workflow"

  describe '#solr' do
    context "calls @solr_document.inspect" do
      before {
        subject.instance_variable_set(:@solr_document, OpenStruct.new(inspect: "Solr document: inspected"))
      }
      it 'returns value' do
        expect(subject.solr).to eq 'Solr document: inspected'
      end
    end
  end
end
