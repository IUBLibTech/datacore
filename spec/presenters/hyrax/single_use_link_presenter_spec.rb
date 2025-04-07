require 'rails_helper'

RSpec.describe Hyrax::SingleUseLinkPresenter do
  let(:link) { double(downloadKey: ['1', '2', '3', '4', '5', '6', '7']) }

  subject { described_class.new(link) }

  describe "delegates methods to link:" do
    it { is_expected.to delegate_method(:downloadKey).to(:link) }
    it { is_expected.to delegate_method(:expired?).to(:link) }
    it { is_expected.to delegate_method(:to_param).to(:link) }
  end

  pending "#human_readable_expiration"

  describe "#short_key" do

    it 'returns first six items of link downloadKey' do
      expect(subject.short_key).to eq ['1', '2', '3', '4', '5', '6']
    end
  end

  pending "#link_type"

  describe '#url_helper' do
    context "download? returns true" do
      before {
        allow(subject).to receive(:download?).and_return(true)
      }
      it 'returns download_single_use_link_url' do
        expect(subject.url_helper).to eq "download_single_use_link_url"
      end
    end

    context "download? returns false" do
      before {
        allow(subject).to receive(:download?).and_return(false)
      }
      it 'returns show show_single_use_link_url' do
        expect(subject.url_helper).to eq "show_single_use_link_url"
      end
    end
  end

end
