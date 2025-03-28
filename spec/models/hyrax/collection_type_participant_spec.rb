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

  before do
    subject.agent_id = "Agent ID"
  end

  describe '#manager?' do

    it "returns true when access is MANAGE_ACCESS" do

      subject.access = Hyrax::CollectionTypeParticipant::MANAGE_ACCESS
      expect(subject.manager?).to eq true
    end

    it "returns false when access is not MANAGE_ACCESS" do

      subject.access = Hyrax::CollectionTypeParticipant::CREATE_ACCESS
      expect(subject.manager?).to eq false
    end
  end

  describe '#creator?' do

    it "returns true when access is CREATE_ACCESS" do

      subject.access = Hyrax::CollectionTypeParticipant::CREATE_ACCESS
      expect(subject.creator?).to eq true
    end

    it "returns false when access is not CREATE_ACCESS" do

      subject.access = Hyrax::CollectionTypeParticipant::MANAGE_ACCESS
      expect(subject.creator?).to eq false
    end
  end

  describe '#label' do

    it "returns agent_id when agent_type is not GROUP_TYPE" do

      subject.agent_type = Hyrax::CollectionTypeParticipant::USER_TYPE
      expect(subject.label).to eq "Agent ID"
    end

    it "returns agent_id when agent_type is GROUP_TYPE and agent_id not group name" do

      subject.agent_type = Hyrax::CollectionTypeParticipant::GROUP_TYPE
      expect(subject.label).to eq "Agent ID"
    end

    # TODO:  test other cases for agent_id
  end

  end