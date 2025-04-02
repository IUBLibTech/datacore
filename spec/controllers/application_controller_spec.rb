require 'rails_helper'

RSpec.describe ApplicationController do

  describe "#rescue_404" do
    it "renders a not found response" do
      get :rescue_404
      expect(response.status).to eq 404
    end
  end

  describe '#show_site_actions?' do
    it 'returns true' do

      expect( subject.show_site_actions? ).to eq true

    end
  end
end
