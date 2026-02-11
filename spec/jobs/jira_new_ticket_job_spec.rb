require 'rails_helper'


RSpec.describe JiraNewTicketJob do

  describe "#perform" do
    work = OpenStruct.new(curation_notes_admin: "accurate")

    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::JiraHelper).to receive(:jira_ticket_for_create).with( curation_concern: work )
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "work.curation_notes_admin=accurate", "" ]
    }

    context "when job_delay is (less than or) equal to zero" do
      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "work_id=1347", "current_user=belgravia", "job_delay=0"]
        allow(ActiveFedora::Base).to receive(:find).with("1347").and_return work
        allow(Deepblue::JiraHelper).to receive(:jira_ticket_for_create).with( curation_concern: work )
      }
      it "calls LoggingHelper.bold_debug twice and calls jira_ticket_for_create" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "work_id=1347", "current_user=belgravia", "job_delay=0"]
        expect(Deepblue::LoggingHelper).not_to receive(:bold_debug).with [ "here", "called from", "work_id=1347", "current_user=belgravia", "sleeping 0 seconds" ]
        expect(subject).not_to receive(:sleep)
        expect(ActiveFedora::Base).to receive(:find).with("1347").twice
        expect(Deepblue::JiraHelper).to receive(:jira_ticket_for_create).with( curation_concern: work )
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "work.curation_notes_admin=accurate", "" ]

        subject.perform(work_id: "1347", current_user: "belgravia")
      end
    end

    context "when job_delay is greater than zero" do
      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "work_id=1296", "current_user=josephine", "job_delay=1" ]
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "work_id=1296", "current_user=josephine", "sleeping 1 seconds" ]
        allow(subject).to receive(:sleep).with 1
        allow(ActiveFedora::Base).to receive(:find).with("1296").and_return work
        allow(Deepblue::JiraHelper).to receive(:jira_ticket_for_create).with( curation_concern: work )
      }
      it "calls LoggingHelper.bold_debug thrice, calls sleep and calls jira_ticket_for_create" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "work_id=1296", "current_user=josephine", "job_delay=1" ]
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "work_id=1296", "current_user=josephine", "sleeping 1 seconds" ]
        expect(subject).to receive(:sleep).with 1
        expect(Deepblue::JiraHelper).to receive(:jira_ticket_for_create).with( curation_concern: work )
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "work.curation_notes_admin=accurate", "" ]

        subject.perform(work_id: "1296", current_user: "josephine", job_delay: 1)
      end
    end


    context "when jira_ticket_for_create raises an Exception" do
      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "work_id=6667", "current_user=cheshire", "job_delay=0"]
        allow(ActiveFedora::Base).to receive(:find).with("6667").and_return work
        allow(Deepblue::JiraHelper).to receive(:jira_ticket_for_create).with( curation_concern: work ).and_raise(Exception, "error message")
        allow(Rails.logger).to receive(:error).with(start_with("JiraNewTicketJob.perform(6667,0) Exception: error message at "))
        allow(Rails.logger).to receive(:error).with(start_with("JiraNewTicketJob.perform(6667,0) Exception: error message at "))
      }
      it "calls Rails.logger.error twice" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "work_id=6667", "current_user=cheshire", "job_delay=0"]

        expect(Deepblue::JiraHelper).to receive(:jira_ticket_for_create).with( curation_concern: work )
        expect(Deepblue::LoggingHelper).not_to receive(:bold_debug).with [ "here", "called from", "work.curation_notes_admin=accurate", "" ]
        expect(Rails.logger).to receive(:error).with(start_with("JiraNewTicketJob.perform(6667,0) Exception: error message at "))
        expect(Rails.logger).to receive(:error).with(start_with("JiraNewTicketJob.perform(6667,0) Exception: error message "))

        subject.perform(work_id: "6667", current_user: "cheshire")

        rescue Exception
        # raises Exception
      end
    end
  end

end
