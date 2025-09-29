require 'rails_helper'

RSpec.describe Deepblue::PublicationLogReporter do

  describe "#initialize" do
    it "calls super" do
      expect(Deepblue::EventLogFilter).to receive(:new) #.with(matching_events: ["publish"])
      Deepblue::PublicationLogReporter::PublishedLogFilter.new
    end

    skip "Add a test that includes parameters"
  end



  subject { described_class.new(input: "input") }

  describe "#initialize" do
    context "when filter not present" do
      it "calls super" do
        expect(Deepblue::EventLogFilter).to receive(:new)
        Deepblue::PublicationLogReporter.new( input: "word processed", options: { "radical" => "vernacular" })
      end
    end

    skip "Add a test for super with parameters"

    context "when filter is present" do
      it "calls super and filter_and" do
        skip "Sdd a test"
      end
    end
  end


  describe "#report" do
    before {
      allow(subject).to receive(:run)
      allow(subject).to receive(:timestamp_first).and_return "6/1/2025"
      allow(subject).to receive(:timestamp_last).and_return "7/1/2025"
      allow(subject).to receive(:published_id).and_return [456]
    }

    context "when creator and subject_discipline are strings" do
      before {
        key_values = { "timestamp" => "6/2/2025", "authoremail" => "unknown@example.edu", "creator" => "the user", "subject_discipline" => "disciplinary subject" }
        allow(subject).to receive(:published_id_to_key_values_map).and_return [].insert(456, key_values)
      }
      it "calls run" do
        expect(subject).to receive(:puts).with "timestamp_first = 6/1/2025"
        expect(subject).to receive(:puts).with "timestamp_last = 7/1/2025"
        expect(subject).to receive(:puts).with "published_id.size = 1"
        expect(subject).to receive(:puts).with "id,published,url,authoremail,creator,subject_discipline,primary filetype"
        expect(subject).to receive(:puts).with "\"456\",6/2/2025,https://deepbluedata.lib.umich.edu/data/concern/data_sets/456,unknown@example.edu,\"the user\",\"disciplinary subject\""

        subject.report
      end
    end

    context "when creator and subject_discipline are arrays" do
      before {
        key_values = { "timestamp" => "6/2/2025", "authoremail" => "unknown@example.edu", "creator" => ["first user", "last user"], "subject_discipline" => ["subject 1", "subject 2"] }
        allow(subject).to receive(:published_id_to_key_values_map).and_return [].insert(456, key_values)
      }
      it "calls run" do
        expect(subject).to receive(:puts).with "timestamp_first = 6/1/2025"
        expect(subject).to receive(:puts).with "timestamp_last = 7/1/2025"
        expect(subject).to receive(:puts).with "published_id.size = 1"
        expect(subject).to receive(:puts).with "id,published,url,authoremail,creator,subject_discipline,primary filetype"
        expect(subject).to receive(:puts).with "\"456\",6/2/2025,https://deepbluedata.lib.umich.edu/data/concern/data_sets/456,unknown@example.edu,\"first user;last user\",\"subject 1;subject 2\""

        subject.report
      end
    end

    after {
      expect(subject).to have_received(:run)
    }
  end


  # protected methods

  describe "#initialize_report_values" do
    before {
      subject.instance_variable_set(:@published_id, [1,2,3])
      subject.instance_variable_set(:@published_id_to_key_values_map, [{ :id => 789, :published => true }])
    }
    it "calls super and sets instance variables to empty" do
      subject.send(:initialize_report_values)

      # called in super
      expect(subject.instance_variable_get(:@lines_reported)).to eq 0
      expect(subject.instance_variable_get(:@timestamp_first)).blank? == true
      expect(subject.instance_variable_get(:@timestamp_last)).blank? == true
      expect(subject.instance_variable_get(:@events)).to be_empty
      expect(subject.instance_variable_get(:@class_events)).to be_empty
      expect(subject.instance_variable_get(:@ids)).to be_empty

      expect(subject.instance_variable_get(:@published_id)).to be_empty
      expect(subject.instance_variable_get(:@published_id_to_key_values_map)).to be_empty
    end
  end


  describe "#line_read" do
    before {
      subject.instance_variable_set(:@lines_reported, 0)
      subject.instance_variable_set(:@events, { "event" => 0 })
      subject.instance_variable_set(:@ids, {})
      allow(subject).to receive(:class_event_key).with(class_name: "class name", event: "event").and_return "class event key"
      subject.instance_variable_set(:@class_events, { "class event key" => 0})

      subject.instance_variable_set(:@published_id, [1,2,3])
      subject.instance_variable_set(:@published_id_to_key_values_map, { })
      allow(Deepblue::ProvenanceHelper).to receive(:parse_log_line_key_values).with("raw").and_return "processed key values"
    }
    it "sets instance variables" do
      subject.send(:line_read, "line", "timestamp", "event", "event note", "class name", 99, "raw")

      # called in super
      expect(subject.instance_variable_get(:@lines_reported)).to eq 1
      expect(subject.instance_variable_get(:@timestamp_first)).to eq "timestamp"
      expect(subject.instance_variable_get(:@timestamp_last)).to eq "timestamp"
      expect(subject.instance_variable_get(:@ids)[99]).to eq true
      expect(subject.instance_variable_get(:@events)["event"]).to eq 1
      expect(subject.instance_variable_get(:@class_events)["class event key"]) == 1

      expect(subject.instance_variable_get(:@published_id)).to eq [1,2,3,99]
      expect(subject.instance_variable_get(:@published_id_to_key_values_map)[99]).to eq "processed key values"
    end
  end

end
