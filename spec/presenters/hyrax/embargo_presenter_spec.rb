require 'rails_helper'

class MockSolrDocument

  def fetch(text, array)
    ["depositor1", "depositor2"]
  end
end


RSpec.describe Hyrax::EmbargoPresenter do

  subject { described_class.new("solar") }

  describe "delegates methods to solr_document:" do
    [:visibility, :to_s].each do
    |method|
      it "#{method}" do
        expect(subject).to delegate_method(method).to(:solr_document)
      end
    end
  end


  describe "#human_readable_type" do
    context "when solr_document.human_readable_type is NOT 'Data Set'" do
      before {
        allow(subject).to receive(:solr_document).and_return OpenStruct.new(human_readable_type: "Dissertation")
      }
      it "returns solr_document.human_readable_type" do
        expect(subject.human_readable_type).to eq "Dissertation"
      end
    end

    context "when solr_document.human_readable_type is 'Data Set'" do
      before {
        allow(subject).to receive(:solr_document).and_return OpenStruct.new(human_readable_type: "Data Set")
      }
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


  describe "#embargo_depositor" do
    before {
      allow(subject).to receive(:solr_document).and_return MockSolrDocument.new
    }
    it "returns first item of depositor_ssim" do
      expect(subject.embargo_depositor).to eq "depositor1"
    end
  end


  describe "#embargo_release_date" do
    context "when embargo release date is blank" do
      before {
        allow(subject).to receive(:solr_document).and_return OpenStruct.new(embargo_release_date: "")
      }
      it "returns blank" do
        expect(subject.embargo_release_date).to be_blank
      end
    end

    context "when embargo release date is NOT blank" do
      before {
        allow(subject).to receive(:solr_document).and_return OpenStruct.new(embargo_release_date: DateTime.new(2025, 11, 20, 8, 0, 0))
      }
      it "returns string formatted embargo release date" do
        expect(subject.embargo_release_date).to eq "Thu, 20 Nov 2025 08:00:00 +0000"
      end
    end
  end


  describe "#visibility_after_embargo" do
    before {
      allow(subject).to receive(:solr_document).and_return MockSolrDocument.new
    }
    it "returns first item of visibility_after_embargo_ssim" do
      expect(subject.embargo_depositor).to eq "depositor1"
    end
  end


  describe "#embargo_history" do
    before {
      allow(subject).to receive(:solr_document).and_return "embargo_history_ssim" => "embargo history"
    }
    it "returns embargo_history_ssim" do
      expect(subject.embargo_history).to eq "embargo history"
    end
  end

end
