require 'rails_helper'

RSpec.describe Hyrax::AdminSetPresenter do
  let(:user) { FactoryBot.create :user }

  let(:user_key) { 'a_user_key' }
  let(:attributes) do {} end

  let(:solr_document) { SolrDocument.new(attributes) }
  let(:current_ability) { instance_double(Ability, current_user: user ) }
  let(:request) { double(host: 'example.org', base_url: 'http://example.org') }

  subject{ described_class.new(solr_document, current_ability, request) }

  describe "#any_items?" do
    it 'returns true when items exist' do
      allow(subject).to receive(:total_items).and_return(5)
      expect(subject.any_items?).to eq true
    end

    it 'returns false when items don\'t exist' do
      allow(subject).to receive(:total_items).and_return(0)
      expect(subject.any_items?).to eq false
    end
  end

end
