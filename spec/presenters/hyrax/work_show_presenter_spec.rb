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

  describe '#page_title' do

    it 'returns page title when Work' do
      allow(subject).to receive(:human_readable_type).and_return("Work")
      expect(subject.page_title).to eq 'Data Set | Fantastic Title | ID: XYZ | DataCORE'
    end


    it 'returns page title when not Work' do
      allow(subject).to receive(:human_readable_type).and_return("Not Work")
      expect(subject.page_title).to eq 'Not Work | Fantastic Title | ID: XYZ | DataCORE'
    end
  end

end
