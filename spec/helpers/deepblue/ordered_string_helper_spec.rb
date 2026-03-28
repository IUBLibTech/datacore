RSpec.describe Deepblue::OrderedStringHelper, type: :helper do

  describe '#self.deserialize' do
    context "when string starts with square bracket ( [ )" do

      context "when string deserializes to an array" do
        it "returns array" do
          expect(Deepblue::OrderedStringHelper.deserialize("[\"mermaid\",\"minotaur\",\"centaur\"]")).to eq ["mermaid", "minotaur", "centaur"]
        end
      end

      context "when string does NOT deserialize to an array" do
        it "raises ActiveSupport::JSON.parse_error" do
          begin
            expect(Deepblue::OrderedStringHelper.deserialize("['spring',\"river\",\"stream\",]")).to raise_error(ActiveSupport::JSON.parse_error)
          rescue Deepblue::OrderedStringHelper::DeserializeError
            # raises error
          end
        end
      end
    end

    context "when string does NOT start with square bracket ( [ ]" do
      it "raises OrderedStringHelper::DeserializeError" do
        begin
          Deepblue::OrderedStringHelper.deserialize('')
        rescue Deepblue::OrderedStringHelper::DeserializeError
          # raises error
        end
      end
    end
  end


  describe "#self.serialize" do
    it "serializes an array into a string" do
      expect(Deepblue::OrderedStringHelper.serialize ["one", "two", "three"]).to eq "[\"one\",\"two\",\"three\"]"
    end

  end


end
