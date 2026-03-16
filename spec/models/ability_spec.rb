require 'rails_helper'

RSpec.describe Ability do
  let(:user) { FactoryBot.create :user }
  let(:options) { {} }
  let(:ability) { described_class.new(user, options) }


  describe "#ability_logic" do
    it "returns an array of functions" do
      expect(Ability.ability_logic).to include(:deepblue_abilities, :featured_collection_abilities)
    end
  end


  describe "#custom_permissions" do
    context "when can deposit" do
      before {
        allow(ability).to receive(:can_deposit?).and_return true
      }
      it "user can create DataSet, FileSet, and doi" do
        ability.custom_permissions
        expect(ability.can? :create, DataSet).to be true
        expect(ability.can? :create, FileSet).to be true
        expect(ability.can? :doi, DataSet).to be true
      end
    end

    context "when canNOT deposit" do
      before {
        allow(ability).to receive(:can_deposit?).and_return false
      }
      it "user cannot create, edit, update, or destroy DataSet or FileSet" do
        ability.custom_permissions
        expect(ability.can? :create, DataSet).to be false
        expect(ability.can? :edit, DataSet).to be false
        expect(ability.can? :update, DataSet).to be false
        expect(ability.can? :destroy, DataSet).to be false
        expect(ability.can? :create, FileSet).to be false
        expect(ability.can? :edit, FileSet).to be false
        expect(ability.can? :update, FileSet).to be false
        expect(ability.can? :destroy, FileSet).to be false
        expect(ability.can? :doi, DataSet).to be false
      end
    end
  end


  describe "#can_deposit?" do
    roles = [{:admin => true, :depositor => true, :expected_result => true},
             {:admin => false, :depositor => false, :expected_result => false},
             {:admin => true, :depositor => false, :expected_result => true},
             {:admin => false, :depositor => true, :expected_result => true}]
    roles.each do |role|
      context "when admin? returns #{role[:admin]} and depositor? returns #{role[:depositor]}" do
        before {
          allow(ability).to receive(:admin?).and_return role[:admin]
          allow(ability).to receive(:depositor?).and_return role[:depositor]
        }
        it "returns #{role[:expected_result]}" do
          expect(ability.can_deposit?).to eq role[:expected_result]
        end
      end
    end
  end


  describe "#admin?" do
    context "when user is an admin" do
      let(:user) { FactoryBot.create :admin }
      it "returns true" do
        expect(ability.admin?).to eq true
      end
    end

    context "when user is NOT an admin" do
      it "returns false" do
        expect(ability.admin?).to eq false
      end
    end
  end


  describe "#depositor?" do
    context "when depositing role is NOT found" do
      before {
        allow(Sipity::Role).to receive(:find_by_name).with(name: Hyrax::RoleRegistry::DEPOSITING).and_return false
      }
      it "returns false" do
        expect(ability.depositor?).to eq false
      end
    end

    context "when depositing role is found" do
      before {
        allow(Sipity::Role).to receive(:find_by_name).with(name: Hyrax::RoleRegistry::DEPOSITING).and_return OpenStruct.new(id: "role_id")
      }

      context "when when user does NOT have depositing role" do
        it "returns false" do
          expect(ability.depositor?).to eq false
        end
      end

      context "when when user has depositing role" do
        it "returns true" do
          skip "Add a test"
        end
      end
    end
  end

end
