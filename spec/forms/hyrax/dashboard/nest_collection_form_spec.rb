require 'rails_helper'

describe Hyrax::Forms::Dashboard::NestCollectionForm do

  let(:config) { Blacklight::Solr::Configuration.new }
  let(:repository) { Blacklight::Solr::Repository.new(:config) }

  subject{ described_class.new(context: repository) }

  describe "#save" do

    # TODO: test positive cases
    it "returns false when invalid" do

      allow(subject).to receive(:valid?).and_return( false )
      expect(subject.save).to eq false
    end

  end
end
