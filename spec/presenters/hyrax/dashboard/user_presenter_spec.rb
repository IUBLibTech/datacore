require 'rails_helper'

RSpec.describe Hyrax::Dashboard::UserPresenter do

  describe "#activity" do
    context "when current user has activity" do
      it "returns all user activity" do
        skip "Add a test"
      end
    end
  end

  describe "#notifications" do
    context "when current user has notifications" do
      let(:mailbox) { double(inbox: "mail") }
      let(:current_user) { double(mailbox: mailbox) }
      subject{ described_class.new(current_user, double, double) }

      it "returns mailbox inbox" do
        expect(subject.notifications).to eq "mail"
      end
    end
   end

  describe "#transfers" do
    context "when current user has transfers" do
      let(:view_context) { double }
      let(:current_user) { double }
      subject{ described_class.new(current_user, view_context, double) }

      it "returns TransfersPresenter" do
        expect(subject.transfers).to be_instance_of Hyrax::TransfersPresenter
      end
    end
  end

  pending "#render_recent_activity"
  pending "#render_recent_notifications"
  pending "#link_to_additional_notifications"
  pending "#link_to_manage_proxies"

end
