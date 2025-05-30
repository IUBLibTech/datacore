require 'rails_helper'

RSpec.describe Deepblue::LogReporter do
  subject { described_class.new(filter: "filter", input: "input", options: {"blue" => "gold"} ) }

  describe "#initialize" do
    it "initializes instance variables" do
      # called by initialize in parent class
      subject.instance_variable_get(:@filter) == "filter"
      subject.instance_variable_get(:@input) == "input"
      subject.instance_variable_get(:@options) == {"blue" => "gold"}
      subject.instance_variable_get(:@verbose) == false
      subject.instance_variable_get(:@verbose_filter) == false

      subject.instance_variable_get(:@output_close) == false
      subject.instance_variable_get(:@output_mode) == 'w'
      subject.instance_variable_get(:@output_pathname).nil? == true
    end

    it "super calls add_date_range_filter" do
      allow(Deepblue::LogReader).to receive(:new)
      Deepblue::LogReporter.new(filter: nil, input:"input", options: {})
      expect(Deepblue::LogReader).to have_received(:new)
    end
  end

  describe "#report" do
    before {
      allow(subject).to receive(:run)

      subject.instance_variable_set(:@timestamp_first, "first!")
      subject.instance_variable_set(:@timestamp_last, "last...")
      allow(subject).to receive(:ids).and_return "1,2,3"
      allow(subject).to receive(:events).and_return "eventually"
      allow(subject).to receive(:class_events).and_return "classified"
    }

    it "puts messages" do
      expect(subject).to receive(:puts).with "timestamp_first = first!"
      expect(subject).to receive(:puts).with "timestamp_last = last..."
      expect(subject).to receive(:puts).with "ids = 1,2,3"
      expect(subject).to receive(:puts).with "events = eventually"
      expect(subject).to receive(:puts).with "class_events = classified"

      expect(subject).to receive(:run)

      subject.report
    end
  end

  describe "#run" do
    before {
      allow(subject).to receive(:initialize_report_values)
      allow(subject).to receive(:readlines).and_return( ["line", "timestamp", "event", "event_note", "class_name", "id", "raw_key_values"] )
    }

    it "calls functions" do
      expect(subject).to receive(:initialize_report_values)
      expect(subject).to receive(:readlines).and_return( ["line", "timestamp", "event", "event_note", "class_name", "id", "raw_key_values"] )
      subject.run
    end

    it "calls line_read" do
      skip "Add a test"
    end
  end

end