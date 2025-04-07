require 'rails_helper'

RSpec.describe ApplicationController do

  pending "#global_request_logging"

  pending "#clear_session_user"

  pending "#user_logged_in?"

  pending "#sso_logout"

  pending "#sso_auto_logout"

  pending "#after_authentication"


  describe "#rescue_404" do
    it "renders a not found response" do
      get :rescue_404
      expect(response.status).to eq 404
    end
  end


  # Testing ThemedLayoutController module

  pending "#with_themed_layout"

  describe '#show_site_actions?' do
    it 'returns true' do
      expect( subject.show_site_actions? ).to eq true

    end
  end

  describe '#show_site_search?' do
    it 'returns true' do
      expect( subject.show_site_search? ).to eq true

    end
  end
end
