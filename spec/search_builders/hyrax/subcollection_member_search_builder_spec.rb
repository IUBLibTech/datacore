require 'rails_helper'

describe Hyrax::SubcollectionMemberSearchBuilder do

  let(:subject) { described_class.new(scope: "scope", collection: OpenStruct.new(id: "PBJ-555")) }


  describe "#self.collection_membership_field" do
    it "returns string" do
      expect(Hyrax::SubcollectionMemberSearchBuilder.collection_membership_field).to eq 'member_of_collection_ids_ssim'
    end
  end


  describe "#self.default_processor_chain" do
    it "returns array" do
      expect(Hyrax::SubcollectionMemberSearchBuilder.default_processor_chain.include?(:member_of_collection)).to eq true
    end
  end


  describe "#initialize" do
    it "sets instance variables" do
      builder = Hyrax::SubcollectionMemberSearchBuilder.new(scope: "scope", collection: "collection")

      expect(builder.instance_variable_get(:@collection)).to eq "collection"
      expect(builder.instance_variable_get(:@page)).to eq 0
    end

    it "calls super" do
      allow(Blacklight::SearchBuilder).to receive(:new)

      Hyrax::SubcollectionMemberSearchBuilder.new(scope: "scope", collection: "collection")

      expect(Blacklight::SearchBuilder).to have_received(:new)
    end
  end


  describe "#member_of_collection" do
    before {
      allow(subject).to receive(:collection_membership_field).and_return "member_of_collection"
      subject.instance_variable_set(:@page, 2)
    }
    it "adds data to Hash as arrays" do
      params = {}
      subject.member_of_collection(params)

      expect(params[:fq]).to eq ["member_of_collection:PBJ-555"]
      expect(params[:page]).to eq ["page:2"]
    end
  end


  describe "#models" do
    before {
      allow(subject).to receive(:collection_classes).and_return "collection classes"
    }

    it "returns collection_classes" do
      expect(subject.models).to eq "collection classes"
    end
  end


end
