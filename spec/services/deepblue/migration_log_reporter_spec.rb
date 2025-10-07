require 'rails_helper'

RSpec.describe Deepblue::MigrationLogReporter do

  subject { described_class.new(input: "input", options: {}) }


  describe "constants" do
    it do
      expect(Deepblue::MigrationLogReporter::DEFAULT_EXPECTED_IDS_PATHNAME).to be_nil
    end
  end


  describe "#initialize" do
    context "when filter parameter is nil" do
      skip "Add a test"
    end

    context "when filter parameter has a value" do
      skip "Add a test"
    end
  end


  describe "#report" do
    before {
      subject.instance_variable_set(:@timestamp_first, "timestamp first")
      subject.instance_variable_set(:@timestamp_last, "timestamp last")
      subject.instance_variable_set(:@ids, [1, 2, 3, 4])
      subject.instance_variable_set(:@events, [5, 6, 7])
      subject.instance_variable_set(:@class_events, [8, 9])
      subject.instance_variable_set(:@collection_ids, [0, 10, 11, 12, 13])
      subject.instance_variable_set(:@work_ids, [14, 15, 16, 17, 18, 19])
      subject.instance_variable_set(:@file_set_ids, [20, 21, 22, 23, 24])
      subject.instance_variable_set(:@fixity_check_failed_ids, [25, 26, 27, 28])
      subject.instance_variable_set(:@fixity_check_passed_ids, [29, 30, 31])
      subject.instance_variable_set(:@unexpected_collection_ids, [0, 13])
      subject.instance_variable_set(:@missing_collection_ids, [32])
      subject.instance_variable_set(:@expected_collection_ids, [32, 33])
      subject.instance_variable_set(:@unexpected_work_ids, [14, 15, 16, 17, 18])
      subject.instance_variable_set(:@missing_work_ids, [34, 35, 36])
      subject.instance_variable_set(:@expected_work_ids, [34, 35, 36, 37])
      subject.instance_variable_set(:@unexpected_file_set_ids, [20, 21, 22, 23])
      subject.instance_variable_set(:@missing_file_set_ids, [38, 39, 40])
      subject.instance_variable_set(:@expected_file_set_ids, [38, 39, 40, 41])

      allow(subject).to receive(:run)
      allow(subject).to receive(:run_rest)
    }
    it "calls run, run_rest, and then puts multiple times" do
      expect(subject).to receive(:run)
      expect(subject).to receive(:run_rest)
      expect(subject).to receive(:puts).with "timestamp_first = timestamp first"
      expect(subject).to receive(:puts).with "timestamp_last = timestamp last"
      expect(subject).to receive(:puts).with "ids.count = 4"
      expect(subject).to receive(:puts).with "events.count = 3"
      expect(subject).to receive(:puts).with "class_events.count = 2"
      expect(subject).to receive(:puts).with "class_events = [8, 9]"
      expect(subject).to receive(:puts).with "migrated collection_ids.count=5"
      expect(subject).to receive(:puts).with "migrated work_ids.count=6"
      expect(subject).to receive(:puts).with "migrated file_set_ids.count=5"
      expect(subject).to receive(:puts).with "migrated file set fixity_check_failed_ids.count=4"
      expect(subject).to receive(:puts).with "migrated file set fixity_check_passed_ids.count=3"
      expect(subject).to receive(:puts).with "unexpected_collection_ids.count=2 (out of 5 migrated)"
      expect(subject).to receive(:puts).with "missing_collection_ids.count=1 (out of 2 expected)"
      expect(subject).to receive(:puts).with "unexpected_work_ids.count=5 (out of 6 migrated)"
      expect(subject).to receive(:puts).with "missing_work_ids.count=3 (out of 4 expected)"
      expect(subject).to receive(:puts).with "unexpected_file_set_ids.count=4 (out of 5 migrated)"
      expect(subject).to receive(:puts).with "missing_file_set_ids.count=3 (out of 4 expected)"

      subject.report
    end
  end


  # protected methods

  describe "#expected_collections_csv_file" do
    it "returns .csv file relative location" do
      expect(subject.send(:expected_collections_csv_file)).to eq "./log/20180911_collections_report_collections.csv"
    end
  end

  describe "#expected_file_sets_csv_file" do
    it "returns .csv file relative location" do
      expect(subject.send(:expected_file_sets_csv_file)).to eq "./log/20180911_collections_report_file_sets.csv"
    end
  end

  describe "#expected_works_csv_file" do
    it "returns .csv file relative location" do
      expect(subject.send(:expected_works_csv_file)).to eq "./log/20180911_collections_report_works.csv"
    end
  end


  describe "#initialize_expected" do
    before{
      allow(subject).to receive(:initialize_expected_collection_ids)
      allow(subject).to receive(:initialize_expected_work_ids)
      allow(subject).to receive(:initialize_expected_file_set_ids)
    }
    it "calls functions" do
      expect(subject).to receive(:initialize_expected_collection_ids)
      expect(subject).to receive(:initialize_expected_work_ids)
      expect(subject).to receive(:initialize_expected_file_set_ids)

      subject.send(:initialize_expected)
    end
  end

  let(:data) do
    [
      ['Alice', 'alice@example.com', "", "", "", "", "", "", "a"],
      ['Bob', 'bob@example.com', "", "", "", "", "", "", "b c"],
      ['Clara', 'clara@example.com', "", "", "", "", "", "", "d e f"],
      ['Derek', 'derek@example.com', "", "", "", "", "", "", ""]
    ]
  end

  describe "#initialize_expected_collection_ids" do
    before {
      allow(subject).to receive(:expected_collections_csv_file).and_return "an unsuspecting CSV file"
      allow(CSV).to receive(:foreach).with("an unsuspecting CSV file").and_yield(data[0]).and_yield(data[1]).and_yield(data[2]).and_yield(data[3])
    }

    it "saves hash to instance variable" do
      subject.send(:initialize_expected_collection_ids)
      expect(subject.instance_variable_get(:@expected_collection_ids)).to eq "Alice" => true, "Bob" => true, "Clara" => true, "Derek" => true
    end

    skip "Add a test for work_ids"
  end


  describe "#initialize_expected_file_set_ids" do
    before {
      allow(subject).to receive(:expected_file_sets_csv_file).and_return "a generic CSV file"
      allow(CSV).to receive(:foreach).with("a generic CSV file").and_yield(data[0]).and_yield(data[1]).and_yield(data[2]).and_yield(data[3])
    }

    it "saves hash to instance variable" do
      subject.send(:initialize_expected_file_set_ids)
      expect(subject.instance_variable_get(:@expected_file_set_ids)).to eq "Alice" => "alice@example.com", "Bob" => "bob@example.com", "Clara" => "clara@example.com", "Derek" => "derek@example.com"
    end
  end


  describe "#initialize_expected_work_ids" do
    before {
      allow(subject).to receive(:expected_works_csv_file).and_return "another CSV file"
      allow(CSV).to receive(:foreach).with("another CSV file").and_yield(data[0]).and_yield(data[1]).and_yield(data[2]).and_yield(data[3])
    }

    it "saves hash to instance variable" do
      subject.send(:initialize_expected_work_ids)
      expect(subject.instance_variable_get(:@expected_work_ids)).to eq "Alice" => {"a" => true}, "Bob" => {"b" => true, "c" => true}, "Clara" => {"d" => true, "e" => true, "f" => true}, "Derek" => {}
    end
  end


  describe "#initialize_report_values" do
    before {
      subject.instance_variable_set(:@collection_ids, [1, 2, 3, 4])
      subject.instance_variable_set(:@file_set_ids, [1, 2, 3, 4])
      subject.instance_variable_set(:@work_ids, [1, 2, 3, 4])
      subject.instance_variable_set(:@fixity_check_failed_ids, [1, 2, 3, 4])
      subject.instance_variable_set(:@fixity_check_passed_ids, [1, 2, 3, 4])
      subject.instance_variable_set(:@missing_collection_ids, [1, 2, 3, 4])
      subject.instance_variable_set(:@unexpected_collection_ids, [1, 2, 3, 4])
      subject.instance_variable_set(:@missing_work_ids, [1, 2, 3, 4])
      subject.instance_variable_set(:@unexpected_work_ids, [1, 2, 3, 4])
      subject.instance_variable_set(:@missing_file_set_ids, [1, 2, 3, 4])
      subject.instance_variable_set(:@unexpected_file_set_ids, [1, 2, 3, 4])

      allow(subject).to receive(:initialize_expected)
    }
    it "calls initialize_expected and sets instance variables to empty" do
      expect(subject).to receive(:initialize_expected)

      subject.send(:initialize_report_values)

      expect(subject.instance_variable_get(:@collection_ids)).to be_blank
      expect(subject.instance_variable_get(:@file_set_ids)).to be_blank
      expect(subject.instance_variable_get(:@work_ids)).to be_blank
      expect(subject.instance_variable_get(:@fixity_check_failed_ids)).to be_blank
      expect(subject.instance_variable_get(:@fixity_check_passed_ids)).to be_blank
      expect(subject.instance_variable_get(:@missing_collection_ids)).to be_blank
      expect(subject.instance_variable_get(:@unexpected_collection_ids)).to be_blank
      expect(subject.instance_variable_get(:@missing_work_ids)).to be_blank
      expect(subject.instance_variable_get(:@unexpected_work_ids)).to be_blank
      expect(subject.instance_variable_get(:@missing_file_set_ids)).to be_blank
      expect(subject.instance_variable_get(:@unexpected_file_set_ids)).to be_blank

      #testing super method
      expect(subject.instance_variable_get(:@lines_reported)).to eq 0
      expect(subject.instance_variable_get(:@timestamp_first)).to be_blank
      expect(subject.instance_variable_get(:@timestamp_last)).to be_blank
      expect(subject.instance_variable_get(:@events)).to be_empty
      expect(subject.instance_variable_get(:@class_events)).to be_empty
      expect(subject.instance_variable_get(:@ids)).to be_empty
    end
  end


  describe "#line_read" do
    before {
      #setup for super method
      subject.instance_variable_set(:@lines_reported, 0)
      subject.instance_variable_set(:@ids, {})

      subject.instance_variable_set(:@key_values, [5, 6, 7, 8])

      allow(subject).to receive(:register_migrate).with("timestamp", "migrate", "event note", "class_name", "id")
      allow(subject).to receive(:register_ingest).with("timestamp", "ingest", "event note", "class_name", "id")
      allow(subject).to receive(:register_child_add).with("timestamp", "ingest", "event note", "class_name", "id")
    }

    context "when event is AbstractEventBehavior::EVENT_MIGRATE" do
      before {
        subject.instance_variable_set(:@events, {"migrate" => 0})
        subject.instance_variable_set(:@class_events, {"class_name_migrate" => 0})
      }
      it "calls super, then calls register_migrate with parameters" do
        expect(subject).to receive(:register_migrate).with("timestamp", "migrate", "event note", "class_name", "id")

        subject.send(:line_read, "line", "timestamp", Deepblue::AbstractEventBehavior::EVENT_MIGRATE, "event note", "class_name", "id", "01101101 01100101")
        
        # testing super method
        expect(subject.instance_variable_get(:@events)["migrate"]).to eq 1
        expect(subject.instance_variable_get(:@class_events)["class_name_migrate"]).to eq 1
      end
    end

    context "when event is AbstractEventBehavior::EVENT_INGEST" do
      before {
        subject.instance_variable_set(:@events, {"ingest" => 0})
        subject.instance_variable_set(:@class_events, {"class_name_ingest" => 0})
      }
      it "calls super, then calls register_ingest with parameters" do
        expect(subject).to receive(:register_ingest).with("timestamp", "ingest", "event note", "class_name", "id")

        subject.send(:line_read, "line", "timestamp", Deepblue::AbstractEventBehavior::EVENT_INGEST, "event note", "class_name", "id", "01101101 01100101")

        # testing super method
        expect(subject.instance_variable_get(:@events)["ingest"]).to eq 1
        expect(subject.instance_variable_get(:@class_events)["class_name_ingest"]).to eq 1
      end
    end

    context "when event is AbstractEventBehavior::EVENT_CHILD_ADD" do
      before {
        subject.instance_variable_set(:@events, {"child_add" => 0})
        subject.instance_variable_set(:@class_events, {"class_name_child_add" => 0})
      }
      it "calls super, then calls register_child_add with parameters" do
        expect(subject).to receive(:register_child_add).with("timestamp", "child_add", "event note", "class_name", "id")

        subject.send(:line_read, "line", "timestamp", Deepblue::AbstractEventBehavior::EVENT_CHILD_ADD, "event note", "class_name", "id", "01101101 01100101")

        # testing super method
        expect(subject.instance_variable_get(:@events)["child_add"]).to eq 1
        expect(subject.instance_variable_get(:@class_events)["class_name_child_add"]).to eq 1
      end
    end

    context "when event is AbstractEventBehavior::EVENT_FIXITY_CHECK" do
      before {
        subject.instance_variable_set(:@events, {"fixity_check" => 0})
        subject.instance_variable_set(:@class_events, {"class_name_fixity_check" => 0})
      }
      it "calls super, then calls register_fixity_check with parameters" do
        expect(subject).to receive(:register_fixity_check).with("timestamp", "fixity_check", "event note", "class_name", "id")

        subject.send(:line_read, "line", "timestamp", Deepblue::AbstractEventBehavior::EVENT_FIXITY_CHECK, "event note", "class_name", "id", "01101101 01100101")

        # testing super method
        expect(subject.instance_variable_get(:@events)["fixity_check"]).to eq 1
        expect(subject.instance_variable_get(:@class_events)["class_name_fixity_check"]).to eq 1
      end
    end

    context "when event is AbstractEventBehavior::EVENT_VIRUS_SCAN" do
      before {
        subject.instance_variable_set(:@events, {"virus_scan" => 0})
        subject.instance_variable_set(:@class_events, {"class_name_virus_scan" => 0})
      }
      it "calls super, then calls register_virus_scan with parameters" do
        expect(subject).to receive(:register_virus_scan).with("timestamp", "virus_scan", "event note", "class_name", "id")

        subject.send(:line_read, "line", "timestamp", Deepblue::AbstractEventBehavior::EVENT_VIRUS_SCAN, "event note", "class_name", "id", "01101101 01100101")

        # testing super method
        expect(subject.instance_variable_get(:@events)["virus_scan"]).to eq 1
        expect(subject.instance_variable_get(:@class_events)["class_name_virus_scan"]).to eq 1
      end
    end

    after {
      expect(subject.instance_variable_get(:@raw_key_values)).to eq "01101101 01100101"
      expect(subject.instance_variable_get(:@key_values)).to be_nil

      # testing super method
      expect(subject.instance_variable_get(:@lines_reported)).to eq 1
      expect(subject.instance_variable_get(:@timestamp_first)).to eq "timestamp"
      expect(subject.instance_variable_get(:@timestamp_last)).to eq "timestamp"
      expect(subject.instance_variable_get(:@ids)["id"]).to eq true
    }
  end


  describe "#register_child_add" do
    it "returns nil" do
      expect(subject.send(:register_child_add, "timestamp", "event", "event note", "class name", "ID")).to be_nil
    end
  end


  describe "#register_fixity_check" do
    before {
      subject.instance_variable_set(:@fixity_check_passed_ids, ["first"])
      subject.instance_variable_set(:@fixity_check_failed_ids, ["random"])
    }

    context "when event_note parameter equals 'success'" do
      it "appends id parameter to @fixity_check_passed_ids" do
        subject.send(:register_fixity_check, "timestamp", "event", "success", "class name", "ID")

        expect(subject.instance_variable_get(:@fixity_check_passed_ids)).to eq ["first", "ID"]
        expect(subject.instance_variable_get(:@fixity_check_failed_ids)).to eq ["random"]
      end
    end

    context "when event_note does NOT equal 'success'" do
      it "appends id parameter to @fixity_check_failed_ids" do
        subject.send(:register_fixity_check, "timestamp", "event", "failure", "class name", "ID")

        expect(subject.instance_variable_get(:@fixity_check_passed_ids)).to eq ["first"]
        expect(subject.instance_variable_get(:@fixity_check_failed_ids)).to eq ["random", "ID"]
      end
    end
  end


  describe "#register_ingest" do
    it "returns nil" do
      expect(subject.send(:register_ingest, "timestamp", "event", "event note", "class name", "ID")).to be_nil
    end
  end


  describe "#register_migrate" do
    before {
      subject.instance_variable_set(:@file_set_ids, {})
      subject.instance_variable_set(:@work_ids, {})
      subject.instance_variable_set(:@collection_ids, {})
    }

    context "when class_name parameter is 'FileSet'" do
      context "when @file_set_ids does NOT have the id parameter as a key already" do
        it "add id parameter as key with true as value to instance variable" do
          subject.send(:register_migrate, "timestamp", "event", "event note", "FileSet", "ID")
          expect(subject.instance_variable_get(:@file_set_ids)["ID"]).to eq true
        end
      end

      context "when @file_set_ids already has the id parameter as a key" do
        before {
          subject.instance_variable_set(:@file_set_ids, {"ID" => false})
        }
        it "changes nothing" do
          subject.send(:register_migrate, "timestamp", "event", "event note", "FileSet", "ID")
          expect(subject.instance_variable_get(:@file_set_ids)["ID"]).to eq false
        end
      end
    end

    context "when class_name parameter is 'DataSet'" do
      context "when @work_ids does NOT have the id parameter as a key already" do
        it "add id parameter as key with true as value to instance variable" do
          subject.send(:register_migrate, "timestamp", "event", "event note", "DataSet", "ID")
          expect(subject.instance_variable_get(:@work_ids)["ID"]).to eq true
        end
      end

      context "when @work_ids already has the id parameter as a key" do
        before {
          subject.instance_variable_set(:@work_ids, {"ID" => false})
        }
        it "changes nothing" do
          subject.send(:register_migrate, "timestamp", "event", "event note", "DataSet", "ID")
          expect(subject.instance_variable_get(:@work_ids)["ID"]).to eq false
        end
      end
    end

    context "when class_name parameter is 'Collection'" do
      context "when @collection_ids does NOT have the id parameter as a key already" do
        it "add id parameter as key with true as value to instance variable" do
          subject.send(:register_migrate, "timestamp", "event", "event note", "Collection", "ID")
          expect(subject.instance_variable_get(:@collection_ids)["ID"]).to eq true
        end
      end

      context "when @collection_ids already has the id parameter as a key" do
        before {
          subject.instance_variable_set(:@collection_ids, {"ID" => false})
        }
        it "changes nothing" do
          subject.send(:register_migrate, "timestamp", "event", "event note", "Collection", "ID")
          expect(subject.instance_variable_get(:@collection_ids)["ID"]).to eq false
        end
      end
    end
  end


  describe "#register_virus_scan" do
    it "returns nil" do
      expect(subject.send(:register_virus_scan, "timestamp", "event", "event note", "class name", "ID")).to be_nil
    end
  end


  describe "#run_rest" do
    before {
      subject.instance_variable_set(:@expected_collection_ids, {"1" => true, "2" => true, "3" => true} )
      subject.instance_variable_set(:@expected_work_ids, {"4" => true, "5" => true, "6" => true} )
      subject.instance_variable_set(:@expected_file_set_ids, {"7" => true, "8" => true, "9" => true} )

      subject.instance_variable_set(:@collection_ids, {"3" => true, "10" => true, "11" => true, "12" => true} )
      subject.instance_variable_set(:@work_ids, {"5" => true, "13" => true, "14" => true, "15" => true} )
      subject.instance_variable_set(:@file_set_ids, {"7" => true, "16" => true, "17" => true, "18" => true} )

      subject.instance_variable_set(:@missing_collection_ids, [])
      subject.instance_variable_set(:@missing_work_ids, [])
      subject.instance_variable_set(:@missing_file_set_ids, [])

      subject.instance_variable_set(:@unexpected_collection_ids, [])
      subject.instance_variable_set(:@unexpected_work_ids, [])
      subject.instance_variable_set(:@unexpected_file_set_ids, [])
    }

    it "appends keys to instance variable arrays with names beginning with 'missing' and 'unexpected'" do
      subject.send(:run_rest)

      expect(subject.instance_variable_get(:@missing_collection_ids )).to eq ["1", "2"]
      expect(subject.instance_variable_get(:@missing_work_ids )).to eq ["4", "6"]
      expect(subject.instance_variable_get(:@missing_file_set_ids )).to eq ["8", "9"]

      expect(subject.instance_variable_get(:@unexpected_collection_ids )).to eq ["10", "11", "12"]
      expect(subject.instance_variable_get(:@unexpected_work_ids )).to eq ["13", "14", "15"]
      expect(subject.instance_variable_get(:@unexpected_file_set_ids )).to eq ["16", "17", "18"]
    end
  end


end
