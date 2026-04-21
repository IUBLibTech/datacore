require 'rails_helper'

class WorkflowNote
  def call
  end
end





RSpec.describe Hyrax::Workflow::AbstractNotification do


  describe "#self.send_notification" do
    notification = WorkflowNote.new
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "entity=entity", "comment=comment", "user=user", "recipients=recipients", ""]
      allow(Hyrax::Workflow::AbstractNotification).to receive(:new).with("entity", "comment", "user", "recipients").and_return notification
      allow(notification).to receive(:call)
    }

    it "calls bold debug and creates a new AbstractNotification to call" do
      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "entity=entity", "comment=comment", "user=user", "recipients=recipients", ""]
      expect(Hyrax::Workflow::AbstractNotification).to receive(:new).with("entity", "comment", "user", "recipients")
      expect(notification).to receive(:call)
      Hyrax::Workflow::AbstractNotification.send_notification(entity: "entity", comment: "comment", user: "user", recipients: "recipients")
    end
  end


  describe "#initialize" do
    context "when comment parameter has comment field" do
      it "sets instance variables" do
        entity = OpenStruct.new(proxy_for_global_id: "/cake/icing", proxy_for: OpenStruct.new(title: ["headline", "byline"]))
        commentary = OpenStruct.new(comment: "commitment")
        notification = Hyrax::Workflow::AbstractNotification.new(entity, commentary, "user", OpenStruct.new(with_indifferent_access: "indifference"))
        expect(notification.instance_variable_get(:@work_id)).to eq "icing"
        expect(notification.instance_variable_get(:@title)).to eq "headline"
        expect(notification.instance_variable_get(:@comment)).to eq "commitment"
        expect(notification.instance_variable_get(:@recipients)).to eq "indifference"
        expect(notification.instance_variable_get(:@user)).to eq "user"
        expect(notification.instance_variable_get(:@entity)).to eq entity
      end
    end

    context "when comment parameter has NO comment field" do
      it "sets instance variables including default empty string where needed" do
        entity = OpenStruct.new(proxy_for_global_id: "/cake/icing", proxy_for: OpenStruct.new(title: ["headline", "byline"]))
        commentary = OpenStruct.new(community: "celebration")
        notification = Hyrax::Workflow::AbstractNotification.new(entity, commentary, "user", OpenStruct.new(with_indifferent_access: "indifference"))

        expect(notification.instance_variable_get(:@comment)).to be_blank
      end
    end
  end


  let(:document) { OpenStruct.new(title: ["top"]) }
  let(:entitle) { OpenStruct.new(proxy_for_global_id: "/orange/lemon", proxy_for: document) }
  let(:commute) { OpenStruct.new(comment: "community") }
  let(:user) { "person"}

  subject { described_class.new(entitle, commute, user, OpenStruct.new(with_indifferent_access: "diffidence")) }

  describe "#call" do
    before {
      allow(subject).to receive(:message).and_return "messaging"
      allow(subject).to receive(:subject).and_return "subjectify"
      allow(subject).to receive(:curation_concern_notifications).with("person", "messaging", "subjectify")
      allow(subject).to receive(:users_to_notify).and_return ["user1", "user2", "user1"]
      allow(Hyrax::MessengerService).to receive(:deliver).with("person", "user1", "messaging", "subjectify")
      allow(Hyrax::MessengerService).to receive(:deliver).with("person", "user2", "messaging", "subjectify")
    }
    it "delivers messages to the users to notify" do
      expect(subject).to receive(:curation_concern_notifications).with("person", "messaging", "subjectify")
      expect(subject).to receive(:users_to_notify).and_return ["user1", "user2", "user1"]
      expect(Hyrax::MessengerService).to receive(:deliver).with("person", "user1", "messaging", "subjectify").once
      expect(Hyrax::MessengerService).to receive(:deliver).with("person", "user2", "messaging", "subjectify")
      subject.call
    end
  end


  # private methods

  describe "#document" do
    it "returns proxy_for of entity" do
      expect(subject.send(:document)).to eq document
    end
  end


  describe "#document_path" do
    before {
      allow(subject).to receive(:document).and_return OpenStruct.new(id: "D-07", model_name: OpenStruct.new(singular_route_key: "edit_robots"))
      allow(Rails.application.routes.url_helpers).to receive(:send).with("edit_robots_path", "D-07").and_return "/robots/edit.D-07"
    }
    it "calls send method from Rails.application.routes.url_helpers and returns result" do
      expect(subject.send(:document_path)).to eq "/robots/edit.D-07"
    end
  end


  describe "#curation_concern_notifications" do
    it "returns nil" do
      expect(subject.send(:curation_concern_notifications, "user", "message", "subject")).to be_nil
    end
  end


  describe "#message" do
    subject { described_class.new(entitle, commute, OpenStruct.new(user_key: "person id"), OpenStruct.new(with_indifferent_access: "diffidence")) }

    before {
      allow(subject).to receive(:document_path).and_return "cherry"
    }
    it "returns string" do
      expect(subject.send(:message)).to eq "top (<a href=\"cherry\">lemon</a>) was advanced in the workflow by person id and is awaiting approval community"
    end
  end


  describe "#subject" do
    it "raises NotImplementedError" do
      begin
        subject.send(:subject)
      rescue NotImplementedError => e
        expect(e.message).to eq "Implement #subject in a child class"
      end
    end
  end


  describe "#users_to_notify" do
    context "when the 'to' and 'cc' keys have values" do
      before {
        subject.instance_variable_set(:@recipients, { :to => ["to@example.org"], :cc => ["cc@example.org"] } )
      }
      it "returns to and cc values from recipients" do
        expect(subject.send(:users_to_notify)).to eq ["to@example.org", "cc@example.org"]
      end
    end

    context "when the 'to' and 'cc' keys do NOT have values" do
      before {
        subject.instance_variable_set(:@recipients, { :to => "", :cc => "" } )
      }
      it "returns the defaults for to and cc" do
        expect(subject.send(:users_to_notify)).to be_empty
      end
    end
  end

end
