require 'rails_helper'

RSpec.describe GuestUserMessagePresenter do

  describe '#initialize' do
    it "sets @controller variable" do
      guest_user = GuestUserMessagePresenter.new(controller: "MysteryController")

      expect(guest_user.instance_variable_get(:@controller)).to eq "MysteryController"
    end
  end

end
