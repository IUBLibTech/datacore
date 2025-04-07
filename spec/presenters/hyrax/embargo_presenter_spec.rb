require 'rails_helper'

RSpec.describe Hyrax::EmbargoPresenter do

  let(:attributes) do
    { "id" => '777',
      "depositor_ssim" => ['Clara Snow', 'Matthew Ice'],
      "visibility_after_embargo_ssim" => ['limited visibility'],
      "embargo_history_ssim" => 'An historical document' }
  end

  let(:solr_document) { SolrDocument.new(attributes) }

  subject{ described_class.new(solr_document) }


  describe "delegates methods to solr_document:" do
    it { is_expected.to delegate_method(:visibility).to(:solr_document) }
    it { is_expected.to delegate_method(:to_s).to(:solr_document) }
  end

  describe '#human_readable_type' do
    context "if Data Set" do
      before {
        allow(subject.solr_document).to receive(:human_readable_type).and_return("Data Set")
      }
      it 'returns Work' do
        expect(subject.human_readable_type).to eq 'Work'
      end
    end

    context "if not Data Set" do
      before {
        allow(subject.solr_document).to receive(:human_readable_type).and_return("Not Data Set")
      }
      it 'returns document.human_readable_type' do
        expect(subject.human_readable_type).to eq 'Not Data Set'
      end
    end
  end


  describe '#embargo_depositor' do
    it 'returns first element of attribute depositor_ssim' do
      expect(subject.embargo_depositor).to eq 'Clara Snow'
    end
  end


  describe '#embargo_release_date' do
    context "if no embargo_release_date" do
      before {
        allow(subject.solr_document).to receive(:embargo_release_date).and_return(nil)
      }
      it 'returns nil' do
        expect(subject.embargo_release_date).to eq nil
      end
    end

    context "if embargo_release_date" do
      before {
        allow(subject.solr_document).to receive(:embargo_release_date).and_return(DateTime.new(2021, 1, 2))
      }
      it 'returns formatted embargo_release_date' do
        expect(subject.embargo_release_date).to eq "Sat, 02 Jan 2021 00:00:00 +0000"
      end
    end
  end


  describe '#visibility_after_embargo' do
    it 'returns first element of attribute visibility_after_embargo_ssim' do
      expect(subject.visibility_after_embargo).to eq 'limited visibility'
    end
  end

  describe '#embargo_history' do
    it 'returns attribute embargo_history_ssim' do
      expect(subject.embargo_history).to eq 'An historical document'
    end
  end
end
