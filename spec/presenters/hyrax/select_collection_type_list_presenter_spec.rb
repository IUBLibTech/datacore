require 'rails_helper'

RSpec.describe Hyrax::SelectCollectionTypeListPresenter do
  let(:user) { FactoryBot.create :user }
  subject { described_class.new(user) }

  describe "#many?" do
    context "when multiple authorized_collection_types" do
      before {
        allow(subject.authorized_collection_types).to receive(:size).and_return(2)
      }
      it 'returns true' do
        expect(subject.many?).to eq true
      end
    end

    context "when not multiple authorized_collection_types" do
      before {
        allow(subject.authorized_collection_types).to receive(:size).and_return(1)
      }
      it 'returns false' do
        expect(subject.many?).to eq false
      end
    end
  end

  describe '#any?' do
    context "authorized_collection_types 1 or more" do
      before {
        allow(subject).to receive(:authorized_collection_types).and_return(["Type1", "Type2"])
      }
      it 'returns true' do
        expect(subject.any?).to eq true
      end
    end

    context "no authorized_collection_types" do
      before {
        allow(subject).to receive(:authorized_collection_types).and_return([])
      }
      it 'returns false' do
        expect(subject.any?).to eq false
      end
    end
  end

  pending '#authorized_collection_types'


  describe '#first_collection_type' do

    context "authorized_collection_types equal to or greater than 1" do
      before {
        allow(subject).to receive(:authorized_collection_types).and_return(["Type1", "Type2"])
      }
      it 'returns first authorized_collection_type' do
        expect(subject.first_collection_type).to eq "Type1"
      end
    end

    context "no authorized_collection_types" do
      before {
        allow(subject).to receive(:authorized_collection_types).and_return([])
      }
      it 'returns nil' do
        expect(subject.first_collection_type).to eq nil
      end
    end
  end

end
