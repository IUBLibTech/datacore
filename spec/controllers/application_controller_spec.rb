require 'rails_helper'


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
      specify { expect { |b| subject.global_request_logging(&b) }.to yield_control }
      specify { expect { |b| subject.global_request_logging(&b) }.to yield_with_no_args }
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


  pending "#after_authentication"


  describe "#rescue_404" do
    it "renders a not found response" do
      get :rescue_404
      expect(response.status).to eq 404
    end
  end


  describe "#set_locale" do
    context "when locale param is present" do
      before {
        allow(subject).to receive(:params).and_return "locale" => "italian"
      }

      context "when constrained_locale has value" do
        before {
          allow(subject).to receive(:constrained_locale).and_return "english"
        }
        it "sets locale param to constrained_locale" do
          allow(subject).to receive(:params).and_return "locale" => "english"
        end
      end

      context "when I18n.default_locale has value" do
        before {
          allow(I18n).to receive(:default_locale).and_return "spanish"
        }
        it "sets locale param to I18n.default_locale" do
          allow(subject).to receive(:params).and_return "locale" => "spanish"
        end
      end
    end

    context "when locale param is not present" do
      it "returns nil" do
        expect(subject.set_locale).to be_blank
      end
    end
  end


  describe "#constrained_locale" do
    context "when locale param in available_translations" do
      skip "Add a test"
    end

    context "when locale not in available_translations" do
      skip "Add a test"
    end
  end

end
