RSpec.describe Deepblue::SchedulerHelper, type: :helper do

  describe '#self.echo_to_rails_logger' do
    before {
      allow(DeepBlueDocs::Application.config).to receive(:scheduler_log_echo_to_rails_logger).and_return "log rails echo"
    }

    context "when class variable has value" do
      before {
        Deepblue::SchedulerHelper.class_variable_set(:@@echo_to_rails_logger, "echo to rails logger")
      }
      it "returns value" do
        expect(DeepBlueDocs::Application.config).not_to receive(:scheduler_log_echo_to_rails_logger)

        expect(Deepblue::SchedulerHelper.echo_to_rails_logger).to eq "echo to rails logger"
      end
    end

    context "when class variable has NO value" do
      before {
        Deepblue::SchedulerHelper.class_variable_set(:@@echo_to_rails_logger, nil)
      }
      it "calls scheduler_log_echo_to_rails_logger, sets class variable and returns its value" do
        expect(DeepBlueDocs::Application.config).to receive(:scheduler_log_echo_to_rails_logger)
        expect(Deepblue::SchedulerHelper.echo_to_rails_logger).to eq "log rails echo"
        expect(Deepblue::SchedulerHelper.class_variable_get(:@@echo_to_rails_logger)).to eq "log rails echo"
      end
    end
  end


  describe "#self.echo_to_rails_logger=" do
    it "sets the value of the class variable" do
      Deepblue::SchedulerHelper.echo_to_rails_logger = "rails echo logarithm"

      expect(Deepblue::SchedulerHelper.class_variable_get(:@@echo_to_rails_logger)).to eq "rails echo logarithm"
    end
  end


  describe "#self.log" do
    before {
      allow(Deepblue::JsonLoggerHelper).to receive(:timestamp_now).and_return "the endless now"
      allow(Deepblue::JsonLoggerHelper).to receive(:timestamp_zone).and_return "the Time Zone"
      allow(Deepblue::SchedulerHelper).to receive(:msg_to_log).and_return "message to log"
      allow(Deepblue::SchedulerHelper).to receive(:log_raw).with "message to log"
      allow(Rails.logger).to receive(:info).with "message to log"
    }

    context "when echo_to_rails_logger parameter has a value" do
      before {
        allow(Deepblue::SchedulerHelper).to receive(:echo_to_rails_logger).and_return "something"
      }
      it "calls log_raw and Rails.logger.info" do
        expect(Deepblue::SchedulerHelper).to receive(:echo_to_rails_logger)
        expect(Deepblue::SchedulerHelper).to receive(:msg_to_log)
        expect(Deepblue::SchedulerHelper).to receive(:log_raw).with "message to log"
        expect(Rails.logger).to receive(:info).with "message to log"

        Deepblue::SchedulerHelper.log(event_note: 'event note', id: "XYZ-00")
      end
    end

    context "when echo_to_rails_logger parameter has NO value" do
      it "calls log_raw" do
        expect(Deepblue::SchedulerHelper).to receive(:msg_to_log)
        expect(Deepblue::SchedulerHelper).to receive(:log_raw).with "message to log"
        expect(Rails.logger).not_to receive(:info)

        Deepblue::SchedulerHelper.log(event_note: 'event note', id: "XYZ-00", echo_to_rails_logger: nil)
      end
    end
  end


  describe "#self.log_raw" do
    skip "Add a test"
  end


end
