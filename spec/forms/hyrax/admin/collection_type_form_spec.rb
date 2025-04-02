require 'rails_helper'

describe Hyrax::Forms::Admin::CollectionTypeForm do

  let(:collection_type) { instance_double(Hyrax::CollectionType) }

  it "delegates" do

    is_expected.to delegate_method(:title).to(:collection_type)
    is_expected.to delegate_method(:description).to(:collection_type)
    is_expected.to delegate_method(:brandable).to(:collection_type)
    is_expected.to delegate_method(:discoverable).to(:collection_type)
    is_expected.to delegate_method(:nestable).to(:collection_type)
    is_expected.to delegate_method(:sharable).to(:collection_type)
    is_expected.to delegate_method(:share_applies_to_new_works).to(:collection_type)
    is_expected.to delegate_method(:require_membership).to(:collection_type)
    is_expected.to delegate_method(:allow_multiple_membership).to(:collection_type)
    is_expected.to delegate_method(:assigns_workflow).to(:collection_type)
    is_expected.to delegate_method(:assigns_visibility).to(:collection_type)
    is_expected.to delegate_method(:id).to(:collection_type)
    is_expected.to delegate_method(:collection_type_participants).to(:collection_type)
    is_expected.to delegate_method(:persisted?).to(:collection_type)
    is_expected.to delegate_method(:collections?).to(:collection_type)
    is_expected.to delegate_method(:admin_set?).to(:collection_type)
    is_expected.to delegate_method(:user_collection?).to(:collection_type)
    is_expected.to delegate_method(:badge_color).to(:collection_type)
  end

  describe "#all_settings_disabled?" do

    it "returns true when collections is true" do
      allow(subject).to receive(:collections?) { true }
      allow(subject).to receive(:admin_set?) { false }
      allow(subject).to receive(:user_collection?) { false }

      expect(subject.all_settings_disabled?).to eq true
    end

    it "returns true when admin_set is true" do
      allow(subject).to receive(:collections?) { false }
      allow(subject).to receive(:admin_set?) { true }
      allow(subject).to receive(:user_collection?) { false }

      expect(subject.all_settings_disabled?).to eq true
    end

    it "returns true when user_collections is true" do
      allow(subject).to receive(:collections?) { false }
      allow(subject).to receive(:admin_set?) { false }
      allow(subject).to receive(:user_collection?) { true }

      expect(subject.all_settings_disabled?).to eq true
    end

    it "returns false when collections, admin_set and user_collections are false" do
      allow(subject).to receive(:collections?) { false }
      allow(subject).to receive(:admin_set?) { false }
      allow(subject).to receive(:user_collection?) { false }

      expect(subject.all_settings_disabled?).to eq false
    end

  end

  describe "#share_options_disabled?" do

    it "returns true when all_settings_disabled?" do
      allow(subject).to receive(:all_settings_disabled?) { true }
      allow(subject).to receive(:sharable) { true }
    end

    it "returns true when not sharable" do
      allow(subject).to receive(:all_settings_disabled?) { false }
      allow(subject).to receive(:sharable) { false }
    end

    it "returns false when all_settings_disabled? is false and sharable" do
      allow(subject).to receive(:all_settings_disabled?) { false }
      allow(subject).to receive(:sharable) { true }
    end

  end
end
