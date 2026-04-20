require 'rails_helper'

describe Deepblue::ProvenancePath do

  subject { described_class.new( "path", "destination" ) }

  pending "#path_for_reference"


  describe "#initialize" do
    context "when object is a string" do
      it "sets object and destination_name as instance variables" do
        provenance_path = Deepblue::ProvenancePath.new("providence", "Rhode Island")

        expect(provenance_path.instance_variable_get(:@id)).to eq "providence"
        expect(provenance_path.instance_variable_get(:@destination_name)).to eq "Rhode Island"
      end
    end

    context "when object is not a string" do
      it "sets object.id and destination_name as instance variables" do
        provenance = Deepblue::ProvenancePath.new(OpenStruct.new(id: "providencetown"), "Massachusetts")

        expect(provenance.instance_variable_get(:@id)).to eq "providencetown"
        expect(provenance.instance_variable_get(:@destination_name)).to eq "Massachusetts"
      end
    end
  end


  describe "#provenance_path" do
    before{
      allow(subject).to receive(:path_prefix).and_return "path prefix"
      allow(subject).to receive(:file_name).and_return "file name"
    }
    it "returns string" do
      expect(subject.provenance_path).to eq "path prefix-file name"
    end
  end


  # private methods

  describe "#root_path" do
    before {
      allow(subject).to receive(:provenance_path).and_return "path"
      allow(Pathname).to receive(:new).with("path").and_return OpenStruct.new(dirname: "path dirname")
    }
    it "returns Pathname dirname of provenance_path" do
      expect(subject.send(:root_path)).to eq "path dirname"
    end
  end


  describe "#path_prefix" do
    before {
      allow(Hyrax.config).to receive(:derivatives_path).and_return "derivatives path"
      allow(subject).to receive(:pair_path).and_return "pair path"
      allow(Pathname).to receive(:new).with("derivatives path").and_return ["derivatives ", " consequences"]
    }
    it "returns string" do
      expect(subject.send(:path_prefix)).to eq "derivatives pair path consequences"
    end
  end


  describe "#pair_path" do
    it "returns string" do
      expect(subject.send(:pair_path)).to eq "pa/th"
    end
  end


  describe "#file_name" do
    context "when destination_name has a value" do
      before {
        allow(subject).to receive(:extension).and_return(".mov")
      }
      it "returns string" do
        expect(subject.send(:file_name)).to eq "destination.mov"
      end
    end

    context "when destination_name has no value or false" do
      subject { described_class.new( "path") }

      it "returns blank" do
        expect(subject.send(:file_name)).to be_blank
      end
    end
  end


  describe "#extension" do
    it "returns string" do
      expect(subject.send(:extension)).to eq ".log"
    end
  end

end
