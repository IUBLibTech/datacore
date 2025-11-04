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

  describe '#can_deposit?', :clean do
    context 'when neither an admin nor depositor' do
      it 'returns false' do
        expect(ability.admin?).to be false
        expect(ability.depositor?).to be false
        expect(ability.can? :create, DataSet).to be false
      end
    end
    context 'when a depositor' do
      let(:depositing_role) { Sipity::Role.find_by_name(Hyrax::RoleRegistry::DEPOSITING) }
      let(:depositing_agent) { Sipity::Agent.create(proxy_for_id: user.id, proxy_for_type: "User") }
      let!(:responsibility) { Sipity::WorkflowResponsibility.create(workflow_role_id: depositing_role.id, agent_id: depositing_agent.id) }
      it 'returns true' do
        expect(ability.admin?).to be false
        expect(ability.depositor?).to be true
        expect(ability.can? :create, DataSet).to be true
      end
    end
    context 'when an admin' do
      let(:user) { FactoryBot.create :admin }
      it 'returns true' do
        expect(ability.admin?).to be true
        expect(ability.depositor?).to be false
        expect(ability.can? :create, DataSet).to be true
      end
    end
  end
end
