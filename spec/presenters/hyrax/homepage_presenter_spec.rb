require 'rails_helper'

RSpec.describe Hyrax::HomepagePresenter do
  let(:user) { FactoryBot.create :user }
  let(:current_ability) { instance_double(Ability, current_user: user ) }
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:collections) { Hyrax::CollectionSearchBuilder.new(self).rows(1) }
  subject{ described_class.new(current_ability, collections) }

  pending "#display_share_button?"

  describe "#create_work_presenter" do
    it 'is a SelectTypeListPresenter' do
      expect(subject.create_work_presenter).to be_kind_of Hyrax::SelectTypeListPresenter
    end
  end

  pending "#create_many_work_types?"


  describe "#draw_select_work_modal?" do
    context "display_share_button? only" do
      before {
        allow(subject).to receive(:display_share_button?).and_return true
        allow(subject).to receive(:create_many_work_types?).and_return false
      }
      it "returns false" do
        expect(subject.draw_select_work_modal?).to eq false
      end
    end

    context "create_many_work_types? only" do
      before {
        allow(subject).to receive(:display_share_button?).and_return false
        allow(subject).to receive(:create_many_work_types?).and_return true
      }
      it "returns false" do
        expect(subject.draw_select_work_modal?).to eq false
      end
    end

    context "display_share_button? && create_many_work_types?" do
      before {
        allow(subject).to receive(:display_share_button?).and_return true
        allow(subject).to receive(:create_many_work_types?).and_return true
      }
      it "returns true" do
        expect(subject.draw_select_work_modal?).to eq true
      end
    end
  end


  describe "#first_work_type" do
    context "create_work_presenter has at least one model" do
      before {
        allow(subject.create_work_presenter).to receive(:authorized_models).and_return ["Uno", "Dos"]
      }
      it "returns first model" do
        expect(subject.first_work_type).to eq "Uno"
      end
    end
  end


end
