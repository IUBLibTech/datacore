require 'rails_helper'

RSpec.describe GuestUserMessageController do

  describe "#show" do
    it "renders a response" do
      get :show
      expect(response.status).to eq 200
    end
  end


end
