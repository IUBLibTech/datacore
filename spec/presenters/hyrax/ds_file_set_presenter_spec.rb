# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::DsFileSetPresenter do
  subject { described_class.new(double, double) }
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:request) { double(host: 'example.org', base_url: 'http://example.org') }

  let(:ability) { double Ability }
  let(:presenter) { described_class.new(solr_document, ability, request) }

  it { is_expected.to delegate_method(:doi).to(:solr_document) }
  it { is_expected.to delegate_method(:doi_the_correct_one).to(:solr_document) }
  it { is_expected.to delegate_method(:doi_minted?).to(:solr_document) }
  it { is_expected.to delegate_method(:doi_minting_enabled?).to(:solr_document) }
  it { is_expected.to delegate_method(:doi_pending?).to(:solr_document) }
  it { is_expected.to delegate_method(:file_size).to(:solr_document) }
  it { is_expected.to delegate_method(:file_size_human_readable).to(:solr_document) }
  it { is_expected.to delegate_method(:original_checksum).to(:solr_document) }
  it { is_expected.to delegate_method(:mime_type).to(:solr_document) }
  it { is_expected.to delegate_method(:title).to(:solr_document) }
  it { is_expected.to delegate_method(:virus_scan_service).to(:solr_document) }
  it { is_expected.to delegate_method(:virus_scan_status).to(:solr_document) }
  it { is_expected.to delegate_method(:virus_scan_status_date).to(:solr_document) }

  describe '#display_provenance_log_enabled?' do
       it 'returns true' do
          expect(subject.display_provenance_log_enabled?).to eq true
       end
  end

end
