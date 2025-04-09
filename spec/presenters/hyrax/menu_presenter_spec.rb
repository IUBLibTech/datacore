require 'rails_helper'

RSpec.describe Hyrax::MenuPresenter do

  let(:view_context) { double }
  subject{ described_class.new(view_context: view_context) }

  describe "delegates methods to view_context:" do
    [:controller, :controller_name, :action_name, :content_tag, :current_page?, :link_to, :can?].each do
    |method|
      it "#{method}" do
        expect(subject).to delegate_method(method).to(:view_context)
      end
    end
  end

  pending "#settings_section?"
  pending "#nav_link"

  describe "#user_activity_section?" do
    context "when the current controller is a UsersController" do
      before {
        allow(subject).to receive(:controller).and_return Hyrax::UsersController.new
      }
      it "returns true" do
        expect(subject.user_activity_section?).to eq true
      end
    end

    context "when the current controller is a NotificationsController" do
      before {
        allow(subject).to receive(:controller).and_return Hyrax::NotificationsController.new
      }
      it "returns true" do
        expect(subject.user_activity_section?).to eq true
      end
    end

    context "when the current controller is a TransfersController" do
      before {
        allow(subject).to receive(:controller).and_return Hyrax::TransfersController.new
      }
      it "returns true" do
        expect(subject.user_activity_section?).to eq true
      end
    end

    context "when the current controller is a DepositorsController" do
      before {
        allow(subject).to receive(:controller).and_return Hyrax::DepositorsController.new
      }
      it "returns true" do
        expect(subject.user_activity_section?).to eq true
      end
    end

    context "when the current controller is not a user activity controller" do
      before {
        allow(subject).to receive(:controller).and_return Hyrax::GenericWorksController.new
      }
      it "returns false" do
        expect(subject.user_activity_section?).to eq false
      end
    end
  end

  pending "#collapsable_section"
  pending "#show_configuration?"

end