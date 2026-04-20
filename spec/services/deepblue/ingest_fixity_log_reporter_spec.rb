require 'rails_helper'


describe Deepblue::IngestFixityLogReporter do

  subject { described_class.new( input: "stuff" ) }

  describe "#initialize" do
    context "when filter is not present" do
      before {
        allow(Deepblue::LogReporter).to receive(:new).with(filter: "filtration", input: "input", options: {})
      }
      it "calls super" do
        expect(Deepblue::LogReporter).to receive(:new).with(filter: "filtration", input: "input", options: {})

        Deepblue::IngestFixityLogReporter.new(filter: "filtration", input: "input", options: {})
      end

      skip "test with Deepblue::FixityCheckLogFilter"
    end

    context "when filter is present" do
      it "calls super and filter_and" do
        skip "Add a test"
      end
    end
  end


  describe "#report" do
    before {
      allow(subject).to receive(:run)

      allow(subject).to receive(:timestamp_first).and_return "first time"
      allow(subject).to receive(:timestamp_last).and_return "last time"
      allow(subject).to receive(:fixity_check_passed_id).and_return ["crocus", "daffodil", "snowdrop"]
      allow(subject).to receive(:fixity_check_failed_id).and_return ["maple", "butterscotch", "caramel", "molasses"]

      allow(subject).to receive(:puts).with("timestamp_first = first time")
      allow(subject).to receive(:puts).with("timestamp_last = last time")
      allow(subject).to receive(:puts).with("fixity_check_passed_count = 3")
      allow(subject).to receive(:puts).with("fixity_check_failed_count = 4")
    }
    it "calls run and calls puts four times" do
      expect(subject).to receive(:run)
      expect(subject).to receive(:puts).with("timestamp_first = first time")
      expect(subject).to receive(:puts).with("timestamp_last = last time")
      expect(subject).to receive(:puts).with("fixity_check_passed_count = 3")
      expect(subject).to receive(:puts).with("fixity_check_failed_count = 4")
      subject.report
    end
  end


  # protected methods

  describe "#initialize_report_values" do
    it "calls super and sets instance variables" do
      subject.send(:initialize_report_values)

      #testing super method
      subject.instance_variable_get(:@lines_reported) == 0
      subject.instance_variable_get(:@timestamp_first).blank?
      subject.instance_variable_get(:@timestamp_last).blank?
      subject.instance_variable_get(:@events).empty?
      subject.instance_variable_get(:@class_events).empty?
      subject.instance_variable_get(:@ids).empty?

      subject.instance_variable_get(:@fixity_check_failed_id).empty?
      subject.instance_variable_get(:@fixity_check_passed_id).empty?
    end
  end


  describe "#line_read" do
    before {
      subject.instance_variable_set(:@lines_reported, 13)
      subject.instance_variable_set(:@timestamp_first, "earlier stamp time")
      subject.instance_variable_set(:@ids, {})
      subject.instance_variable_set(:@events, {"event" => 3})
      subject.instance_variable_set(:@class_events, {"class event key" => 7})
      allow(subject).to receive(:class_event_key).with(class_name: "classy name", event: "event").and_return "class event key"
      subject.instance_variable_set(:@fixity_check_failed_id, ["once ID"])
      subject.instance_variable_set(:@fixity_check_passed_id, ["old ID"])
    }

    context "on success" do
      it "sets and updates instance variables including @fixity_check_passed_id" do
        #testing super method
        subject.instance_variable_get(:@lines_reported) == 14
        subject.instance_variable_get(:@timestamp_first) == "earlier stamp time"
        subject.instance_variable_get(:@timestamp_last) == "time to stamp"
        subject.instance_variable_get(:@ids)["ID"] == true
        subject.instance_variable_get(:@events)["event"] == 4
        subject.instance_variable_get(:@class_events)["class event key"] == 8

        subject.instance_variable_get(:@fixity_check_passed_id) == ["old ID","ID"]

        subject.send(:line_read, "line", "time to stamp", "event", "success", "classy name", "ID", "raw key values")
      end
    end

    context "when not success" do
      it "sets and updates instance variables including @fixity_check_failed_id" do
        #testing super method
        subject.instance_variable_get(:@lines_reported) == 14
        subject.instance_variable_get(:@timestamp_first) == "earlier stamp time"
        subject.instance_variable_get(:@timestamp_last) == "time to stamp"
        subject.instance_variable_get(:@ids)["ID"] == true
        subject.instance_variable_get(:@events)["event"] == 4
        subject.instance_variable_get(:@class_events)["class event key"] == 8

        subject.instance_variable_get(:@fixity_check_failed_id) == ["once ID","ID"]

        subject.send(:line_read, "line", "time to stamp", "event", "event note", "classy name", "ID", "raw key values")
      end
    end
  end
end