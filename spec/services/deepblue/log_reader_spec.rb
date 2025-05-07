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
        allow(Deepblue::AllLogFilter).to receive(:new)
      }
      it "calls AllLogFilter.new" do
        expect(Deepblue::AllLogFilter).to receive(:new)

        expect(subject.initialize_filter nil).to be_blank
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
      it "returns filter" do
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

  describe "#input_mode" do
    before {
      allow(subject).to receive(:option).with(key: 'input_mode', default_value: 'r').and_return ("trail mix")
    }
    it "calls option function" do
      expect(subject).to receive(:option).with(key: 'input_mode', default_value: 'r')

      expect(subject.input_mode).to eq "trail mix"
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

  pending "#readlines"

end
