require 'rails_helper'

RSpec.describe Hyrax::EmbargoPresenter do
  let(:solr_hash) { {} } # overriden in examples as needed
  let(:solr_document) { SolrDocument.new(solr_hash) }
  subject { described_class.new(solr_document) }

  describe "delegates methods to solr_document:" do
    [:visibility, :to_s].each do
    |method|
      it "#{method}" do
        expect(subject).to delegate_method(method).to(:solr_document)
      end
    end
  end

  describe "#human_readable_type" do
    let(:solr_hash) { { human_readable_type_tesim: human_readable_type } }
    context "when solr_document.human_readable_type is NOT 'Data Set'" do
      let(:human_readable_type) { "Dissertation" }
      it "returns solr_document.human_readable_type" do
        expect(subject.human_readable_type).to eq solr_document.human_readable_type
      end
    end
    context "when solr_document.human_readable_type is 'Data Set'" do
      let(:human_readable_type) { "Data Set" }
      it "returns 'Work'" do
        expect(subject.human_readable_type).to eq "Work"
      end
    end
  end

  describe "#initialize" do
    it "sets @solr_document variable" do
      embargo = Hyrax::EmbargoPresenter.new("solr_document")
      expect(embargo.instance_variable_get(:@solr_document)).to eq "solr_document"
    end
  end

  { embargo_depositor: { depositor_ssim: ['depositor1', 'depositor2'] },
    visibility_after_embargo: { visibility_after_embargo_ssim: ['visibility1', 'visibility2'] }
  }.each do |method, hash|
    describe "#{method}" do
      context "without values present" do
        it "returns nil" do
          expect(subject.send(method)).to be_nil
        end
      end
      context "with values present" do
        let(:solr_hash) { hash }
        it "returns first #{hash.keys.first} value" do
          expect(subject.send(method)).to eq hash[hash.keys.first].first
        end
      end
    end
  end

  describe "#embargo_release_date" do
    context "when embargo release date is blank" do
      it "returns blank" do
        expect(subject.embargo_release_date).to be_blank
      end
    end

    context "when embargo release date is NOT blank" do
      let(:date_value) { DateTime.new(2025, 11, 20, 8, 0, 0).to_s }
      let(:date_string) { "20 Nov 2025" } # rfc822 format for Date value
      let(:solr_hash) { { embargo_release_date_dtsi: date_value } }
      it "returns string formatted embargo release date" do
        expect(subject.embargo_release_date).to eq date_string
      end
    end
  end

  describe "#embargo_history" do
    let(:embargo_history) { "embargo history" }
    let(:solr_hash) { { embargo_history_ssim: embargo_history } }
    it "returns embargo_history_ssim" do
      expect(subject.embargo_history).to eq embargo_history
    end
  end
end
