require 'rails_helper'

RSpec.describe Hyrax::Admin::UsersPresenter do

  pending "#users"

  describe "#user_count" do
    context "when there are users" do
      before {
        allow(subject.users).to receive(:count).and_return(77)
      }
      it "returns count" do
        expect(subject.users.count).to eq 77
      end
    end
  end


  describe "#user_roles" do
    let(:user) { OpenStruct.new(groups: ["Admin", "Moderator"]) }

    context "when user has groups" do
      it "returns groups" do
        expect(subject.user_roles user).to eq ["Admin", "Moderator"]
      end
    end
  end


  describe "#last_accessed" do
    context "when user has last_sign_in_at" do
      let(:user) { OpenStruct.new(last_sign_in_at: "May 10th 2014") }

      it "returns last_sign_in_at" do
        expect(subject.last_accessed user).to eq "May 10th 2014"
      end
    end

    context "when user last_sign_in_at is nil" do
      let(:user) { OpenStruct.new(last_sign_in_at: nil, created_at: "March 1st 2013") }

      it "returns last_sign_in_at" do
        expect(subject.last_accessed user).to eq "March 1st 2013"
      end
    end
  end


  describe "#show_last_access?" do
    context "when show_last_access is nil" do
      let(:show_last_access) { nil }

      it "returns blank" do
        expect(subject.show_last_access?).to be_blank
      end
    end

    context "when show_last_access has value" do
      it "returns returns last access" do
        skip "Add a test"
      end
    end
  end

end
