require 'rails_helper'

RSpec.describe Hyrax::UserProfilePresenter do

  let(:first_user) { FactoryBot.create :user }
  let(:second_user) { FactoryBot.create :user }
  let(:ability) { instance_double(Ability, current_user: first_user ) }

    describe "user is current user" do
    subject{ described_class.new(first_user, ability) }

    it { is_expected.to delegate_method(:name).to(:user) }

    it "#current_user?" do
      expect(subject.current_user?).to eq true
    end

  end

  describe "user is not current user" do
    subject{ described_class.new(second_user, ability) }

    it "#current_user?" do
      expect(subject.current_user?).to eq false
    end

  end

end