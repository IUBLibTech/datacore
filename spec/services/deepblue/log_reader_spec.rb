require 'rails_helper'

class MockLogFilter

  def initialize ( all_log_filter = false )
    @all_log_filter = all_log_filter
  end
  def all_log_filter?
    @all_log_filter
  end

  def and ( new_filters: )
    "bran flakes"
  end

  def to_ary
    [self]
  end

  def or (new_filters: )
    "corn flakes"
  end
end

class MockInputFile

  def initialize()
    @eof = true
  end
  def eof?
    @eof = !@eof
  end

  def readline
    "Read this line here!?"
  end

  def close
  end
end


class MockInputFilter

  def initialize(next_line)
    @next_line = next_line
  end

  def filter_in(parsed_timestamp,
                parsed_event,
                parsed_event_note,
                parsed_class_name,
                parsed_id,
                parsed_raw_key_values)
    @next_line
  end
end


RSpec.describe Deepblue::LogReader do
  let( :initial_filter ) { MockLogFilter.new all_log_filter: true}
  subject { described_class.new(filter: initial_filter, input: "input", options: {"red" => "green"} ) }

  describe 'constants' do
    it do
      expect( Deepblue::LogReader::DEFAULT_BEGIN_TIMESTAMP ).to be_blank
      expect( Deepblue::LogReader::DEFAULT_END_TIMESTAMP ).to be_blank
      expect( Deepblue::LogReader::DEFAULT_TIMESTAMP_FORMAT ).to be_blank
      expect( Deepblue::LogReader::DEFAULT_VERBOSE ).to eq false
      expect( Deepblue::LogReader::DEFAULT_VERBOSE_FILTER ).to eq false
    end
  end

  describe "#initialize" do
    it "sets instance variables" do
      subject.instance_variable_get(:@filter) == initial_filter
      subject.instance_variable_get(:@input) == "input"
      subject.instance_variable_get(:@options) == {"red" => "green"}
      subject.instance_variable_get(:@verbose) == false
      subject.instance_variable_get(:@verbose_filter) == false
    end

    it "calls add_date_range_filter" do
      skip "Add a test"
    end
  end

  describe "#initialize_filter" do
    context "when filter is blank" do
      before {
        allow(Deepblue::AllLogFilter).to receive(:new).and_return "all log filter"
      }
      it "calls AllLogFilter.new" do
        expect(Deepblue::AllLogFilter).to receive(:new)

        expect(subject.initialize_filter nil).to eq "all log filter"
      end
    end

    context "when filter is an array" do
      before {
        allow(Deepblue::AndLogFilter).to receive(:new).with( filters: ["filtration", "salination"], options: {}).and_return "particulate matter"
      }
      it "calls AndLogFilter.new" do
        allow(Deepblue::AndLogFilter).to receive(:initialize).with( filters: ["filtration", "salination"], options: {})

        expect(subject.initialize_filter ["filtration", "salination"]).to eq "particulate matter"
      end
    end

    context "when filter is not an array and not blank" do
      it "returns filter argument" do
        expect(subject.initialize_filter "condensation").to eq "condensation"
      end
    end
  end


  describe "#add_date_range_filter" do

    context "when option function returns blank every time" do
      before {
        allow(subject).to receive("option").with(key: 'begin')
        allow(subject).to receive("option").with(key: 'begin_timestamp', default_value: '')

        allow(subject).to receive("option").with(key: 'end')
        allow(subject).to receive("option").with(key: 'end_timestamp', default_value: '')

        allow(subject).to receive("option").with(key: 'format')
        allow(subject).to receive("option").with(key: 'timestamp_format', default_value: '')

        allow(subject).to receive("verbose_filter").and_return(false)
      }
      it "returns nil" do
        expect(subject).to receive("option").with(key: 'begin')
        expect(subject).to receive("option").with(key: 'begin_timestamp', default_value: '')

        expect(subject).to receive("option").with(key: 'end')
        expect(subject).to receive("option").with(key: 'end_timestamp', default_value: '')

        expect(subject).to receive("option").with(key: 'format')
        expect(subject).to receive("option").with(key: 'timestamp_format', default_value: '')

        expect(subject.add_date_range_filter).to be_blank
      end
    end

    context "when begin_timestamp and end_timestamp not blank and verbose_filter" do
      before {
        allow(subject).to receive("option").with(key: 'begin').and_return( "good times" )
        allow(subject).to receive("option").with(key: 'end').and_return( "best times" )
        allow(subject).to receive("option").with(key: 'format').and_return( "worst times" )

        allow(subject).to receive("verbose_filter").and_return( true )

        allow(Deepblue::DateLogFilter).to receive("new").with( begin_timestamp: "good times" ,
                                                               end_timestamp: "best times" ,
                                                               timestamp_format: "worst times",
                                                               options: Hash.new(["wherefore" => "whyfor"]) )
                                                        .and_return( "home on the range" )
        allow(subject).to receive("filter_and").with( new_filters: "home on the range" )
      }
      it "calls DateLogFilter.new and filter_and" do
        expect(subject).to receive("option").with(key: 'begin')
        expect(subject).to receive("option").with(key: 'end')
        expect(subject).to receive("option").with(key: 'format')

        expect(subject).to receive("puts").with "add_date_range_filter begin_timestamp=good times end_timestamp=best times"

        expect(Deepblue::DateLogFilter).to receive("new").with( begin_timestamp: "good times" ,
                                                               end_timestamp: "best times" ,
                                                               timestamp_format: "worst times",
                                                               options: Hash.new(["wherefore" => "whyfor"]) )
        expect(subject).to receive("filter_and").with( new_filters: "home on the range" )

        expect(subject.add_date_range_filter options: Hash.new(["wherefore" => "whyfor"])).to be_blank
      end
    end
  end

  describe "#filter_and" do
    context "when new_filters is blank" do
      it "returns blank" do

        expect(subject.filter_and new_filters: nil).to be_blank
      end
    end

    context "when verbose" do
      before {
        allow(subject).to receive(:verbose).and_return(true)
        allow(subject).to receive(:filter_refresh).with( current_filter: initial_filter, new_filters: "consonant", append: true, options: {} )
                                                  .and_return "globalization"
        allow(subject).to receive(:puts).with( "filter_and @filter=globalization" )
      }

      it "outputs string" do
        expect(subject).to receive(:filter_refresh).with( current_filter: initial_filter, new_filters: "consonant", append: true, options: {} )
        expect(subject).to receive(:puts).with("filter_and @filter=globalization" )

        subject.filter_and new_filters: "consonant"
      end
    end
  end

  describe "#filter_refresh" do

    context "when current_filter.all_log_filter is true and new_filters is an array" do
      before {
        allow(Deepblue::AndLogFilter).to receive(:new).with( filters: ["pop", "corn"], options: {} ).and_return "cornflakes"
      }

      it "return new_filters" do
        expect(subject.filter_refresh current_filter: MockLogFilter.new( all_log_filter = true ), new_filters: ["pop", "corn"]).to eq "cornflakes"
      end
    end

    context "when current_filter.all_log_filter is true and new_filters is not an array" do
      it "return new_filters" do
        expect(subject.filter_refresh current_filter: MockLogFilter.new( all_log_filter = true ), new_filters: "brand new").to eq "brand new"
      end
    end

    context "when current_filter.all_log_filter is false and append is true" do
      it "return new_filters" do
        expect(subject.filter_refresh current_filter: MockLogFilter.new, new_filters: "brand new", append: true).to eq "bran flakes"
      end
    end

    context "when current_filter.all_log_filter is false and append is false" do
      it "return new_filters" do
        currentFilter = MockLogFilter.new
        newFilter = MockLogFilter.new
        expect(Deepblue::AndLogFilter).to receive(:new).with(filters: [newFilter, currentFilter], options: {1 => "Alpha"})
        expect(subject.filter_refresh current_filter: currentFilter, new_filters: newFilter, append: false, options: {1 => "Alpha"})
      end
    end
  end


  describe "#filter_or" do
    context "when new_filters is blank" do
      it "returns blank" do

        expect(subject.filter_or new_filters: []).to be_blank
      end
    end

    context "when new_filters is not blank and LogReader initialized with filter that has all_log_filter true" do

      it "when current_filter all_log_filter is true" do
        expect(subject.filter_or new_filters: MockLogFilter.new, append: true).to eq initial_filter
      end
    end

    context "when new_filters is not blank and LogReader initialized with filter that has all_log_filter false" do
      subject { described_class.new(filter: MockLogFilter.new, input: "input" ) }

      it "returns current_filter or new_filters when append is true" do
        expect(subject.filter_or new_filters: MockLogFilter.new, append: true).to eq "corn flakes"
      end
    end

    context "when new_filters is not blank and LogReader initialized with filter that has all_log_filter false and append false" do
      firstFilter = MockLogFilter.new
      secondFilter = MockLogFilter.new
      subject { described_class.new(filter: firstFilter, input: "input" ) }

      it "returns   " do
        expect(Deepblue::OrLogFilter).to receive(:new).with(filters: [secondFilter, firstFilter], options: {10 => "Omega"})
        subject.filter_or new_filters: secondFilter, append: false, options: {10 => "Omega"}
      end
    end
  end


  describe "#input mode" do
    before {
      allow(subject).to receive(:option).with(key: 'input_mode', default_value: "r").and_return "substantial"
    }
    context "when instance variable has a value" do
      before {
        subject.instance_variable_set(:@input_mode, "optionally")
      }
      it "returns instance variable" do
        expect(subject).not_to receive(:option)
        expect(subject.input_mode).to eq "optionally"
        subject.instance_variable_get(:@input_mode) == "optionally"
      end
    end

    context "when instance variable does not have a value" do
      it "calls option function" do
        expect(subject).to receive(:option)
        expect(subject.input_mode).to eq "substantial"
        subject.instance_variable_get(:@input_mode) == "substantial"
      end
    end
  end


  describe "#parse_line" do

    context "when @current_line is blank" do
      before {
        subject.instance_variable_set(:@current_line, " ")
      }
      it "returns" do
        expect(Deepblue::ProvenanceHelper).not_to receive(:parse_log_line).with any_args
        subject.parse_line
      end
    end

    context "when LogParseError is raised" do
      before {
        subject.instance_variable_set(:@current_line, "linear")
        subject.instance_variable_set(:@lines_read, 22)
        allow(Deepblue::ProvenanceHelper).to receive(:parse_log_line).and_raise(Deepblue::LogParseError, "log parse error")
      }

      it "puts LogParseError message" do
        expect(subject).to receive(:puts).with("log parse error")
        subject.parse_line
      end
    end

    context "when @current_line is not blank" do
      before {
        subject.instance_variable_set(:@current_line, "linear")
        subject.instance_variable_set(:@lines_read, 22)
        subject.instance_variable_set(:@lines_parsed, 0)
      }

      it "calls ProvenanceHelper" do
        expect(Deepblue::ProvenanceHelper).to receive(:parse_log_line).with("linear", line_number: 22, raw_key_values: true)
        subject.parse_line
        subject.instance_variable_get(:@lines_parsed) == 1
        subject.instance_variable_get(:@parsed) == true
      end
    end
  end

  describe "#quick_report" do
    before {
      subject.instance_variable_set(:@input_pathname, "strawberries")
      subject.instance_variable_set(:@lines_read, "watermelon")
      subject.instance_variable_set(:@lines_parsed, "yuzu")
    }

    it "outputs text" do
      expect(subject).to receive(:puts).with no_args
      expect(subject).to receive(:puts).with "Quick report"
      expect(subject).to receive(:puts).with "input_pathname: strawberries"
      expect(subject).to receive(:puts).with "lines_read: watermelon"
      expect(subject).to receive(:puts).with "lines_parsed: yuzu"

      subject.quick_report
    end
  end


  describe "#readlines" do
    before {
      subject.instance_variable_set(:@lines_parsed, "default")
      subject.instance_variable_set(:@current_line, "default")

      subject.instance_variable_set(:@parsed_timestamp, "Time Stamp")
      subject.instance_variable_set(:@parsed_event, "Event Name")
      subject.instance_variable_set(:@parsed_event_note, "Event Note")
      subject.instance_variable_set(:@parsed_class_name, "Class Name")
      subject.instance_variable_set(:@parsed_id, "ID#")
      subject.instance_variable_set(:@parsed_raw_key_values, "raw key values...")

      allow(subject).to receive(:log_open_input)
      allow(subject).to receive(:log_close_input)
    }

    context "when no block provided and input at end of file" do
      before {
        subject.instance_variable_set(:@lines_read, "default")
        subject.instance_variable_set(:@input, OpenStruct.new(eof?: true))

        allow(subject).to receive(:filter)
      }
      it "sets instance variables to zero or blank" do
        subject.readlines

        subject.instance_variable_get(:@lines_parsed) == 0
        subject.instance_variable_get(:@lines_read) == 0
        subject.instance_variable_get(:@current_line).blank? == true
      end
    end

    context "when input provided" do
      before {
        subject.instance_variable_set(:@lines_read, 0)
        allow(subject).to receive(:parse_line)
      }

      context "when @parsed is false" do
        before {
          subject.instance_variable_set(:@parsed, false)
          subject.instance_variable_set(:@input, MockInputFile.new)
          allow(subject).to receive(:filter)
        }

        it "calls parse_line" do
          subject.readlines
        end
      end

      context "when @parsed is true" do
        before {
          subject.instance_variable_set(:@parsed, true)
          subject.instance_variable_set(:@input, MockInputFile.new)
        }

        context "when filter.filter_in returns false" do
          mock_filter = MockInputFilter.new(false)
          before {
            allow(subject).to receive(:filter).and_return mock_filter
          }
          it "calls parse_line and filter_in" do
            expect(mock_filter).to receive(:filter_in).with("Time Stamp", "Event Name", "Event Note", "Class Name", "ID#", "raw key values...")

            subject.readlines
          end

          specify { expect { |b| subject.readlines(&b) }.not_to yield_control }  # method does not reach block
        end

        context "when filter.filter_in returns true" do
          filter_mock = MockInputFilter.new(true)
          before {
            allow(subject).to receive(:filter).and_return filter_mock
          }
          it "calls parse_line and filter_in" do
            expect(filter_mock).to receive(:filter_in).with("Time Stamp", "Event Name", "Event Note", "Class Name", "ID#", "raw key values...")

            subject.readlines
          end

          specify { expect { |b| subject.readlines(&b) }.to yield_with_args }  # method reaches block which yields with arguments
        end
      end

      after {
        expect(subject).to have_received(:parse_line)

        subject.instance_variable_get(:@current_line) == "Read this line here!"
        subject.instance_variable_get(:@lines_read) == 1
      }
    end

    after {
      expect(subject).to have_received(:log_open_input)
      expect(subject).to have_received(:log_close_input)
    }
  end


  # protected methods

  describe "#log_close_input" do
    close_input = MockInputFile.new
    before {
      subject.instance_variable_set(:@input, close_input)
    }

    context "when @input_close is false" do
      before {
        subject.instance_variable_set(:@input_close, false)
      }
      it "does not call close on @input" do
        expect(close_input).not_to receive(:close)
        subject.send(:log_close_input)
      end
    end

    context "when @input_close is true and @input has a value" do
      before {
        subject.instance_variable_set(:@input_close, true)
      }
      it "calls close on @input" do
        expect(close_input).to receive(:close)
        subject.send(:log_close_input)
      end
    end
  end


  describe "#log_open_input" do
    path_name = Pathname.new("/tmp")

    context "when @input is a string file location that exists" do
      before {
        subject.instance_variable_set(:@input, "/tmp")
        allow(subject).to receive(:open).with(path_name, 'r').and_return "string pathname"
      }
      it "creates Pathname with string and opens it, sets instance variables" do
        expect(subject).to receive(:open).with(path_name, 'r')
        subject.send(:log_open_input)

        subject.instance_variable_get(:@input) == "string pathname"
        subject.instance_variable_get(:@input_close) == true
      end
    end

    context "when @input is a Pathname that exists" do
      before {
        subject.instance_variable_set(:@input, path_name)
        allow(subject).to receive(:open).with(path_name, 'r').and_return "original pathname"
      }
      it "opens Pathname and sets instance variables" do
        expect(subject).to receive(:open).with(path_name, 'r')
        subject.send(:log_open_input)

        subject.instance_variable_get(:@input) == "original pathname"
        subject.instance_variable_get(:@input_close) == true
      end
    end

    context "when @input Pathname does not exist" do
      before {
        subject.instance_variable_set(:@input, "message")
      }
      it "does not open pathname or set instance variables" do
        expect(subject).not_to receive(:open)
        subject.send(:log_open_input)

        subject.instance_variable_get(:@input).blank? == true
        subject.instance_variable_get(:@input_close).blank? == true
      end
    end
  end


  describe "#option" do
    context "when key is not an option" do
      before {
        allow(subject).to receive(:options_key?).with("platinum").and_return false
      }
      it "returns default value" do
        expect(subject.send(:option, key: "platinum", default_value: "nickel")).to eq "nickel"
      end
    end

    context "when key is an option" do
      before {
        allow(subject).to receive(:options_key?).with("silver").and_return true
        allow(subject).to receive(:options_key?).with(:silver).and_return true
        allow(subject).to receive(:options_key?).with("gold").and_return true
        allow(subject).to receive(:options_key?).with(["copper"]).and_return true

        subject.instance_variable_set(:@options, { "silver" => "treasure chest", :gold => "fort knox" })
      }
      it "returns @options key value" do
        expect(subject.send(:option, key: "silver", default_value: "tin")).to eq "treasure chest"
        expect(subject.send(:option, key: :silver, default_value: "tin")).to eq "treasure chest"
        expect(subject.send(:option, key: "gold", default_value: "brass")).to eq "fort knox"
      end

      it "returns default value if key is not a string or a symbol" do
        expect(subject.send(:option, key: ["copper"], default_value: "bronze")).to eq "bronze"
      end
    end
  end


  describe "#options_key?" do
    before {
      subject.instance_variable_set(:@options, { "apple" => "honeycrisp", :orange => "blood" })
    }
    it "returns true if key is present" do
      expect(subject.send(:options_key?, "apple")).to eq true
    end

    it "returns true if key is present as a symbol but entered as a string" do
      expect(subject.send(:options_key?, "orange")).to eq true
    end

    it "returns true if key is present as a string but entered as a symbol" do
      expect(subject.send(:options_key?, :apple)).to eq true
    end

    it "returns false if key is absent" do
      expect(subject.send(:options_key?, "pear")).to eq false
    end

  end

end
