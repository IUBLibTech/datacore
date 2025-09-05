require 'rails_helper'


RSpec.describe HeartbeatEmailJob do

  describe "#perform" do
    options = {"macaron" => nil, "ice cream" => nil}
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with('class', subject).and_return "class.class=HeartbeatEmailJob"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "class.class=HeartbeatEmailJob", ""]
      allow(Deepblue::SchedulerHelper).to receive(:log).with( class_name: "HeartbeatEmailJob",  event: "heartbeat email" )

      allow(Deepblue::LoggingHelper).to receive(:obj_class).with('options', options).and_return "optional"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "options={\"macaron\"=>nil, \"ice cream\"=>nil}", "optional", ""]

      allow(DeepBlueDocs::Application.config).to receive(:hostname).and_return "Deepblue hostname"
    }

    context "when hostname is found" do
      before {
        allow(subject).to receive(:get_hostnames).and_return ["Deepblue hostname", "additional hostname"]
        allow(DeepBlueDocs::Application.config).to receive(:scheduler_heartbeat_email_targets).and_return ["email target"]
      }

      context "when no Exception is raised" do
        before {
          allow(subject).to receive(:heartbeat_email).with(email_target: "email target", hostname: "Deepblue hostname")
        }
        it "logs job and calls heartbeat_email" do
          expect(DeepBlueDocs::Application.config).to receive(:scheduler_heartbeat_email_targets).and_return ["email target"]
          expect(subject).to receive(:heartbeat_email).with(email_target: "email target", hostname: "Deepblue hostname")

          subject.perform("macaron", "ice cream")
        end
      end

      context "when Exception occurs when calling heartbeat_email" do
        before {
          allow(subject).to receive(:heartbeat_email).with(email_target: "email target", hostname: "Deepblue hostname").and_raise(Exception)
        }
        it "logs job and logs errors" do
          begin
            expect(DeepBlueDocs::Application.config).to receive(:scheduler_heartbeat_email_targets).and_return ["email target"]
            expect(subject).to receive(:heartbeat_email).with(email_target: "email target", hostname: "Deepblue hostname").and_raise(Exception)
            expect(Rails.logger).to receive(:error).twice
            subject.perform("macaron", "ice cream")
          rescue Exception
            # raises Exception
          end
        end
      end
    end

    context "when hostname is not found" do
      before {
        allow(subject).to receive(:get_hostnames).and_return ["unrelated hostname", "unwanted hostname"]
      }
      it "logs job but does not call heartbeat_email" do
        expect(DeepBlueDocs::Application.config).not_to receive(:scheduler_heartbeat_email_targets)
        expect(subject).not_to receive(:heartbeat_email)

        subject.perform("macaron", "ice cream")
      end
    end

    after {
      expect(Deepblue::LoggingHelper).to have_received(:bold_debug).with [ "here", "called from", "class.class=HeartbeatEmailJob", ""]
      expect(Deepblue::SchedulerHelper).to have_received(:log).with( class_name: "HeartbeatEmailJob",  event: "heartbeat email" )
      expect(Deepblue::LoggingHelper).to have_received(:bold_debug).with [ "here", "options={\"macaron\"=>nil, \"ice cream\"=>nil}", "optional", ""]
    }
  end


  describe "#get_hostnames" do
    context "when verbose" do
      before {
        allow(subject).to receive(:job_options_value).with("options", key: "verbose", default_value: false).and_return true
        allow(Deepblue::LoggingHelper).to receive(:debug).with "verbose=true"
        allow(subject).to receive(:job_options_value).with("options", key: 'hostnames', default_value:[], verbose: true).and_return ["Deepblue hostname", "other hostname"]
      }
      it "logs with debug and returns hostnames" do
        expect(subject).to receive(:job_options_value).with("options", key: "verbose", default_value: false)
        expect(Deepblue::LoggingHelper).to receive(:debug).with "verbose=true"
        expect(subject).to receive(:job_options_value).with("options", key: 'hostnames', default_value:[], verbose: true)

        expect(subject.get_hostnames "options").to eq ["Deepblue hostname", "other hostname"]
      end
    end

    context "when NOT verbose" do
      before {
        allow(subject).to receive(:job_options_value).with("options", key: "verbose", default_value: false).and_return false
        allow(subject).to receive(:job_options_value).with("options", key: 'hostnames', default_value:[], verbose: false).and_return ["good hostname", "best hostname"]
      }
      it "returns hostnames" do
        expect(subject).to receive(:job_options_value).with("options", key: "verbose", default_value: false)
        expect(Deepblue::LoggingHelper).not_to receive(:debug)
        expect(subject).to receive(:job_options_value).with("options", key: 'hostnames', default_value:[], verbose: false)

        expect(subject.get_hostnames "options").to eq ["good hostname", "best hostname"]
      end
    end
  end


  describe "#heartbeat_email" do
    before {
      allow(Deepblue::EmailHelper).to receive(:log).with(class_name: "HeartbeatEmailJob",
                                                         current_user: nil,
                                                         event: "Heartbeat email",
                                                         event_note: '',
                                                         id: 'NA',
                                                         to: "email target",
                                                         from: "email target",
                                                         subject: "DBD scheduler heartbeat from hostname",
                                                         body: "DBD scheduler heartbeat from hostname" )
      allow(Deepblue::EmailHelper).to receive(:send_email).with( to: "email target",
                                                                 from:  "email target",
                                                                 subject: "DBD scheduler heartbeat from hostname",
                                                                 body: "DBD scheduler heartbeat from hostname" )
    }

    it "calls EmailHelper log and send_email" do
      expect(Deepblue::EmailHelper).to receive(:log).with(class_name: "HeartbeatEmailJob",
                                                          current_user: nil,
                                                          event: "Heartbeat email",
                                                          event_note: '',
                                                          id: 'NA',
                                                          to: "email target",
                                                          from: "email target",
                                                          subject: "DBD scheduler heartbeat from hostname",
                                                          body: "DBD scheduler heartbeat from hostname" )
      expect(Deepblue::EmailHelper).to receive(:send_email).with( to: "email target",
                                                                  from:  "email target",
                                                                  subject: "DBD scheduler heartbeat from hostname",
                                                                  body: "DBD scheduler heartbeat from hostname" )

      subject.heartbeat_email email_target: "email target", hostname: "hostname"
    end
  end

end
