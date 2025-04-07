require 'rails_helper'

RSpec.describe Hyrax::SelectTypeListPresenter do
  let(:user) { FactoryBot.create :user }
  let(:row_presenter) { SelectTypePresenter }

  subject { described_class.new(user) }

  describe "#many?" do
    context "when multiple authorized_models" do
      before {
        allow(subject.authorized_models).to receive(:size).and_return(2)
      }
      it 'returns true' do
        expect(subject.many?).to eq true
      end
    end

    context "when not multiple authorized_models" do
      before {
        allow(subject.authorized_models).to receive(:size).and_return(1)
      }
      it 'returns false' do
        expect(subject.many?).to eq false
      end
    end
  end

  describe "#authorized_models" do
    context "current_user is nil" do
      before {
        subject { described_class.new(nil) }
      }
      it "returns an empty array" do
        expect(subject.authorized_models).to be_empty
      end
    end

    context "current_user exists" do
      it "returns authorized_models" do
        skip "Add a test"
      end
    end
  end

  describe 'first_model' do

    context "authorized_models exist" do
      before {
        allow(subject).to receive(:authorized_models).and_return(["Type1", "Type2"])
      }
      it 'returns first model' do
        expect(subject.first_model).to eq "Type1"
      end
    end

    context "no authorized_models" do
      before {
        allow(subject).to receive(:authorized_models).and_return([])
      }
      it 'returns nil' do
        expect(subject.first_model).to eq nil
      end
    end
  end

  pending "#each"

end
