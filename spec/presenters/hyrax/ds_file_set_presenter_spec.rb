# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::DsFileSetPresenter do
  subject { described_class.new(double, double) }
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:request) { double(host: 'example.org', base_url: 'http://example.org') }

  let(:ability) { double Ability }
  let(:presenter) { described_class.new(solr_document, ability, request) }

  describe "delegates methods to solr_document:" do
    [:doi, :doi_the_correct_one, :doi_minted?, :doi_minting_enabled?, :doi_pending?, :file_size, :file_size_human_readable,
     :original_checksum, :mime_type, :title, :virus_scan_service, :virus_scan_status, :virus_scan_status_date].each do
    |method|
      it "#{method}" do
        expect(subject).to delegate_method(method).to(:solr_document)
      end
    end
  end

  pending "#relative_url_root"
  pending "#parent_doi_minted?"


  describe '#display_provenance_log_enabled?' do
     it 'returns true' do
        expect(subject.display_provenance_log_enabled?).to eq true
     end
  end

  pending "#provenance_log_entries?"
  pending "#parent_public?"


  describe "#first_title" do
    context "when the document has no title" do
      before {
        allow(subject).to receive(:title).and_return([])
      }
      it "returns string \'File\'" do
        expect(subject.first_title).to eq "File"
      end
    end

    context "when the document has at least one title" do
      before {
        allow(subject).to receive(:title).and_return(["Descriptive Title"])
      }
      it "returns first title" do
        expect(subject.first_title).to eq "Descriptive Title"
      end
    end
  end

  pending "#link_name"
  pending "#file_name"
  pending "#file_size_too_large_to_download?"

end
