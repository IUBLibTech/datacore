require 'rails_helper'

class Mockline

  def initialize(eof, line)
    @eof = eof
    @line = line
  end

  def readline
    @line
  end

  def eof?
    @eof
  end
end




describe Deepblue::ProvenanceLogService do

  pending "#self.provenance_log_name"

  pending "#self.provenance_log_path"

  describe "#self.entries" do
    before {
      allow(Deepblue::ProvenancePath).to receive(:path_for_reference).with("Q-3000").and_return "Q-3000.txt"
      allow(Deepblue::ProvenanceLogService).to receive(:read_entries).with("Q-3000.txt").and_return ["read entries"]
      allow(Deepblue::ProvenanceLogService).to receive(:filter_entries).with("Q-3000").and_return ["filter", "entries"]
      allow(Deepblue::ProvenanceLogService).to receive(:write_entries).with("Q-3000.txt", ["filter", "entries"])
    }

    context "when refresh is false and File exists" do
      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with "ProvenanceLogService.entries( Q-3000, false )"
        allow(File).to receive(:exist?).with("Q-3000.txt").and_return true
      }
      it "calls read_entries" do
        expect(File).to receive(:exist?).with("Q-3000.txt").and_return true
        expect(Deepblue::ProvenanceLogService).to receive(:read_entries).with("Q-3000.txt").and_return ["read entries"]
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with "ProvenanceLogService.entries( Q-3000 ) read 1 entries"

        expect(Deepblue::ProvenanceLogService.entries("Q-3000", refresh: false)).to eq ["read entries"]
      end
    end

    context "when refresh is true" do
      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with "ProvenanceLogService.entries( Q-3000, true )"
      }

      it "calls filter_entries and write_entries (doesn't check if File exists)" do
        expect(Deepblue::ProvenanceLogService).to receive(:filter_entries).with("Q-3000").and_return ["filter", "entries"]
        expect(Deepblue::ProvenanceLogService).to receive(:write_entries).with("Q-3000.txt", ["filter", "entries"])
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with "ProvenanceLogService.entries( Q-3000 ) read 2 entries"

        expect(Deepblue::ProvenanceLogService.entries("Q-3000", refresh: true)).to eq ["filter", "entries"]
      end
    end

    context "when refresh is false and File does not exist" do
      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with "ProvenanceLogService.entries( Q-3000, false )"
        allow(File).to receive(:exist?).with("Q-3000.txt").and_return false
      }

      it "calls filter_entries and write_entries" do
        expect(File).to receive(:exist?).with("Q-3000.txt").and_return false
        expect(Deepblue::ProvenanceLogService).to receive(:filter_entries).with("Q-3000").and_return ["filter", "entries"]
        expect(Deepblue::ProvenanceLogService).to receive(:write_entries).with("Q-3000.txt", ["filter", "entries"])
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with "ProvenanceLogService.entries( Q-3000 ) read 2 entries"

        expect(Deepblue::ProvenanceLogService.entries("Q-3000", refresh: false)).to eq ["filter", "entries"]
      end
    end
  end


  pending "#self.filter_entries"


  describe "#self.parse_entry" do
    context "function returns successfully" do
      it "calls Deepblue::ProvenanceHelper.parse_log_line" do
        skip "Add a test"
      end
    end

    context "when Deepblue::ProvenanceHelper.parse_log_line throws an error" do
      before {
        allow(Deepblue::ProvenanceHelper).to receive(:parse_log_line).with("data entry", line_number: 0, raw_key_values: true)
          .and_raise(Deepblue::LogParseError)

      }
      it "returns parameters and error message" do
        expect(Deepblue::ProvenanceHelper).to receive(:parse_log_line).with("data entry", line_number: 0, raw_key_values: true)

        return_value = Deepblue::ProvenanceLogService.parse_entry("data entry")
        expect(return_value[:entry]).to eq "data entry"
        expect(return_value[:line_number]).to eq 0
        expect(return_value[:parse_error]).to be_an_instance_of Deepblue::LogParseError
      end
    end
  end


  describe "#self.pp_key_values" do
    before {
      allow(JSON).to receive(:parse).with("raw").and_return "JSON parse"
      allow(JSON).to receive(:pretty_generate).with("JSON parse").and_return "JSON pretty generate"
    }
    it "calls JSON.parse and JSON.pretty_generate on parameter" do
      expect(Deepblue::ProvenanceLogService.pp_key_values "raw").to eq "JSON pretty generate"
    end
  end


  describe "#self.key_values_to_table" do
    context "when parse parameter is true" do
      before {
        allow(JSON).to receive(:parse).with("values").and_return "parsed key values"
      }
      it "" do
        expect(JSON).to receive(:parse).with("values")
        expect(Deepblue::ProvenanceLogService.key_values_to_table "values", parse: true).to eq "parsed key values"
      end
    end

    context "when parse parameter is false" do

      context "when key_values parameter is an array of 0 values" do
        it "returns empty html table code" do
          expect(JSON).not_to receive(:parse)
          expect(Deepblue::ProvenanceLogService.key_values_to_table [], parse: false).to eq "<table>\n<tr><td>&nbsp;</td></tr>\n</table>\n"
        end
      end

      context "when key_values parameter is an array of 1 value" do
        before {
          allow(ERB::Util).to receive(:html_escape).with("key value").and_return "escaped key value"
        }
        it "returns html table of escaped key_value" do
          expect(JSON).not_to receive(:parse)

          expect(Deepblue::ProvenanceLogService.key_values_to_table ["key value"], parse: false)
            .to eq "<table>\n<tr><td>escaped key value</td></tr>\n</table>\n"
        end
      end

      context "when key_values parameter is an array of more than 1 value" do
        before {
          allow(ERB::Util).to receive(:html_escape).with("omega").and_return "escaped key value 1"
          allow(ERB::Util).to receive(:html_escape).with("zeta").and_return "escaped key value 2"
        }
        it "returns html table of escaped array values" do
          expect(JSON).not_to receive(:parse)

          expect(Deepblue::ProvenanceLogService.key_values_to_table ["omega", "zeta"], parse: false)
            .to eq "<table>\n<tr><td>escaped key value 1</td></tr>\n<tr><td>escaped key value 2</td></tr>\n</table>\n"
        end
      end

      context "when key_values parameter is a hash" do
        before {
          allow(ERB::Util).to receive(:html_escape).with("alpha").and_return "escaped key 1"
          allow(ERB::Util).to receive(:html_escape).with("beta").and_return "escaped value 1"
        }
        it "returns html table of escaped hash values" do
          expect(JSON).not_to receive(:parse)

          expect(Deepblue::ProvenanceLogService.key_values_to_table( {"alpha" => "beta"}, parse: false))
            .to eq "<table>\n<tr><td>escaped key 1</td><td>escaped value 1</td></tr>\n</table>\n"
        end
      end

      context "when key_values parameter is not an array or a hash (could be a string)" do
        before {
          allow(ERB::Util).to receive(:html_escape).with("violin").and_return "string instrument"
        }
        it "returns escaped key_value(s)" do
          expect(JSON).not_to receive(:parse)

          expect(Deepblue::ProvenanceLogService.key_values_to_table "violin", parse: false)
            .to eq "string instrument"
        end
      end
    end
  end


  pending "#self.read_entries"

  pending "#self.write_entries"

end

