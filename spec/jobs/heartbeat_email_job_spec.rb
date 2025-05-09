require 'rails_helper'


RSpec.describe Hyrax::ApplicationJob::HeartbeatEmailJob do

  pending "#perform"

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

    it "calls EmailHelper log and send_email)" do
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