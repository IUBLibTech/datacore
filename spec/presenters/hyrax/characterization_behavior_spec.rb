require 'rails_helper'

class CharacterizationMock
  include ::Hyrax::CharacterizationBehavior

  attr_accessor :solr_document

  def initialize(solr_document)
    @solr_document = solr_document
  end
end

RSpec.describe Hyrax::CharacterizationBehavior do
  let(:attributes) { }
  let(:solr_document) { SolrDocument.new(attributes) }

  subject { CharacterizationMock.new solr_document }

  pending "delegates methods to solr_document:"

  describe "#characterized?" do
    context "characterization metadata values not empty" do
      before {
        allow(subject).to receive(:characterization_metadata).and_return( {"first" => "one", "second" => "two", "third" => "three"} )
      }
      it "returns true" do
        expect(subject.characterized?).to eq true
      end
    end

    context "characterization metadata values empty" do
      before {
        allow(subject).to receive(:characterization_metadata).and_return( {"first" => nil, "second" => nil } )
      }
      it "returns false" do
        expect(subject.characterized?).to eq false
      end
    end
  end

  pending "#characterization_metadata"

  describe "#additional_characterization_metadata" do
    it "returns empty hash" do
      expect(subject.characterization_metadata).to be_empty
    end
  end

  describe "#label_for_term" do
    it "returns capitalized label for term" do
      expect(subject.label_for_term "the last hop-a-long rabbit").to eq "The Last Hop A Long Rabbit"
    end
  end

  pending "#primary_characterization_values"
  pending "#secondary_characterization_values"

end
