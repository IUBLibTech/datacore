require 'rails_helper'

describe Hyrax::Forms::Dashboard::NestCollectionForm do

  let(:parent) { Collection.new }
  let(:child) { Collection.new }
  let(:config) { Blacklight::Solr::Configuration.new }
  let(:repository) { Blacklight::Solr::Repository.new(:config) }

  subject{ described_class.new(parent: parent, child: child, context: repository) }

  describe "#save" do

    context "when invalid" do
      before {
        allow(subject).to receive(:valid?).and_return( false )
      }
      it "returns false" do
        expect(subject.save).to eq false
      end
    end

    context "when valid" do
      before {
        allow(subject).to receive(:valid?).and_return( true )
      }
      it "returns function result" do
        skip "Add test here"
      end
    end
  end

  pending "#available_child_collections"

  pending "#available_parent_collections"

  pending "#validate_add"

  pending "#remove"
end
