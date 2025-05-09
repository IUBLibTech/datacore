require 'rails_helper'

describe Hyrax::Forms::Admin::CollectionTypeForm do

  let(:collection_type) { instance_double(Hyrax::CollectionType) }

  describe "delegates methods to collection_type" do
    [:title, :description, :brandable, :discoverable, :nestable, :sharable, :share_applies_to_new_works,
     :require_membership, :allow_multiple_membership, :assigns_workflow, :assigns_visibility, :id,
     :collection_type_participants, :persisted?, :collections?, :admin_set?, :user_collection?, :badge_color].each do
    |method|
      it "#{method}" do
        expect(subject).to delegate_method(method).to(:collection_type)
      end
    end
  end

  describe "#all_settings_disabled?" do

    context "when collections is true" do
      before {
        allow(subject).to receive(:collections?) { true }
        allow(subject).to receive(:admin_set?) { false }
        allow(subject).to receive(:user_collection?) { false }
      }
      it "returns true" do
        expect(subject.all_settings_disabled?).to eq true
      end
    end

    context "when admin_set is true" do
      before {
        allow(subject).to receive(:collections?) { false }
        allow(subject).to receive(:admin_set?) { true }
        allow(subject).to receive(:user_collection?) { false }
      }
      it "returns true" do
        expect(subject.all_settings_disabled?).to eq true
      end
    end

    context "when user_collections is true" do
      before {
        allow(subject).to receive(:collections?) { false }
        allow(subject).to receive(:admin_set?) { false }
        allow(subject).to receive(:user_collection?) { true }
      }
      it "returns true" do
        expect(subject.all_settings_disabled?).to eq true
      end
    end

    context "when collections, admin_set and user_collections are false" do
      before {
        allow(subject).to receive(:collections?) { false }
        allow(subject).to receive(:admin_set?) { false }
        allow(subject).to receive(:user_collection?) { false }
      }
      it "returns false" do
        expect(subject.all_settings_disabled?).to eq false
      end
    end
  end

  describe "#share_options_disabled?" do

    context "when all_settings_disabled?" do
      before {
        allow(subject).to receive(:all_settings_disabled?) { true }
        allow(subject).to receive(:sharable) { true }
      }
      it "returns true" do
        expect(subject.share_options_disabled?).to eq true
      end
    end

    context "when not sharable" do
      before {
        allow(subject).to receive(:all_settings_disabled?) { false }
        allow(subject).to receive(:sharable) { false }
      }
      it "returns true" do
        expect(subject.share_options_disabled?).to eq true
      end
    end

    context "when sharable and not all_settings_disabled?" do
      before {
        allow(subject).to receive(:all_settings_disabled?) { false }
        allow(subject).to receive(:sharable) { true }
      }
      it "returns false " do
        expect(subject.share_options_disabled?).to eq false
      end
    end
  end
end
