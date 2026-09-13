class JiraHelperMock
  include ::Deepblue::JiraHelper

end


class CuratingConcerningMockParent
  def id
    "123ID"
  end

  def authoremail
    "author@example.com"
  end

  def creator
    "creativetype"
  end

  def subject_discipline
    "discipline"
  end

  def title
    ["Out There", "Somewhere"]
  end

  def save!
  end
end


class CuratingConcerningMockChild < ::CuratingConcerningMockParent

  def curation_notes_admin=(notes)
    @curation_notes_admin = notes
  end
  def curation_notes_admin
    @curation_notes_admin
  end

  def date_modified=(datetime)
    @date_modified = datetime
  end

  def date_modified
    @date_modified
  end
end


class MockIssue
  def save(options)
  end

  def build
    self
  end
end


RSpec.describe Deepblue::JiraHelper, type: :helper do
  subject { JiraHelperMock.new }


  pending "constants"


  describe "#self.jira_enabled" do
    before {
      allow(DeepBlueDocs::Application.config).to receive(:jira_integration_enabled).and_return "jira integration enabled"
    }
    it "returns value of jira_integration_enabled" do
      expect(Deepblue::JiraHelper.jira_enabled).to eq "jira integration enabled"
    end
  end


  describe "#self.jira_manager_issue_type" do
    before {
      allow(DeepBlueDocs::Application.config).to receive(:jira_manager_issue_type).and_return "manager"
    }
    it "returns value of jira_manager_issue_type" do
      expect(Deepblue::JiraHelper.jira_manager_issue_type).to eq "manager"
    end
  end


  describe "#self.jira_manager_project_key" do
    before {
      allow(DeepBlueDocs::Application.config).to receive(:jira_manager_project_key).and_return "JIRA-123"
    }
    it "returns value of jira_manager_project_key" do
      expect(Deepblue::JiraHelper.jira_manager_project_key).to eq "JIRA-123"
    end
  end


  describe "#self.jira_test_mode" do
    before {
      allow(DeepBlueDocs::Application.config).to receive(:jira_test_mode).and_return "TEST MODE"
    }
    it "returns value of jira_test_mode" do
      expect(Deepblue::JiraHelper.jira_test_mode).to eq "TEST MODE"
    end
  end


  describe "#self.summary_last_name" do
    context "when creator name is blank" do
      it "returns empty string" do
        expect(Deepblue::JiraHelper.summary_last_name(curation_concern: OpenStruct.new(creator: [" ", "create 1"]))).to be_empty
      end
    end

    context "when creator name has a comma" do
      it "returns last name" do
        expect(Deepblue::JiraHelper.summary_last_name(curation_concern: OpenStruct.new(creator: ["Smith, Elisabet", "create 2"]))).to eq "Smith"
      end
    end

    context "when creator name has NO comma" do
      it "returns last name" do
        expect(Deepblue::JiraHelper.summary_last_name(curation_concern: OpenStruct.new(creator: ["Johanna Lexenstein", "create 3"]))).to eq "Lexenstein"
      end
    end
  end


  describe "#self.summary_description" do
    context "when description is blank" do
      it "returns empty string" do
        expect(Deepblue::JiraHelper.summary_description(curation_concern: OpenStruct.new(description: [" "]))).to be_empty
      end
    end

    context "when description has three or more words" do
      it "returns first two words" do
        expect(Deepblue::JiraHelper.summary_description(curation_concern: OpenStruct.new(description: ["Armoire Bench Chair."]))).to eq "ArmoireBench"
      end
    end

    context "when description has two words" do
      it "returns first two words" do
        expect(Deepblue::JiraHelper.summary_description(curation_concern: OpenStruct.new(description: ["Armoire Bench"]))).to eq "ArmoireBench"
      end
    end

    context "when description has one word" do
      it "returns first word" do
        expect(Deepblue::JiraHelper.summary_description(curation_concern: OpenStruct.new(description: ["Chandelier"]))).to eq "Chandelier"
      end
    end

    context "when description does not match preceding word patterns" do
      it "returns description parameter value" do
        expect(Deepblue::JiraHelper.summary_description(curation_concern: OpenStruct.new(description: ["Chaise "]))).to eq "Chaise "
      end
    end
  end


  describe "#self.summary_title" do
    context "when title is blank" do
      it "returns empty string" do
        expect(Deepblue::JiraHelper.summary_description(curation_concern: OpenStruct.new(title: [" "]))).to be_empty
      end
    end

    context "when title has three or more words" do
      it "returns first two words" do
        expect(Deepblue::JiraHelper.summary_title(curation_concern: OpenStruct.new(title: ["Crispy Crunchy Salty."]))).to eq "CrispyCrunchy"
      end
    end

    context "when title has two words" do
      it "returns first two words" do
        expect(Deepblue::JiraHelper.summary_title(curation_concern: OpenStruct.new(title: ["sugary sweet"]))).to eq "sugarysweet"
      end
    end

    context "when title has one word" do
      it "returns first word" do
        expect(Deepblue::JiraHelper.summary_title(curation_concern: OpenStruct.new(title: ["Umami"]))).to eq "Umami"
      end
    end

    context "when title does not match preceding word patterns" do
      it "returns description parameter value" do
        expect(Deepblue::JiraHelper.summary_title(curation_concern: OpenStruct.new(title: [" octopus"]))).to eq " octopus"
      end
    end
  end


  describe "#self.jira_ticket_for_create" do
    concern = CuratingConcerningMockParent.new

    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "curation_concern.id=123ID", ""]
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with('class', Deepblue::JiraHelper).and_return "object class"
      allow(Deepblue::JiraHelper).to receive(:summary_title).with(curation_concern: concern).and_return "summary title"
      allow(Deepblue::JiraHelper).to receive(:summary_last_name).with(curation_concern: concern).and_return "family name"
      allow(Deepblue::EmailHelper).to receive(:data_set_url).with(data_set: concern).and_return "deposit url"

      allow(Deepblue::LoggingHelper).to receive(:obj_class).with('class', subject).and_return "object class"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "object class", "summary=family name_summary title_123ID",
                                                                  "description=Out There\nSomewhere\n\nby creativetype"]

      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "jira_url=Jira ticket", ""]
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "curation_concern.curation_notes_admin=notify ", ""]
      allow(DateTime).to receive(:now).and_return DateTime.new(2025, 10, 20, 10, 10, 10)
    }

    context "when JiraHelper.new_ticket returns nil" do
      before {
        allow(Deepblue::JiraHelper).to receive(:new_ticket).with(contact_info: "author@example.com", deposit_id: "123ID", deposit_url: "deposit url",
                                                                 description: "Out There\nSomewhere\n\nby creativetype", discipline: "discipline",
                                                                 summary: "family name_summary title_123ID").and_return nil
      }
      it "does NOT update or save curation_concern parameter" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "curation_concern.id=123ID", ""]
        expect(Deepblue::JiraHelper).to receive(:summary_title).with(curation_concern: concern)
        expect(Deepblue::JiraHelper).to receive(:summary_last_name).with(curation_concern: concern)
        expect(Deepblue::EmailHelper).to receive(:data_set_url).with(data_set: concern)
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "object class", "summary=family name_summary title_123ID",
                                                                      "description=Out There\nSomewhere\n\nby creativetype", ""]
        expect(Deepblue::JiraHelper).to receive(:new_ticket).with(contact_info: "author@example.com", deposit_id: "123ID", deposit_url: "deposit url",
                                                                  description: "Out There\nSomewhere\n\nby creativetype", discipline: "discipline",
                                                                  summary: "family name_summary title_123ID")
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "jira_url=", ""]
        expect(Deepblue::LoggingHelper).not_to receive(:bold_debug).with ["here", "called from", "curation_concern.curation_notes_admin=notify ", ""]
        expect(concern).not_to receive(:save!)

        Deepblue::JiraHelper.jira_ticket_for_create(curation_concern: concern)
      end
    end

    context "when JiraHelper.new_ticket does NOT return nil and curation_concern does NOT respond to :curation_notes_admin" do
      before {
        allow(Deepblue::JiraHelper).to receive(:new_ticket).with(contact_info: "author@example.com", deposit_id: "123ID", deposit_url: "deposit url",
                                                                 description: "Out There\nSomewhere\n\nby creativetype", discipline: "discipline",
                                                                 summary: "family name_summary title_123ID").and_return "Jira ticket"
      }
      it "does NOT update or save curation_concern parameter" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "curation_concern.id=123ID", ""]
        expect(Deepblue::JiraHelper).to receive(:summary_title).with(curation_concern: concern)
        expect(Deepblue::JiraHelper).to receive(:summary_last_name).with(curation_concern: concern)
        expect(Deepblue::EmailHelper).to receive(:data_set_url).with(data_set: concern)
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "object class", "summary=family name_summary title_123ID",
                                                                      "description=Out There\nSomewhere\n\nby creativetype", ""]
        expect(Deepblue::JiraHelper).to receive(:new_ticket).with(contact_info: "author@example.com", deposit_id: "123ID", deposit_url: "deposit url",
                                                                  description: "Out There\nSomewhere\n\nby creativetype", discipline: "discipline",
                                                                  summary: "family name_summary title_123ID")
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "jira_url=Jira ticket", ""]
        expect(Deepblue::LoggingHelper).not_to receive(:bold_debug).with ["here", "called from", "curation_concern.curation_notes_admin=notify ", ""]
        expect(concern).not_to receive(:save!)

        Deepblue::JiraHelper.jira_ticket_for_create(curation_concern: concern)
      end

      context "when JiraHelper.new_ticket does NOT return nil and curation_concern responds to :curation_notes_admin" do
        concerned = CuratingConcerningMockChild.new
        concerned.curation_notes_admin = "notify "
        before {
          allow(Deepblue::JiraHelper).to receive(:summary_title).with(curation_concern: concerned).and_return "summary title"
          allow(Deepblue::JiraHelper).to receive(:summary_last_name).with(curation_concern: concerned).and_return "family name"
          allow(Deepblue::EmailHelper).to receive(:data_set_url).with(data_set: concerned).and_return "deposit url"
        }
        it "updates and saves curation_concern parameter" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "curation_concern.id=123ID", ""]
          expect(Deepblue::JiraHelper).to receive(:summary_title).with(curation_concern: concerned)
          expect(Deepblue::JiraHelper).to receive(:summary_last_name).with(curation_concern: concerned)
          expect(Deepblue::EmailHelper).to receive(:data_set_url).with(data_set: concerned)
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "object class", "summary=family name_summary title_123ID",
                                                                              "description=Out There\nSomewhere\n\nby creativetype", ""]
          expect(Deepblue::JiraHelper).to receive(:new_ticket).with(contact_info: "author@example.com", deposit_id: "123ID", deposit_url: "deposit url",
                                                                          description: "Out There\nSomewhere\n\nby creativetype", discipline: "discipline",
                                                                          summary: "family name_summary title_123ID")
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "jira_url=Jira ticket", ""]
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "curation_concern.curation_notes_admin=notify ", ""]
          expect(concerned).to receive(:save!)

          Deepblue::JiraHelper.jira_ticket_for_create(curation_concern: concerned)

          expect(concerned.date_modified).to eq DateTime.new(2025, 10, 20, 10, 10, 10)
          expect(concerned.curation_notes_admin).to eq "notify Jira ticket: Jira ticket"
        end
      end
    end
  end


  describe "#self.new_ticket" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with('class', Deepblue::JiraHelper).and_return "object class"
      allow(Deepblue::JiraHelper).to receive(:jira_manager_project_key).and_return "project_key"
      allow(Deepblue::JiraHelper).to receive(:jira_manager_issue_type).and_return "issue type"
    }

    context 'when jira_enabled returns false' do
      before {
        allow(Deepblue::JiraHelper).to receive(:jira_enabled).and_return false
      }

      it "returns nil" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "object class", "summary=sum",
                                                                     "project_key=project_key", "issue_type=issue type", "description=desc",
                                                                     "jira_enabled=false", ""]

        expect(Deepblue::JiraHelper.new_ticket(contact_info: "", deposit_id: "", deposit_url: "", description: "desc", discipline: "disc", summary: "sum")).to be_nil
      end
    end

    context 'when jira_enabled returns true' do
      before {
        allow(Deepblue::JiraHelper).to receive(:jira_enabled).and_return true
        allow(Deepblue::LoggingHelper).to receive(:bold_debug)
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "object class", "summary=sum",
                                                                     "project_key=project_key", "issue_type=issue type", "description=desc",
                                                                     "jira_enabled=true", ""]
      }

      context "when jira_test_mode is true" do
        before {
          allow(Deepblue::JiraHelper).to receive(:jira_test_mode).and_return true
        }
        it "calls bold_debug twice and returns jira test mode url" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).twice

          expect(Deepblue::JiraHelper.new_ticket(contact_info: "", deposit_id: "", deposit_url: "", description: "desc", discipline: "disc", summary: "sum"))
            .to eq "https://test.jira.url/project_key"
        end
      end

      context "when jira_test_mode is false" do
        before {
          allow(Deepblue::JiraHelper).to receive(:jira_test_mode).and_return false
          allow(JIRA::Client).to receive(:new).and_return OpenStruct.new(Issue: MockIssue.new)
          allow(Deepblue::JiraHelper).to receive(:ticket_url).and_return "ticket url"
        }
        it "calls bold_debug eight times and returns ticket url" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).exactly(8).times
          expect(Deepblue::JiraHelper.new_ticket(contact_info: "", deposit_id: "", deposit_url: "", description: "desc", discipline: "disc", summary: "sum"))
            .to eq "ticket url"
        end
      end
    end

    pending "add more details for bold debug calls"
  end


  describe "#self.ticket_url" do
    it "returns url constructed from parameters" do
      expect(Deepblue::JiraHelper.ticket_url client: OpenStruct.new(options: { :site => "site/", :context_path => "context_path" }),
                                             issue: OpenStruct.new(key: "issue_key")).to eq "site/context_path/browse/issue_key"
    end
  end

end
