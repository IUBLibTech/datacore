require 'rails_helper'

RSpec.describe Hyrax::SelectTypeListPresenter do
  let(:user) { FactoryBot.create :user }
  let(:row_presenter) { SelectTypePresenter }

  subject { described_class.new(user) }


  describe 'authorized_collection_types different values' do

    it 'authorized_collection_types greater than 1' do
      allow(subject).to receive(:authorized_models).and_return(["Type1", "Type2"])

      expect(subject.many?).to eq true
      expect(subject.first_model).to eq "Type1"
    end

    it 'authorized_collection_types equal to 1' do
      allow(subject).to receive(:authorized_models).and_return(["StandardType"])

      expect(subject.many?).to eq false
      expect(subject.first_model).to eq "StandardType"
    end

    it 'authorized_collection_types less than 1' do
      allow(subject).to receive(:authorized_models).and_return([])

      expect(subject.many?).to eq false
      expect(subject.first_model).to eq nil
    end

  end
end