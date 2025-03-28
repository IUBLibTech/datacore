require 'rails_helper'

RSpec.describe Hyrax::InspectWorkPresenter do
  let(:user) { FactoryBot.create :user }
  let(:attributes) do {} end
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:current_ability) { instance_double(Ability, current_user: user ) }

  subject { described_class.new(solr_document, current_ability) }

  describe '#solr' do

    it 'returns string' do
      allow(subject.solr_document).to receive(:inspect).and_return("Solr document: inspected")
      expect(subject.solr).to eq 'Solr document: inspected'
    end
  end
end