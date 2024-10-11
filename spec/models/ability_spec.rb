require 'rails_helper'

RSpec.describe Ability do
  let(:user) { FactoryBot.create :user }
  let(:options) { {} }
  let(:ability) { described_class.new(user, options) }

  describe '#can_deposit?' do
    context 'when neither an admin nor depositor' do
      it 'returns false' do
        expect(ability.admin?).to be false
        expect(ability.depositor?).to be false
        expect(ability.can? :create, DataSet).to be false
      end
    end
    context 'when a depositor' do
      let(:admin_set) { AdminSet.find(AdminSet.find_or_create_default_admin_set_id) }
      before do
        # creates permission template and depositor permissions
        Hyrax::AdminSetCreateService.new(admin_set: admin_set, creating_user: user).create
      end
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
