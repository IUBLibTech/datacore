require 'rails_helper'

class CookieMock
  def delete (text, path:)
  end
end

RSpec.describe ApplicationController do

  describe "#global_request_logging" do
    before {
      allow(subject).to receive(:request).and_return OpenStruct.new(remote_ip: "1.2.3.4", method: "GET", url: "/", headers: {"HTTP_USER_AGENT" => "agent"})
      allow(subject).to receive(:response).and_return OpenStruct.new(status: "responsive")

      allow(subject.logger).to receive(:info).with "ACCESS: 1.2.3.4, GET /, agent"
      allow(subject.logger).to receive(:info).with "response_status: responsive"
    }
    context "when called with an empty block" do
      it do
        expect(subject.logger).to receive(:info).with "ACCESS: 1.2.3.4, GET /, agent"
        expect(subject.logger).to receive(:info).with "response_status: responsive"

        subject.global_request_logging { }
      end
    end

    context "when called with a block" do
      it "yields the block" do
        skip "Add a test"
      end
    end
  end


  describe "#clear_session_user" do
    context "when called with nil request" do
      it "returns nil_request" do
        skip "Add a test"
      end
    end

    context "when called with request with value" do
      it "clears the session user" do
        skip "Add a test"
      end
    end
  end


  describe "#user_logged_in?" do
    before {
      allow(subject).to receive(:request).and_return OpenStruct.new(headers: "request headers")
    }

    context "when user_signed_in? true, valid_user? true, and Rails.env.test? false" do
      before {
        allow(subject).to receive(:user_signed_in?).and_return true
        allow(subject).to receive(:valid_user?).with("request headers").and_return true
        allow(Rails.env).to receive(:test?).and_return false
      }
      it "returns true" do
        expect(subject).to receive(:valid_user?).with("request headers")

        expect(subject.user_logged_in?).to eq true
      end
    end

    context "when user_signed_in? true, valid_user? false, and Rails.env.test? true" do
      before {
        allow(subject).to receive(:user_signed_in?).and_return true
        allow(subject).to receive(:valid_user?).with("request headers").and_return false
        allow(Rails.env).to receive(:test?).and_return true
      }
      it "returns true" do
        expect(subject).to receive(:valid_user?).with("request headers")
        expect(Rails.env).to receive(:test?)

        expect(subject.user_logged_in?).to eq true
      end
    end

    context "when user_signed_in? false, valid_user? true, and Rails.env.test? true" do
      before {
        allow(subject).to receive(:user_signed_in?).and_return false
        allow(subject).to receive(:valid_user?).with("request headers").and_return true
        allow(Rails.env).to receive(:test?).and_return true
      }
      it "returns false" do
        expect(subject.user_logged_in?).to eq false
      end
    end

    context "when user_signed_in? true, valid_user? false, and Rails.env.test? false" do
      before {
        allow(subject).to receive(:user_signed_in?).and_return true
        allow(subject).to receive(:valid_user?).with("request headers").and_return false
        allow(Rails.env).to receive(:test?).and_return false
      }
      it "returns false" do
        expect(subject).to receive(:valid_user?).with("request headers")

        expect(subject.user_logged_in?).to eq false
      end
    end

    after {
      expect(subject).to have_received(:user_signed_in?)
    }
  end


  describe "#sso_logout" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "from"

      allow(Hyrax::Engine.config).to receive(:logout_prefix).and_return "logout prefix "
      allow(subject).to receive(:logout_now_url).and_return "logout now"
      allow(subject).to receive(:redirect_to).with "logout prefix logout now"
    }

    context "without a current user" do
      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                     "from",
                                                                     "[AUTHN] sso_logout: (no user)",
                                                                     ""]
      }
      it "logs no user" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                     "from",
                                                                     "[AUTHN] sso_logout: (no user)",
                                                                     ""]
        subject.sso_logout
      end
    end

    context "with a current user" do
      before {
        allow(subject.current_user).to receive(:try).with(:email).and_return "current user email"
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                     "from",
                                                                     "[AUTHN] sso_logout: current user email",
                                                                     ""]
      }
      it "logs current user" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                      "from",
                                                                      "[AUTHN] sso_logout: current user email",
                                                                      ""]
        subject.sso_logout
      end
    end

    after {
      expect(subject).to have_received(:redirect_to).with "logout prefix logout now"
    }
  end


  describe "#sso_auto_logout" do
    before {
      allow(Rails.logger).to receive(:debug).with anything

      allow(subject).to receive(:sign_out)
      allow(Hyrax::Engine.config).to receive(:hostname).and_return "hyrax engine config hostname"
      allow(subject).to receive(:cookies).and_return CookieMock.new
      allow(subject.session).to receive(:destroy)
      allow(subject.flash).to receive(:clear)
    }

    it "logs out" do
      expect(subject).to receive(:sign_out)
      expect(subject).to receive(:cookies)
      expect(subject.session).to receive(:destroy)
      expect(subject.flash).to receive(:clear)

      subject.sso_auto_logout
    end

    it "logs out with current user" do
      skip "Add a test"
    end

    it "logs out with no user" do
      skip "Add a test"
    end
  end


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
