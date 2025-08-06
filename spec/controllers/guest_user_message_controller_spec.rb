require 'rails_helper'

RSpec.describe GuestUserMessageController, type: :controller do

  describe "presenter_class" do
    it do
      expect(GuestUserMessageController.presenter_class).to eq GuestUserMessagePresenter
    end
  end

  describe "#show" do
    it "renders a response" do
      get :show
      expect(response.status).to eq 200
      expect(subject.instance_variable_get(:@presenter)).to be_instance_of GuestUserMessagePresenter
    end
  end


end
