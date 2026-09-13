require 'rails_helper'

class WorkflowPublishingConcern

  def workflow_publish(current_user:, event_note:, message:)
    "workflow published"
  end
end




RSpec.describe Hyrax::Workflow::DepositedNotification do

  let(:doc) { OpenStruct.new(title: ["top"]) }
  let(:title) { OpenStruct.new(proxy_for_global_id: "/papaya/pineapple", proxy_for: doc) }
  let(:commute) { OpenStruct.new(comment: "community.") }
  let(:user) { OpenStruct.new(user_key: "person")}

  subject { described_class.new(title, commute, user, OpenStruct.new(with_indifferent_access: { :to => ["to@example.org"], :cc => ["cc@example.org"] })) }


  # private methods

  describe '#curation_concern_notifications' do

    context "when 'ActiveFedora::Base.find' returns an object with a workflow_publish function" do
      workflow_concern = WorkflowPublishingConcern.new
      before {
        allow(ActiveFedora::Base).to receive(:find).with("pineapple").and_return workflow_concern
      }

      it "calls workflow_publish on result of ActiveFedora::Base.find" do
        expect(ActiveFedora::Base).to receive(:find).with("pineapple")
        expect(workflow_concern).to receive(:workflow_publish).with(current_user: "user key", event_note: "DepositedNotification", message: "messaging").and_return "workflow published"

        subject.send(:curation_concern_notifications, OpenStruct.new(user_key: "user key"), "messaging", "subject not used")
      end
    end

    context "when 'ActiveFedora::Base.find' returns an object withOUT a workflow_publish function" do
      non_concern = OpenStruct.new(publish: false)
      before {
        allow(ActiveFedora::Base).to receive(:find).with("pineapple").and_return non_concern
      }

      it "does NOT call workflow_publish" do
        expect(ActiveFedora::Base).to receive(:find).with("pineapple")

        expect(subject.send(:curation_concern_notifications, OpenStruct.new(user_key: "user key"), "no connection", "subject not used")).to be_nil
      end
    end
  end


  describe "#message" do
    before {
      allow(subject).to receive(:document_path).and_return "peaches"
    }

    it "returns a string" do
      expect(subject.send(:message)).to eq "top (<a href=\"peaches\">pineapple</a>) was approved by person. community."
    end
  end


  describe "#subject" do
    it "returns a string" do
      expect(subject.send(:subject)).to eq "Deposit has been approved"
    end
  end


  describe "#users_to_notify" do
    before {
      allow(ActiveFedora::Base).to receive(:find).with("pineapple").and_return OpenStruct.new(depositor: "user_key")
      allow(User).to receive(:find_by).with(email: "user_key").and_return "work_id@example.org"
    }
    it "calls super and adds work depositor email to array result" do
      expect(ActiveFedora::Base).to receive(:find).with("pineapple")
      expect(User).to receive(:find_by).with(email: "user_key")

      expect(subject.send(:users_to_notify)).to eq ["to@example.org", "cc@example.org", "work_id@example.org"]
    end
  end

end
