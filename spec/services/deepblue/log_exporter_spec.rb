require 'rails_helper'

class OutputMock

  def puts (text)
    text
  end
end

RSpec.describe Deepblue::LogExporter do
  let(:setup_output) { OutputMock.new }
  subject { described_class.new( filter: nil, input: "input", output: setup_output) }

  describe 'constants' do
    it do
      expect( Deepblue::LogExporter::DEFAULT_PP_EXPORT ).to eq false
    end
  end

  describe "#initialize" do
    it "calls super" do
      skip "Add a test"
    end

    context "when verbose is false" do
      it "sets instance variables" do
        subject.instance_variable_get(:@output) == setup_output
        subject.instance_variable_get(:@pp_export) == false
      end
    end

    context "when verbose is true" do
      it "sets instance variables, calls puts method" do
        skip "Add a test"
      end
    end
  end

  describe "#export_line" do
    context "when pp_export is equivalent to true" do
      before {
        allow(subject).to receive(:pp_export).and_return true
      }
      it "calls pretty_print_line" do
        expect(subject).to receive(:pretty_print_line).with "line", "timestamp", "event", "event_note", "class_name", "id", "raw"
        subject.export_line "line", "timestamp", "event", "event_note", "class_name", "id", "raw"
      end
    end

    context "when pp_export is equivalent to false" do
      before {
        allow(subject).to receive(:pp_export).and_return false
      }
      it "calls @output.puts" do
        expect(subject.export_line"line", "timestamp", "event", "event_note", "class_name", "id", "raw")
          .to eq "line"
      end
    end
  end

  describe "#pretty_print_line" do
    before {
      allow(subject.output).to receive(:puts).with("timestamp event/event_note/class_name/id")
      allow(subject.output).to receive(:puts).with("{\n  \"foo\": \"bar\",\n  \"ping\": \"pong\"\n}")
    }

    it "calls @output.puts twice" do
      expect(subject.output).to receive(:puts).with("timestamp event/event_note/class_name/id")
      expect(subject.pretty_print_line "line", "timestamp", "event", "event_note", "class_name", "id", '{"foo":"bar", "ping":"pong"}')
    end
  end

  describe "#output_mode" do
    context "when @output_mode has no value" do
      before {
        allow(subject).to receive(:option).with(key: 'output_mode', default_value: 'w').and_return "output_mode=w"
      }
      it "sets and returns output mode" do
        expect(subject).to receive(:option).with(key: 'output_mode', default_value: 'w')
        expect(subject.output_mode).to eq "output_mode=w"
        subject.instance_variable_get(:@output_mode) == "output_mode=w"
      end
    end

    context "when @output_mode has a value" do
      before {
        subject.instance_variable_set(:@output_mode, "high value")
        allow(subject).to receive(:option).with(key: 'output_mode', default_value: 'w').and_return "output_mode=w"
      }
      it "sets and returns output mode" do
        expect(subject).not_to receive(:option).with(key: 'output_mode', default_value: 'w')
        expect(subject.output_mode).to eq "high value"
        subject.instance_variable_get(:@output_mode) == "high value"
      end
    end
  end

  describe "#run" do
    before {
      allow(subject).to receive(:log_open_output)
      allow(subject).to receive(:readlines).and_return( "line",
                                                        "timestamp",
                                                        "event",
                                                        "event_note",
                                                        "class_name",
                                                        "id",
                                                        "raw_key_values" )
      allow(subject).to receive(:log_close_output)
    }

    it "calls log_open_output, readlines, and log_close_output" do
      expect(subject).to receive(:log_open_output)
      expect(subject).to receive(:readlines)
      expect(subject).to receive(:log_close_output)

      subject.run

      subject.instance_variable_get(:@lines_exported) == 1
    end

    it "calls export_line" do
      skip "Add a test"
    end
  end

  describe "#quick_report" do
    before {
      # stubbing for super
      subject.instance_variable_set(:@input_pathname, "strawberries")
      subject.instance_variable_set(:@lines_read, "watermelon")
      subject.instance_variable_set(:@lines_parsed, "yuzu")

      subject.instance_variable_set(:@output_pathname, "bananas")
      subject.instance_variable_set(:@lines_exported, "oranges")
    }

    it "calls super, outputs text" do
      # super expectations
      expect(subject).to receive(:puts).with no_args
      expect(subject).to receive(:puts).with "Quick report"
      expect(subject).to receive(:puts).with "input_pathname: strawberries"
      expect(subject).to receive(:puts).with "lines_read: watermelon"
      expect(subject).to receive(:puts).with "lines_parsed: yuzu"

      expect(subject).to receive(:puts).with "output_pathname: bananas"
      expect(subject).to receive(:puts).with "lines_exported: oranges"

      subject.quick_report
    end
  end

end
