require 'rails_helper'


RSpec.describe Hyrax::ApplicationJob::HeartbeatJob do

  pending "#self.perform"

  describe "#perform" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "from"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with('class', anything).and_return "class.class=HeartbeatJob"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with( [ "here", "from", "class.class=HeartbeatJob", ""] )
      allow(Deepblue::SchedulerHelper).to receive(:log).with( class_name: "HeartbeatJob",  event: "heartbeat" )
    }

    it "calls LoggingHelper.bold_debug and SchedulerHelper.log" do
      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with( ["here", "from", "class.class=HeartbeatJob", ""] )
      expect(Deepblue::SchedulerHelper).to receive(:log).with( class_name: "HeartbeatJob",  event: "heartbeat" )

      subject.perform
    end
  end

end
