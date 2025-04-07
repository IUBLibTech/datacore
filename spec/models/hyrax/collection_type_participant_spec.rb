require 'rails_helper'

RSpec.describe Hyrax::CollectionTypeParticipant do

  describe 'constants' do
    it do
      expect( ::Hyrax::CollectionTypeParticipant::MANAGE_ACCESS).to eq 'manage'
      expect( ::Hyrax::CollectionTypeParticipant::CREATE_ACCESS).to eq 'create'
      expect( ::Hyrax::CollectionTypeParticipant::GROUP_TYPE).to eq 'group'
      expect( ::Hyrax::CollectionTypeParticipant::USER_TYPE).to eq 'user'
    end
  end


  describe '#manager?' do

    context "when access is MANAGE_ACCESS" do
      before {
        allow(subject).to receive(:access).and_return Hyrax::CollectionTypeParticipant::MANAGE_ACCESS
      }
      it "returns true" do
        expect(subject.manager?).to eq true
      end
    end

    context "when access is not MANAGE_ACCESS" do
      before {
        allow(subject).to receive(:access).and_return Hyrax::CollectionTypeParticipant::CREATE_ACCESS
      }
      it "returns false" do
        expect(subject.manager?).to eq false
      end
    end
  end

  describe '#creator?' do

    context "when access is CREATE_ACCESS" do
      before {
        allow(subject).to receive(:access).and_return Hyrax::CollectionTypeParticipant::CREATE_ACCESS
      }
      it "returns true" do
        expect(subject.creator?).to eq true
      end
    end

    context "when access is not CREATE_ACCESS" do
      before {
        allow(subject).to receive(:access).and_return Hyrax::CollectionTypeParticipant::MANAGE_ACCESS
      }
      it "returns false" do
        expect(subject.creator?).to eq false
      end
    end
  end


  describe '#label' do
    before do
      subject.agent_id = "Agent ID"
    end

    context "when agent_type is not GROUP_TYPE" do
      before {
        allow(subject).to receive(:agent_type).and_return Hyrax::CollectionTypeParticipant::USER_TYPE
      }
      it "returns agent_id" do
        expect(subject.label).to eq "Agent ID"
      end
    end

    context "when agent_type is GROUP_TYPE and agent_id not group name" do
      before {
        allow(subject).to receive(:agent_type).and_return Hyrax::CollectionTypeParticipant::GROUP_TYPE
      }
      it "returns agent_id" do
        expect(subject.label).to eq "Agent ID"
      end
    end

    context "when agent_type is GROUP_TYPE and agent_id is Ability.registered_group_name" do
      it "returns hyrax registered_users" do
        skip "Add test here"
      end
    end

    context "when agent_type is GROUP_TYPE and agent_id is Ability.admin_group_name" do
      it "returns hyrax admin_users" do
        skip "Add test here"
      end
    end
  end

end
