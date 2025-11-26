class WorkflowEventMockNoDatePublished
  include Deepblue::WorkflowEventBehavior

  def initialize
    @date_published = nil
    @date_modified = nil
  end

  def save!
  end

  def date_published=(text)
    @date_published = text
  end

  def date_modified=(text)
    @date_modified = text
  end

  def provenance_publish(current_user:, event_note:, message:)
  end

  def email_rds_publish(current_user:, event_note:, message:)
  end
end


class WorkflowEventMock < WorkflowEventMockNoDatePublished
  def id
  end

  def provenance_create(current_user:, event_note:)
  end

  def provenance_embargo(current_user:, event_note:)
  end

  def provenance_destroy(current_user:, event_note:)
  end

  def email_rds_create(current_user:, event_note:)
  end

  def email_rds_destroy(current_user:, event_note:)
  end

  def date_published
  end
end


RSpec.describe Deepblue::WorkflowEventBehavior do
  subject { WorkflowEventMock.new }

  describe '#workflow_create' do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with('class', subject).and_return "class"
      allow(::Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "class", "current_user=user", "event_note=note", ""])

      allow(subject).to receive(:provenance_create).with(current_user: "user", event_note: "note")
      allow(subject).to receive(:email_rds_create).with(current_user: "user", event_note: "note")
      allow(subject).to receive(:id).and_return "work_id"

      allow(JiraNewTicketJob).to receive(:perform_later).with(work_id: 'work_id', current_user: "user")
    }

    it "calls create functions" do
      expect(Deepblue::LoggingHelper).to receive(:here)
      expect(Deepblue::LoggingHelper).to receive(:called_from)
      expect(Deepblue::LoggingHelper).to receive(:obj_class).with('class', subject)
      expect(::Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "class", "current_user=user", "event_note=note", ""])

      expect(subject).to receive(:provenance_create)
      expect(subject).to receive(:email_rds_create)
      allow(subject).to receive(:id).and_return "work_id"

      allow(JiraNewTicketJob).to receive(:perform_later).with(work_id: 'work_id', current_user: "user")

      subject.workflow_create(current_user: 'user', event_note: 'note')
    end
  end


  describe '#workflow_embargo' do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with('class', subject).and_return "class"
      allow(::Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "class", "current_user=user", "event_note=note", ""])

      allow(subject).to receive(:provenance_embargo).with(current_user: "user", event_note: "note")
    }
    it "calls embargo functions" do
      expect(Deepblue::LoggingHelper).to receive(:here)
      expect(Deepblue::LoggingHelper).to receive(:called_from)
      expect(Deepblue::LoggingHelper).to receive(:obj_class).with('class', subject)
      expect(::Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "class", "current_user=user", "event_note=note", ""])
      expect(subject).to receive(:provenance_embargo).with(current_user: "user", event_note: "note")

      subject.workflow_embargo(current_user: 'user', event_note: 'note')
    end
  end


  describe '#workflow_destroy' do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with('class', subject).and_return "class"
      allow(::Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "class", "current_user=user", "event_note=note", ""])

      allow(subject).to receive(:provenance_destroy).with(current_user: "user", event_note: "note")
      allow(subject).to receive(:email_rds_destroy).with(current_user: "user", event_note: "note")
    }
    it "calls destroy functions" do
      expect(Deepblue::LoggingHelper).to receive(:here)
      expect(Deepblue::LoggingHelper).to receive(:called_from)
      expect(Deepblue::LoggingHelper).to receive(:obj_class).with('class', subject)
      expect(::Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "class", "current_user=user", "event_note=note", ""])

      expect(subject).to receive(:provenance_destroy).with(current_user: "user", event_note: "note")
      expect(subject).to receive(:email_rds_destroy).with(current_user: "user", event_note: "note")

      subject.workflow_destroy(current_user: 'user', event_note: 'note')
    end
  end


  describe '#workflow_publish' do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with('class', subject).and_return "class"
      allow(::Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "class", "current_user=user", "event_note=note",
                                                                     "message=message", ""])

      allow(Hyrax::TimeService).to receive(:time_in_utc).and_return "time in utc"
      allow(DateTime).to receive(:now).and_return "right now"
    }

    context "when respond_to? :date_published" do
      before {
        allow(subject).to receive(:provenance_publish).with(current_user: "user", event_note: "note", message: "message")
        allow(subject).to receive(:email_rds_publish).with(current_user: "user", event_note: "note", message: "message")
      }

      it "calls publish functions" do
        expect(Deepblue::LoggingHelper).to receive(:here).and_return "here"
        expect(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
        expect(Deepblue::LoggingHelper).to receive(:obj_class).with('class', subject).and_return "class"
        expect(::Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "class", "current_user=user", "event_note=note",
                                                                        "message=message", ""])
        expect(subject).to receive(:save!)

        expect(subject).to receive(:provenance_publish).with(current_user: "user", event_note: "note", message: "message")
        expect(subject).to receive(:email_rds_publish).with(current_user: "user", event_note: "note", message: "message")

        subject.workflow_publish(current_user: 'user', event_note: 'note', message: 'message')

        subject.instance_variable_get(:@date_published) == "time in utc"
        subject.instance_variable_get(:@date_modified) == "right now"
      end
    end

    context "when respond_to? :date_published is false" do
      subject { WorkflowEventMockNoDatePublished.new }

      before {
        allow(::Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "does not respond to :date_published", ""])
        allow(subject).to receive(:provenance_publish).with(current_user: "user", event_note: "note", message: "message")
        allow(subject).to receive(:email_rds_publish).with(current_user: "user", event_note: "note", message: "message")
      }

      it "calls publish functions" do
        expect(Deepblue::LoggingHelper).to receive(:here).and_return "here"
        expect(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
        expect(Deepblue::LoggingHelper).to receive(:obj_class).with('class', subject).and_return "class"
        expect(::Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "class", "current_user=user", "event_note=note",
                                                                        "message=message", ""])
        expect(subject).not_to receive(:save!)

        expect(::Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "does not respond to :date_published", ""])

        expect(subject).to receive(:provenance_publish).with(current_user: "user", event_note: "note", message: "message")
        expect(subject).to receive(:email_rds_publish).with(current_user: "user", event_note: "note", message: "message")

        subject.workflow_publish(current_user: 'user', event_note: 'note', message: 'message')

        subject.instance_variable_get(:@date_published).blank? == true
        subject.instance_variable_get(:@date_modified).blank? == true
      end
    end
  end

end
