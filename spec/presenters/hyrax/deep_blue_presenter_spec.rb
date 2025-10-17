require 'rails_helper'

RSpec.describe Hyrax::DeepbluePresenter do
  let(:user) { FactoryBot.create :user }
  let(:attributes) do {} end
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:current_ability) { instance_double(Ability, current_user: user ) }

  subject { described_class.new(solr_document, current_ability) }

  describe '#box_enabled?' do
    it 'returns false' do
      expect(subject.box_enabled?).to eq false
    end
  end

  describe '#display_provenance_log_enabled?' do
    it 'returns false' do
      expect(subject.display_provenance_log_enabled?).to eq false
    end
  end

  describe '#doi_minting_enabled?' do
    it 'returns false' do
      expect(subject.doi_minting_enabled?).to eq false
    end
  end

  describe '#globus_download_enabled?' do
    it 'returns false' do
      expect(subject.globus_download_enabled?).to eq false
    end
  end

  describe '#human_readable_type' do
    it 'returns Work text' do
      expect(subject.human_readable_type).to eq 'Work'
    end
  end

  describe '#zip_download_enabled?' do
    it 'returns false' do
      expect(subject.zip_download_enabled?).to eq false
    end
  end
end
