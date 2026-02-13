require 'rails_helper'

RSpec.describe Hyrax::RenderPresentValueService do

  subject { described_class.new("type_none") }


  describe "#initialize" do
    it "calls super" do
      skip "Add a test"
    end
  end


  describe "#include_current_value" do
    context "when value is NOT present" do
      it "returns the render_options and html_options parameters unchanged in an array" do
        expect(subject.include_current_value(nil, "index", "render", "html")).to eq ["render", "html"]
      end
    end

    context "when value is present" do
      before {
        allow(subject).to receive(:label).with("saffron").and_return "*saffron*"
      }
      it "adds to the render_options and html_options parameters and returns them in an array" do
        expect(subject.include_current_value("saffron", "index", [["*pomegranate*", "pomegranate"]], {:class => "bat-select"}))
          .to eq [[["*pomegranate*", "pomegranate"], ["*saffron*", "saffron"]], {:class => "bat-select force-select"}]
      end
    end
  end
  
  
end
