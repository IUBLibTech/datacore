require 'rails_helper'

RSpec.describe Hyrax::CollectionPresenter do
  let(:user) { FactoryBot.create :user }

  let(:user_key) { 'a_user_key' }
  let(:attributes) do {} end

  let(:solr_document) { SolrDocument.new(attributes) }
  let(:current_ability) { instance_double(Ability, current_user: user ) }
  let(:request) { double(host: 'example.org', base_url: 'http://example.org') }

  subject{ described_class.new(solr_document, current_ability, request) }

  it { is_expected.to delegate_method(:stringify_keys).to(:solr_document) }
  it { is_expected.to delegate_method(:human_readable_type).to(:solr_document) }
  it { is_expected.to delegate_method(:collection?).to(:solr_document) }
  it { is_expected.to delegate_method(:representative_id).to(:solr_document) }
  it { is_expected.to delegate_method(:to_s).to(:solr_document) }
end
