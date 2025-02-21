require 'rails_helper'

RSpec.describe Hyrax::DataSetsController do
  include Devise::Test::ControllerHelpers
  routes { Rails.application.routes }
  let(:main_app) { Rails.application.routes.url_helpers }
  let(:hyrax) { Hyrax::Engine.routes.url_helpers }
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  shared_examples "doi_mint! behavior" do
    it "redirect" do
      expect(response).to redirect_to(work)
    end
    it "flashes something" do
      expect(flash[:alert]).to be_a String
    end
  end

  # always redirect, always flash notice
  describe "#doi" do
    context "when minting is disabled" do
    end
    context "when minting is in progress" do
      it "redirects to the work"
      it "flashes a notice"
    end
    context "when minting is already done" do
    end
    context "when invalid metadata" do
    end
    context "when not yet minted" do
      context "but no files are present" do
      end
      context "but user lacks rights" do
      end
      context "and user has rights" do
        it "starts minting"
        context "and succeeds"
        context "and fails"
      end
    end
  end
end
