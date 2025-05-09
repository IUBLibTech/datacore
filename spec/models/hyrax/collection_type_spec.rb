require 'rails_helper'

RSpec.describe Hyrax::CollectionType do

  describe 'constants' do
    it do
      expect( ::Hyrax::CollectionType::USER_COLLECTION_MACHINE_ID ).to eq 'user_collection'
      expect( ::Hyrax::CollectionType::ADMIN_SET_MACHINE_ID ).to eq 'admin_set'
    end
  end

  pending "#title="
  pending "#self.find_by_gid"
  pending "#self.find_by_gid!"
  pending "#gid"

  describe "#collections" do
    context "when gid returns no value" do
      before {
        allow(subject).to receive(:gid).and_return( nil )
      }
      it "returns empty array " do
        expect(subject.collections).to be_empty
      end
    end

    context "when gid returns a value" do
      it "returns hyrax gid value" do
        skip "Add test here"
      end
    end
  end

  describe "#collections?" do
    context "when collections has at least one item" do
      before {
        allow(subject).to receive(:collections).and_return( %w[this that] )
      }
      it "returns true " do
        expect(subject.collections?).to eq true
      end
    end

    context "when collections is empty" do
      before {
        allow(subject).to receive(:collections).and_return( [] )
      }
      it "returns false " do
        expect(subject.collections?).to eq false
      end
    end
  end

  describe '#admin_set?' do
    context "when machine_id is ADMIN_SET_MACHINE_ID" do
      before {
        allow(subject).to receive(:machine_id).and_return( Hyrax::CollectionType::ADMIN_SET_MACHINE_ID )
      }
      it 'returns true' do
        expect( subject.admin_set? ).to eq true
      end
    end

    context "when machine_id is USER_COLLECTION_MACHINE_ID" do
      before {
        allow(subject).to receive(:machine_id).and_return( Hyrax::CollectionType::USER_COLLECTION_MACHINE_ID )
      }
      it 'returns false' do
        expect( subject.admin_set? ).to eq false
      end
    end
  end

  describe '#user_collection?' do
    context "when machine_id is ADMIN_SET_MACHINE_ID" do
      before {
        allow(subject).to receive(:machine_id).and_return( Hyrax::CollectionType::ADMIN_SET_MACHINE_ID )
      }
      it 'returns false' do
        expect( subject.user_collection? ).to eq false
      end
    end

    context "when machine_id is USER_COLLECTION_MACHINE_ID" do
      before {
        allow(subject).to receive(:machine_id).and_return( Hyrax::CollectionType::USER_COLLECTION_MACHINE_ID )
      }
      it 'returns true' do
        expect( subject.user_collection? ).to eq true
      end
    end
  end

  pending "#self.any_nestable?"
  pending "#self.find_or_create_default_collection_type"
  pending "#self.find_or_create_admin_set_type"

end
