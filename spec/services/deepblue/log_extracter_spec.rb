require 'rails_helper'


describe Deepblue::LogExtracter do

  subject { described_class.new( input: "some musings" ) }

  describe "#initialize" do
    it "sets instance variables" do
      log_extracter = Deepblue::LogExtracter.new(filter: "good filtration", input: "considerations", extract_parsed_tuple: true, options: { "omens" => "good" })

      log_extracter.instance_variable_get(:@extract_parsed_tuple) == true
      log_extracter.instance_variable_get(:@lines_extracted).empty? == true
    end

    skip "Add a test for call to Deepblue::LogReader"
  end


  describe "#extract_line" do
    context "when @extract_parsed_tuple is true" do
      before {
        subject.instance_variable_set(:@extract_parsed_tuple, true)
      }
      it "appends parameters to @lines_extracted" do
        subject.extract_line "extract line", "time stamp", "eventful", "noted!", "classical", "ID_", "raw values"
        subject.instance_variable_get(:@lines_extracted) == ["extract line", "time stamp", "eventful", "noted!", "classical", "ID_", "raw values"]
      end
    end

    context "when @extract_parsed_tuple is false" do
      before {
        subject.instance_variable_set(:@extract_parsed_tuple, false)
      }
      it "appends line parameter to @lines_extracted" do
        subject.extract_line "e line!", "time stamp", "eventful", "noted!", "classical", "ID_", "raw values"
        subject.instance_variable_get(:@lines_extracted) == "e line!"
      end
    end
  end


  describe "#run" do
    it "calls readlines" do
      expect(subject).to receive(:readlines)
      subject.run
    end

    skip "Add a test that includes extract_line and parameters"
  end

end