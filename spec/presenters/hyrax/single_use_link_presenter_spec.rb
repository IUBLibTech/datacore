require 'rails_helper'

RSpec.describe Hyrax::SingleUseLinkPresenter do
  let(:link) { double(downloadKey: ['1', '2', '3', '4', '5', '6', '7']) }

  subject { described_class.new(link) }

  it { is_expected.to delegate_method(:downloadKey).to(:link) }
  it { is_expected.to delegate_method(:expired?).to(:link) }
  it { is_expected.to delegate_method(:to_param).to(:link) }

  describe "#short_key" do

    it 'returns first six items of link downloadKey' do
      expect(subject.short_key).to eq ['1', '2', '3', '4', '5', '6']
    end
  end


  describe '#url_helper' do

    it 'returns download etc.' do
      allow(subject).to receive(:download?).and_return(true)

      expect(subject.url_helper).to eq "download_single_use_link_url"
    end

    it 'returns show etc.' do
      allow(subject).to receive(:download?).and_return(false)

      expect(subject.url_helper).to eq "show_single_use_link_url"
    end

  end
end