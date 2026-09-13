require 'rails_helper'
require_relative '../../../lib/tasks/task_reporter'
require_relative '../../../lib/tasks/task_pacifier'
require_relative '../../../lib/tasks/task_logger'

class MockTaskReporter
  include Deepblue::TaskReporter
end

class MockTaskLogger

  def level=(level)
  end
end


RSpec.describe Deepblue::TaskReporter do

  attr_accessor :log, :pacifier

  subject { MockTaskReporter.new }


  describe "#log" do
    context "when @log has a value" do
      before {
        subject.instance_variable_set(:@log, "log")
      }
      it "returns value of @log" do
        expect(subject).not_to receive(:initialize_log)

        expect(subject.log).to eq "log"
      end
    end

    context "when @log has NO value" do
      before {
        allow(subject).to receive(:initialize_log).and_return "log initialized"
      }
      it "calls initialize_log, sets and returns the value of @log" do
        expect(subject).to receive(:initialize_log)
        expect(subject.log).to eq "log initialized"

        expect(subject.instance_variable_get(:@log)).to eq "log initialized"
      end
    end
  end


  describe "#pacifier" do
    context "when @pacifier has a value" do
      before {
        subject.instance_variable_set(:@pacifier, "pacifier")
      }
      it "returns value of @pacifier" do
        expect(subject).not_to receive(:initialize_pacifier)

        expect(subject.pacifier).to eq "pacifier"
      end
    end

    context "when @pacifier has NO value" do
      before {
        allow(subject).to receive(:initialize_pacifier).and_return "pacifier initialized"
      }
      it "calls initialize_pacifier, sets and returns the value of @pacifier" do
        expect(subject).to receive(:initialize_pacifier)
        expect(subject.pacifier).to eq "pacifier initialized"

        expect(subject.instance_variable_get(:@pacifier)).to eq "pacifier initialized"
      end
    end
  end


  describe "#initialize_log" do
    task_logger = MockTaskLogger.new

    before {
      allow(Deepblue::TaskLogger).to receive(:new).with( STDOUT ).and_return task_logger
    }
    it "calls Deepblue::TaskLogger.new" do
      expect(Deepblue::TaskLogger).to receive(:new).with( STDOUT )
      expect(task_logger).to receive(:level=).with(Logger::INFO)
      expect(Rails).to receive(:logger=).with(task_logger)

      subject.send(:initialize_log)
    end
  end


  describe "#initialize_pacifier" do
    before {
      allow(Deepblue::TaskPacifier).to receive(:new).with( out: STDOUT )
    }

    it "calls Deepblue::TaskPacifier.new" do
      expect(Deepblue::TaskPacifier).to receive(:new).with( out: STDOUT )

      subject.send(:initialize_pacifier)
    end
  end

end
