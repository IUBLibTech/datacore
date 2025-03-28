require 'rails_helper'

RSpec.describe Hyrax::SelectCollectionTypeListPresenter do
  let(:user) { FactoryBot.create :user }
  subject { described_class.new(user) }

  describe '#authorized_collection_types different values' do

    it 'authorized_collection_types greater than 1' do
      allow(subject).to receive(:authorized_collection_types).and_return(["Type1", "Type2"])

      expect(subject.many?).to eq true
      expect(subject.any?).to eq true
      expect(subject.first_collection_type).to eq "Type1"
    end

    it 'authorized_collection_types equal to 1' do
      allow(subject).to receive(:authorized_collection_types).and_return(["StandardType"])

      expect(subject.many?).to eq false
      expect(subject.any?).to eq true
      expect(subject.first_collection_type).to eq "StandardType"
    end

    it 'authorized_collection_types less than 1' do
      allow(subject).to receive(:authorized_collection_types).and_return([])

      expect(subject.many?).to eq false
      expect(subject.any?).to eq false
      expect(subject.first_collection_type).to eq nil
    end

  end
end