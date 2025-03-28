require 'rails_helper'

RSpec.describe Hyrax::LeasePresenter do
  let(:attributes) do
    { "id" => '999',
      "visibility_after_lease_ssim" => ['Some Visibility', 'No Visibility'],
      "lease_history_ssim" => "Lease History" }
  end
  let(:solr_document) { SolrDocument.new(attributes) }

  subject { described_class.new(solr_document) }

  it { is_expected.to delegate_method(:human_readable_type).to(:solr_document) }
  it { is_expected.to delegate_method(:visibility).to(:solr_document) }
  it { is_expected.to delegate_method(:to_s).to(:solr_document) }

  describe '#lease_expiration_date' do

    it 'returns expiration date if present' do
      allow(subject.solr_document).to receive(:lease_expiration_date).and_return(DateTime.new(2025, 2, 25))

      expect(subject.lease_expiration_date).to eq 'Tue, 25 Feb 2025 00:00:00 +0000'
    end

    it 'returns keys if expiration date not present' do
      allow(subject.solr_document).to receive(:lease_expiration_date).and_return(nil)

      expect(subject.lease_expiration_date).to eq ["id", "visibility_after_lease_ssim", "lease_history_ssim"]
    end
  end

  describe '#visibility_after_lease' do

    it 'returns first value of visibility_after_lease_ssim array' do
      expect(subject.visibility_after_lease).to eq 'Some Visibility'
    end
  end

  describe '#lease_history' do

    it 'returns lease_history_ssim value' do
      expect(subject.lease_history).to eq "Lease History"
    end
  end
end