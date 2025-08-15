require 'rails_helper'

class OutputMock

  def puts (text)
    text
  end

  def flush
  end

  def close
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
      mockoutput = OutputMock.new
      before {
        allow(subject).to receive(:pp_export).and_return false
        subject.instance_variable_set(:@output, mockoutput)
      }
      it "calls @output.puts" do
        expect(mockoutput).to receive(:puts).with "line"
        subject.export_line "line", "timestamp", "event", "event_note", "class_name", "id", "raw"
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


  # protected methods

  describe "#log_close_output" do
    context "when @output_close is false" do
      it "returns nil" do
        expect(subject.send(:log_close_output)).to be_blank
      end
    end

    context "when @output_close is true" do
      out_put = OutputMock.new
      before {
        subject.instance_variable_set(:@output_close, true)
      }

      context "when @output is nil" do
        before {
          subject.instance_variable_set(:@output, nil)
        }
        it "nothing happens" do
          expect(out_put).not_to receive(:flush)
          expect(out_put).not_to receive(:close)
          subject.send(:log_close_output)
        end
      end
      context "when @output is not nil" do
        before {
          subject.instance_variable_set(:@output, out_put)
        }
        it "calls flush and close on @output" do
          expect(out_put).to receive(:flush)
          expect(out_put).to receive(:close)
          subject.send(:log_close_output)
        end
      end
    end
  end


  describe "#log_open_output" do
    before {
      allow(subject).to receive(:output_mode).and_return "output mode"
    }

    context "when @output is a string" do
      before {
        subject.instance_variable_set(:@output, "things")
        allow(Pathname).to receive(:new).with("things").and_return "string output pathname"
        allow(subject).to receive(:open).with("string output pathname", "output mode").and_return "string output"
      }
      it "creates Pathname from string" do
        subject.send(:log_open_output)

        expect(subject.instance_variable_get(:@output_pathname)).to eq "string output pathname"
        expect(subject.instance_variable_get(:@output)).to eq "string output"
      end
    end

    context "when @output is a Pathname" do
      path_name = Pathname.new("path name")
      before {
        subject.instance_variable_set(:@output, path_name)
        allow(subject).to receive(:open).with(path_name, "output mode").and_return "pathname output"
      }
      it "uses Pathname" do
        subject.send(:log_open_output)

        expect(subject.instance_variable_get(:@output_pathname)).to eq path_name
        expect(subject.instance_variable_get(:@output)).to eq "pathname output"
      end
    end

    after {
      expect(subject.instance_variable_get(:@output_close)).to eq true
    }
  end

end
