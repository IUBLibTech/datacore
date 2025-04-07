require 'rails_helper'

RSpec.describe Hyrax::UserProfilePresenter do

  let(:first_user) { FactoryBot.create :user }
  let(:second_user) { FactoryBot.create :user }
  let(:ability) { instance_double(Ability, current_user: first_user ) }

  describe "delegates method to user:" do
    subject{ described_class.new(first_user, ability) }

    it { is_expected.to delegate_method(:name).to(:user) }
  end


  describe "#current_user?" do
    context "when user is current_user" do
      subject{ described_class.new(first_user, ability) }
      it "returns true" do
        expect(subject.current_user?).to eq true
      end
    end

    context "when user is not current_user" do
      subject{ described_class.new(second_user, ability) }
      it "returns false" do
        expect(subject.current_user?).to eq false
      end
    end
  end


  pending "#events"
  pending "#trophies"

end
