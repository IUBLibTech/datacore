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


  describe "#initialize" do
    it "sets instance variable to arguments" do
     ProvenanceLogPresenter.new controller: "controller"

      subject.instance_variable_get(:@controller) == "controller"
    end
  end


  describe "#display_title" do
    context "when argument is blank" do
      it "returns empty string" do
        expect(subject.display_title []).to be_blank
      end
    end

    context "when argument is array of strings" do
      it "returns whitespace delimited concatenated string of array values" do
        expect(subject.display_title ["uno", "dos", "tres"]).to eq "uno dos tres"
      end
    end
  end


  describe "#provenance_log_entries?" do
    context "if id is blank" do
      before {
         allow(controller).to receive(:id).and_return(nil)
      }
      it "returns false" do
        expect(::Deepblue::ProvenancePath).not_to receive(:path_for_reference)

        expect(subject.provenance_log_entries?).to eq false
      end
    end

    context "if id is not blank" do
      before {
        allow(controller).to receive(:id).and_return(3001)
        allow(::Deepblue::ProvenancePath).to receive(:path_for_reference).with(3001).and_return "file path"
      }

      context "when file exists" do
        before {
          allow(File).to receive(:exist?).and_return true
        }
        it "returns true" do
          expect(subject.provenance_log_entries?).to eq true
        end
      end

      context "when file does not exist" do
        before {
          allow(File).to receive(:exist?).and_return false
        }
        it "returns false" do
          expect(subject.provenance_log_entries?).to eq false
        end
      end

      after {
        expect(::Deepblue::ProvenancePath).to have_received(:path_for_reference)
      }
    end
  end


  describe '#provenance_log_display_enabled?' do
    it 'returns true' do
      expect(subject.provenance_log_display_enabled?).to eq true
    end
  end


  describe "#url_for" do
    # Could not stub Rails.application.routes.url_helpers.url_for
    it "returns url for provenance log with id" do
      expect(subject.url_for(action: "show", id: 50)).to eq "/provenance_log/50"
    end
  end


  describe "#url_for_deleted" do
    it 'calls url_for' do
      expect(subject).to receive(:url_for).with(action: "show", id: 101, only_path: true)
      subject.url_for_deleted(id: 101)
    end
  end

end
