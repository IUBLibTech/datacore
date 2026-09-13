require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user) { build(:user) }
  let(:another_user) { build(:user) }

  describe 'verifying factories' do
    describe ':user' do
      let(:user) { build(:user) }

      it 'will, by default, have only registered group' do
        expect(user.groups).to eq([])
        user.save!
        # Ensuring that we can refind it and have the correct groups
        expect(user.class.find(user.id).groups).to eq(['registered'])
      end
    end
    describe ':admin' do
      let(:admin_user) { create(:admin) }

      it 'will be an "admin"' do
        expect(admin_user.admin?).to be true
      end
      context 'when found from the database' do
        it 'will be an "admin"' do
          refound_admin_user = described_class.find(admin_user.id)
          expect(refound_admin_user.admin?).to be true
        end
      end
    end
  end

  it "has an email" do
    expect(user.user_key).to be_kind_of String
  end
  it "has activity stream-related methods defined" do
    expect(user).to respond_to(:stream)
    expect(user).to respond_to(:events)
    expect(user).to respond_to(:profile_events)
    expect(user).to respond_to(:log_event)
    expect(user).to respond_to(:log_profile_event)
  end
  it "has social attributes" do
    expect(user).to respond_to(:twitter_handle)
    expect(user).to respond_to(:facebook_handle)
    expect(user).to respond_to(:googleplus_handle)
    expect(user).to respond_to(:linkedin_handle)
    expect(user).to respond_to(:orcid)
  end


  describe "#to_s" do
    before {
      allow(subject).to receive(:email).and_return "genericemailatcom"
    }

    it "returns user email" do
      expect(subject.to_s).to eq "genericemailatcom"
    end
  end

end
