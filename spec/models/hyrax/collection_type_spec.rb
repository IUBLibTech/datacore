require 'rails_helper'

RSpec.describe Hyrax::CollectionType do

  describe 'constants' do
    it do
      expect( ::Hyrax::CollectionType::USER_COLLECTION_MACHINE_ID ).to eq 'user_collection'
      expect( ::Hyrax::CollectionType::ADMIN_SET_MACHINE_ID ).to eq 'admin_set'
    end
  end

  describe "#collections" do

    # TODO: test positive case
    it "returns empty array when gid has no value" do

      allow(subject).to receive(:gid).and_return( nil )
      expect(subject.collections).to eq []
    end
  end

  describe "#collections?" do

    it "returns true when collections has at least one item" do

      allow(subject).to receive(:collections).and_return( %w[this that] )
      expect(subject.collections?).to eq true
    end

    it "returns false when collections is empty" do

      allow(subject).to receive(:collections).and_return( [] )
      expect(subject.collections?).to eq false
    end
  end

  describe '#admin_set?' do

    it 'returns true when machine_id is ADMIN_SET_MACHINE_ID' do
      subject.machine_id = Hyrax::CollectionType::ADMIN_SET_MACHINE_ID

      expect( subject.admin_set? ).to eq true
    end

    it 'returns false when machine_id is USER_COLLECTION_MACHINE_ID' do
      subject.machine_id = Hyrax::CollectionType::USER_COLLECTION_MACHINE_ID

      expect( subject.admin_set? ).to eq false
    end
  end

  describe '#user_collection?'

    it 'returns false when machine_id is ADMIN_SET_MACHINE_ID' do
      subject.machine_id = Hyrax::CollectionType::ADMIN_SET_MACHINE_ID

      expect( subject.user_collection? ).to eq false
    end

    it 'returns true when machine_id is USER_COLLECTION_MACHINE_ID' do
      subject.machine_id = Hyrax::CollectionType::USER_COLLECTION_MACHINE_ID

      expect( subject.user_collection? ).to eq true
    end
  end


