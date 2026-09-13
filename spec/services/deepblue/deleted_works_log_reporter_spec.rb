require 'rails_helper'


describe Deepblue::DeletedWorksLogReporter do

  subject { described_class.new( input: "input" ) }


  describe "#initialize" do
    it "calls super" do
      expect(Deepblue::EventLogFilter).to receive(:new)
      Deepblue::DeletedWorksLogReporter::DeletedLogFilter.new options: {"optional" => "true"}
    end

    skip "Add a test that includes initialize parameters"
  end


  describe "#initialize" do
    context "when DeletedLogFilter is blank and DataSetLogFilter is blank" do
      it "calls super, calls new on DeletedLogFilter and DataSetLogFilter" do
        expect(Deepblue::LogReporter).to receive(:new).with(filter: "filter", input: "stuff", options: {})
        Deepblue::DeletedWorksLogReporter.new(filter: "filter", input: "stuff", options: {})
      end
    end

    skip "Add a test where DeletedLogFilter and DataSetLogFilter are not blank"
  end


  describe "#report" do

    before {
      allow(subject).to receive(:run)
      allow(subject).to receive(:deleted_ids).and_return ["alpha"]
      allow(subject).to receive(:deleted_id_to_key_values_map).and_return(
        {"alpha" => {"timestamp" => "stamping time", "authoremail" => "auteur email", "event_note" => "eventful", "creator" => ["artisan", "artiste"]}})
      allow(subject).to receive(:puts).with("id,deleted,event_note,url,authoremail,creator")
      allow(subject).to receive(:puts).with("\"alpha\",stamping time,eventful,https://deepbluedata.lib.umich.edu/provenance_log/alpha,auteur email,\"artisan;artiste\"")
    }

    context "when verbose" do
      before {
        allow(subject).to receive(:verbose).and_return true
        allow(subject).to receive(:timestamp_first).and_return "first time"
        allow(subject).to receive(:timestamp_last).and_return "last time"
        allow(subject).to receive(:puts).with("timestamp_first = first time")
        allow(subject).to receive(:puts).with("timestamp_last = last time")

        allow(subject).to receive(:puts).with("deleted_ids.size = 1")
      }
      it "calls run and calls puts five times" do
        expect(subject).to receive(:run)
        expect(subject).to receive(:puts).with("timestamp_first = first time")
        expect(subject).to receive(:puts).with("timestamp_last = last time")
        expect(subject).to receive(:puts).with("deleted_ids.size = 1")
        expect(subject).to receive(:puts).with("id,deleted,event_note,url,authoremail,creator")
        expect(subject).to receive(:puts).with("\"alpha\",stamping time,eventful,https://deepbluedata.lib.umich.edu/provenance_log/alpha,auteur email,\"artisan;artiste\"")

        subject.report
      end
    end

    context "when not verbose" do
      before {
        allow(subject).to receive(:verbose).and_return false
      }
      it "calls run and calls puts twice" do
        expect(subject).to receive(:run)
        expect(subject).to receive(:puts).with("id,deleted,event_note,url,authoremail,creator")
        expect(subject).to receive(:puts).with("\"alpha\",stamping time,eventful,https://deepbluedata.lib.umich.edu/provenance_log/alpha,auteur email,\"artisan;artiste\"")

        subject.report
      end
    end
  end


  # protected methods

  describe "#initialize_report_values" do
    it "sets instance variables" do
      subject.send(:initialize_report_values)

      #testing super method
      subject.instance_variable_get(:@lines_reported) == 0
      subject.instance_variable_get(:@timestamp_first).blank?
      subject.instance_variable_get(:@timestamp_last).blank?
      subject.instance_variable_get(:@events).empty?
      subject.instance_variable_get(:@class_events).empty?
      subject.instance_variable_get(:@ids).empty?

      subject.instance_variable_get(:@deleted_ids).empty?
      subject.instance_variable_get(:@deleted_id_to_key_values_map).empty?
    end
  end


  describe "#line_read" do
    before {
      subject.instance_variable_set(:@lines_reported, 0)
      subject.instance_variable_set(:@ids, {})
      subject.instance_variable_set(:@events, {"event" => 3})
      subject.instance_variable_set(:@class_events, {"class event key" => 7})
      allow(subject).to receive(:class_event_key).with(class_name: "classy name", event: "event").and_return "class event key"

      subject.instance_variable_set(:@deleted_ids, ["previous ID"])
      subject.instance_variable_set(:@deleted_id_to_key_values_map, {})
      allow(Deepblue::ProvenanceHelper).to receive(:parse_log_line_key_values).with("raw key values").and_return "key values"
    }
    it "sets and updates instance variables" do
      #testing super method
      subject.instance_variable_get(:@lines_reported) == 1
      subject.instance_variable_get(:@timestamp_first) == "time to stamp" 
      subject.instance_variable_get(:@timestamp_last) == "time to stamp"
      subject.instance_variable_get(:@ids)["ID"] == true
      subject.instance_variable_get(:@events)["event"] == 4
      subject.instance_variable_get(:@class_events)["class event key"] == 8

      subject.instance_variable_get(:@deleted_ids) == ["previous ID","ID"]
      subject.instance_variable_get(:@deleted_id_to_key_values_map)["ID"] == "key values"

      subject.send(:line_read, "line", "time to stamp", "event", "event note", "classy name", "ID", "raw key values")
    end
  end

end
