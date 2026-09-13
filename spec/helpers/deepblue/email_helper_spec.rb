class EmailHelperMock
  include ::Deepblue::EmailHelper
end

class DeliverableEmailMock
  def deliver_now
  end
end



RSpec.describe Deepblue::EmailHelper, type: :helper do

  subject { EmailHelperMock.new }

  describe '#self.contact_email' do
    it "returns a string from settings" do
      expect(Deepblue::EmailHelper.contact_email).to be_instance_of String
    end
  end

  describe '#self.curation_concern_url' do
    context "when parameter is a DataSet" do
      it "calls data_set_url" do
        dataset = DataSet.new
        dataset.id = "123"

        expect(Deepblue::EmailHelper).to receive(:data_set_url).with(id: "123")
        Deepblue::EmailHelper.curation_concern_url(curation_concern: dataset)
      end
    end

    context "when parameter is a FileSet" do
      it "calls file_set_url" do
        fileset = FileSet.new
        fileset.id = "abc"

        expect(Deepblue::EmailHelper).to receive(:file_set_url).with(id: "abc")
        Deepblue::EmailHelper.curation_concern_url(curation_concern: fileset)
      end
    end

    context "when parameter is a Collection" do
      it "calls collection_url" do
        collection = Collection.new
        collection.id = "XYZ"

        expect(Deepblue::EmailHelper).to receive(:collection_url).with(id: "XYZ")
        Deepblue::EmailHelper.curation_concern_url(curation_concern: collection)
      end
    end

    context "when parameter is not a DataSet, FileSet, or Collection" do
      it "returns blank" do
        expect(Deepblue::EmailHelper.curation_concern_url(curation_concern: "concern")).to be_blank
      end
    end
  end

  # NOTE: unable to stub Rails.application.routes.url_helpers methods
  describe '#self.collection_url' do
    before {
      allow(Settings).to receive(:hostname).and_return "mock.host.name"
    }

    context "when collection parameter NOT present" do
      it "returns url for collection by id" do
        expect(Deepblue::EmailHelper.collection_url id: "123").to eq "http://mock.host.name/concern/collections/123"
      end
    end

    context "when collection parameter is present" do
      it "returns url for collection by collection id" do
        expect(Deepblue::EmailHelper.collection_url id: "123", collection: OpenStruct.new(id: "456"))
          .to eq "http://mock.host.name/concern/collections/456"
      end
    end
  end


  describe "#self.data_set_url" do
    before {
      allow(Settings).to receive(:hostname).and_return "mock.host.name"
    }
    context "when data_set parameter NOT present" do
      it "returns url for data_set by id" do
        expect(Deepblue::EmailHelper.data_set_url id: "123").to eq "http://mock.host.name/concern/data_sets/123"
      end
    end
    context "when data_set parameter is present" do
      it "returns url for data_set by data_set id" do
        expect(Deepblue::EmailHelper.data_set_url id: "123", data_set: OpenStruct.new(id: "456"))
          .to eq "http://mock.host.name/concern/data_sets/456"
      end
    end
  end


  describe "#self.file_set_url" do
    before {
      allow(Settings).to receive(:hostname).and_return "mock.host.name"
    }
    context "when file_set parameter NOT present" do
      it "returns url for file_set by id" do
        expect(Deepblue::EmailHelper.file_set_url id: "123").to eq "http://mock.host.name/concern/file_sets/123"
      end
    end
    context "when file_set parameter is present" do
      it "returns url for file_set by file_set id" do
        expect(Deepblue::EmailHelper.file_set_url id: "123", file_set: OpenStruct.new(id: "456"))
          .to eq "http://mock.host.name/concern/file_sets/456"
      end
    end
  end


  describe "#self.echo_to_rails_logger" do
    it "calls email_log_echo_to_rails_logger" do
      expect(DeepBlueDocs::Application.config).to receive(:email_log_echo_to_rails_logger)
      Deepblue::EmailHelper.echo_to_rails_logger
    end
  end


  describe "#self.hostname" do
    context "when Settings.hostname returns a value" do
      before {
        allow(Settings).to receive(:hostname).and_return "mock.host.name"
      }
      it "returns Settings.hostname" do
        expect(Deepblue::EmailHelper.hostname).to eq "mock.host.name"
      end
    end

    context "when Settings.hostname is nil then we are in development mode" do
      before {
        allow(Settings).to receive(:hostname).and_return nil
        allow(Settings).to receive(:relative_url_root).and_return "relative.url.root"
      }
      it "returns localhost url with Settings.relative_url_root included" do
        expect(Deepblue::EmailHelper.hostname).to eq "http://localhost:3000/relative.url.root/"
      end
    end
  end


  describe "#self.log" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:timestamp_now).and_return "the now"
      allow(DeepBlueDocs::Application.config).to receive(:email_enabled).and_return "enabled"
      allow(Deepblue::EmailHelper).to receive(:echo_to_rails_logger).and_return "logger"

    }
    context "when to_note parameter is blank" do
      before {
        allow(Deepblue::LoggingHelper).to receive(:log).with(class_name: "UnknownClass", event: 'unknown', event_note: "note", id: 'unknown_id',
                                                             timestamp: "the now", echo_to_rails_logger: "logger", logger: instance_of(EmailLogger),
                                                             to: "to@to.com", from: "from@from.com", subject: "subject", message: "message",
                                                             email_enabled: "enabled")
      }
      it "calls LoggingHelper.log without the to_note parameter" do
        expect(Deepblue::LoggingHelper).to receive(:log).with(class_name: "UnknownClass", event: 'unknown', event_note: "note", id: 'unknown_id',
                                                              timestamp: "the now",  echo_to_rails_logger: "logger", logger: instance_of(EmailLogger),
                                                              to: "to@to.com", from: "from@from.com", subject: "subject", message: "message",
                                                              email_enabled: "enabled")
        Deepblue::EmailHelper.log event_note: "note", to: "to@to.com", from: "from@from.com", subject: "subject", message: "message"
      end
    end

    context "when to_note parameter is present" do
      before {
        allow(Deepblue::LoggingHelper).to receive(:log).with(class_name: "UnknownClass", event: 'unknown', event_note: "note", id: 'unknown_id',
                                                             timestamp: "the now", echo_to_rails_logger: "logger", logger: instance_of(EmailLogger),
                                                             to: "to@to.com",  to_note: "notify!", from: "from@from.com", subject: "subject",
                                                             message: "message", email_enabled: "enabled")
      }
      it "calls LoggingHelper.log with the to_note parameter" do
        expect(Deepblue::LoggingHelper).to receive(:log).with(class_name: "UnknownClass", event: 'unknown', event_note: "note", id: 'unknown_id',
                                                              timestamp: "the now",  echo_to_rails_logger: "logger", logger: instance_of(EmailLogger),
                                                              to: "to@to.com", to_note: "notify!", from: "from@from.com", subject: "subject",
                                                              message: "message", email_enabled: "enabled")
        Deepblue::EmailHelper.log event_note: "note", to: "to@to.com", to_note: "notify!", from: "from@from.com", subject: "subject", message: "message"
      end
    end
  end


  describe "#self.log_raw" do
    before {
      allow(EMAIL_LOGGER).to receive(:info).with "message"
    }
    it "calls EMAIL_LOGGER.info with parameter" do
      expect(EMAIL_LOGGER).to receive(:info).with "message"
      Deepblue::EmailHelper.log_raw "message"
    end
  end


  describe "#self.notification_email" do
    before {
      allow(Rails.configuration).to receive(:notification_email).and_return "notification_email"
    }
    it "returns Rails.configuration.notification_email" do
      expect(Deepblue::EmailHelper.notification_email).to eq "notification_email"
    end
  end


  describe "#self.send_email" do
    context "when email is enabled" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:email_enabled).and_return true
      }
      context "when 'log' parameter is true and 'to' parameter has value" do
        before {
          allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["EmailHelper.send_email is enabled",
                                                             "to: to@to.com from: from@from.com subject: subject\nbody:\nbody"]
          allow(DeepblueMailer).to receive(:send_an_email).with(to: "to@to.com", from: "from@from.com", subject: "subject", body: "body")
                                                                                    .and_return DeliverableEmailMock.new
        }
        it "logs and sends email" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["EmailHelper.send_email is enabled",
                                                                        "to: to@to.com from: from@from.com subject: subject\nbody:\nbody"]
          expect(DeepblueMailer).to receive(:send_an_email).with(to: "to@to.com", from: "from@from.com", subject: "subject", body: "body")
          Deepblue::EmailHelper.send_email(to: "to@to.com", from: "from@from.com", subject: "subject", body: "body", log: true)
        end
      end

      context "when 'log' parameter is true and 'to' parameter is blank" do
        before {
          allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["EmailHelper.send_email is enabled",
                                                                       "to:  from: from@from.com subject: subject\nbody:\nbody"]
        }
        it "logs and does NOT send email" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["EmailHelper.send_email is enabled",
                                                                        "to:  from: from@from.com subject: subject\nbody:\nbody"]
          expect(DeepblueMailer).not_to receive(:send_an_email)
          Deepblue::EmailHelper.send_email(to: "", from: "from@from.com", subject: "subject", body: "body", log: true)
        end
      end

      context "when 'log' parameter is false and 'to' parameter is blank" do
        it "does NOT log and does NOT send email" do
          expect(Deepblue::LoggingHelper).not_to receive(:bold_debug)
          expect(DeepblueMailer).not_to receive(:send_an_email)
          Deepblue::EmailHelper.send_email(to: "", from: "from@from.com", subject: "subject", body: "body", log: false)
        end
      end
    end

    context "when email is disabled" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:email_enabled).and_return false
      }
      context "when 'log' parameter is true" do
        before {
          allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["EmailHelper.send_email is not enabled",
                                                                       "to: to@to.com from: from@from.com subject: subject\nbody:\nbody"]
        }
        it "logs and does NOT send email" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["EmailHelper.send_email is not enabled",
                                                                        "to: to@to.com from: from@from.com subject: subject\nbody:\nbody"]
          expect(DeepblueMailer).not_to receive(:send_an_email)
          Deepblue::EmailHelper.send_email(to: "to@to.com", from: "from@from.com", subject: "subject", body: "body", log: true)
        end
      end

      context "when 'log' parameter is false" do
        it "does NOT log and does NOT send email" do
          expect(Deepblue::LoggingHelper).not_to receive(:bold_debug)
          expect(DeepblueMailer).not_to receive(:send_an_email)
          Deepblue::EmailHelper.send_email(to: "to@to.com", from: "from@from.com", subject: "subject", body: "body", log: false)
        end
      end
    end
  end


  describe "self.user_email" do
    before {
      allow(Rails.configuration).to receive(:user_email).and_return "user_email"
    }
    it "returns Rails.configuration.user_email" do
      expect(Deepblue::EmailHelper.user_email).to eq "user_email"
    end
  end


  describe "self.user_email_from" do
    context "when user not signed in" do
      it "returns nil" do
        expect(Deepblue::EmailHelper.user_email_from "current user", user_signed_in: false).to be_nil
      end
    end

    context "when current user is nil" do
      it "returns nil" do
        expect(Deepblue::EmailHelper.user_email_from nil, user_signed_in: true).to be_nil
      end
    end

    context "when user signed in and current user has a value" do
      it "returns current user email" do
        current_user = OpenStruct.new(email: "user@example.com")
        expect(Deepblue::EmailHelper.user_email_from current_user).to eq "user@example.com"
      end
    end
  end

end
