require 'rails_helper'

RSpec.describe ProvenanceLogPresenter do

  let(:controller) { instance_double(ProvenanceLogController) }

  subject { described_class.new(controller: controller) }

  describe "delegates methods to controller:" do
    [:id, :id_msg, :id_invalid, :id_deleted, :id_valid?, :deleted_ids, :deleted_id_to_key_values_map].each do
    |method|
      it "#{method}" do
        expect(subject).to delegate_method(method).to(:controller)
      end
    end
  end

  describe "#display_title" do
    it "returns empty string when empty array" do
      expect(subject.display_title []).to eq ""
    end

    it "returns whitespace delimited concatenated string of array" do
      expect(subject.display_title ["uno", "dos", "tres"]).to eq "uno dos tres"
    end
  end


  describe "#provenance_log_entries?" do
    context "if id is blank" do
      before {
         allow(controller).to receive(:id).and_return(nil)
      }
      it "returns false" do
        expect(subject.provenance_log_entries?).to eq false
      end
    end

    context "if id is not blank" do
      it "sets file path" do
        skip "Add a test"
      end
    end
  end


  describe '#provenance_log_display_enabled?' do
    it 'returns true' do
      expect(subject.provenance_log_display_enabled?).to eq true
    end
  end


  pending "#url_for"


  describe "#url_for_deleted" do
    it 'calls url_for' do
      expect(subject).to receive(:url_for).with(action: "show", id: 101, only_path: true)
      subject.url_for_deleted(id: 101)
    end
  end

end
