require 'rails_helper'

RSpec.describe Hyrax::RenderCurrentValueService do

  subject { described_class.new("type_none") }


  describe "#initialize" do
    it "calls super" do
      skip "Add a test"
    end
  end


  describe "#include_current_value" do
    context "when value is blank" do
      it "returns the render_options and html_options parameters unchanged in an array" do
        expect(subject.include_current_value("", "index", "render", "html")).to eq ["render", "html"]
      end
    end

    context "when value is active" do
      before {
        allow(subject).to receive(:active?).with("cherry").and_return true
      }
      it "returns the render_options and html_options parameters unchanged in an array" do
        expect(subject.include_current_value("cherry", "index", [["*raspberry*", "raspberry"]], {:class => "tab-select"}))
          .to eq [[["*raspberry*", "raspberry"]], {:class => "tab-select"}]
      end
    end

    context "when value is not blank or active" do
      before {
        allow(subject).to receive(:active?).with("orange").and_return false
        allow(subject).to receive(:label).with("orange").and_return "*orange*"
      }
      it "adds to the render_options and html_options parameters and returns them in an array" do
        expect(subject.include_current_value("orange", "index", [["*grape*", "grape"]], {:class => "tab-select"}))
          .to eq [[["*grape*", "grape"], ["*orange*", "orange"]], {:class => "tab-select force-select"}]
      end
    end
  end
  
  
end
