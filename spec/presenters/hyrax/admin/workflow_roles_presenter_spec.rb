require 'rails_helper'

RSpec.describe Hyrax::Admin::WorkflowRolesPresenter do

  pending "#users"


  describe "#presenter_for" do
    let(:user) { OpenStruct.new(sipity_agent: nil) }

    context "when user has no sipity_agent" do
      it "returns blank" do
        expect(subject.presenter_for user).to be_blank
      end
    end

    context "when user has a sipity_agent" do
      it "returns new agent" do
        skip "Add a test"
      end
    end
  end

end
