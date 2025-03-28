require 'rails_helper'

RSpec.describe ProvenanceLogPresenter do

  let(:controller) { instance_double(ProvenanceLogController) }

  subject { described_class.new(controller: controller) }

  it { is_expected.to delegate_method(:id).to(:controller) }
  it { is_expected.to delegate_method(:id_msg).to(:controller) }
  it { is_expected.to delegate_method(:id_invalid).to(:controller) }
  it { is_expected.to delegate_method(:id_deleted).to(:controller) }
  it { is_expected.to delegate_method(:id_valid?).to(:controller) }
  it { is_expected.to delegate_method(:deleted_ids).to(:controller) }
  it { is_expected.to delegate_method(:deleted_id_to_key_values_map).to(:controller) }

  describe "#display_title" do

    it "returns empty string when empty array" do
      expect(subject.display_title []).to eq ""
    end

    it "returns whitespace delimited concatenated string of array" do
      expect(subject.display_title ["uno", "dos", "tres"]).to eq "uno dos tres"
    end
  end


  describe '#provenance_log_display_enabled??' do

    it 'returns true' do
      expect(subject.provenance_log_display_enabled?).to eq true
    end
  end


  describe "#url_for_deleted" do

    it 'calls url_for' do
      expect(subject).to receive(:url_for).with(action: "show", id: 101, only_path: true)
      subject.url_for_deleted(id: 101)
    end
  end

end
