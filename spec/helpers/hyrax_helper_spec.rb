class HyraxHelperMock
  include ::HyraxHelper

  def link_to (label, info)
    "Link: #{label} #{info}"
  end

  def to_sentence (array)
    array.join(", ")
  end
end

class ServiceMock

  def label (info)
    "Here: #{info}"
  end
end



RSpec.describe HyraxHelper, type: :helper do
  subject { HyraxHelperMock.new }

  describe "#available_translations" do
    it "returns hash of available translations" do
      expect(subject.available_translations).to eq 'en' => 'English'
    end
  end


  describe "#human_readable_file_size" do
    before {
      allow(ActiveSupport::NumberHelper::NumberToHumanSizeConverter).to receive(:convert).with("optional", precision: 3).and_return "human readable size"
    }
    it "calls NumberToHumanSizeConverter.convert with parameters" do
      expect(subject.human_readable_file_size( :value => ["optional", "required"] )).to eq "human readable size"
    end
  end


  describe "#self.nbsp_or_value" do

    checking = [{"attempt" => nil, "result" => "&nbsp;"}, {"attempt" => "", "result" => "&nbsp;"}, {"attempt" => "thing", "result" => "thing"}]
    checking.each do |check|

      context "when value is #{check["attempt"]}" do
        it "returns #{check["result"]}" do
          expect(HyraxHelper.nbsp_or_value check["attempt"]).to eq check["result"]
        end
      end
    end
  end


  describe "#render_visibility_link" do
    before {
      allow(subject).to receive(:visibility_badge).with("public").and_return "badge"
    }
    it "calls visibility_badge" do
      expect(subject.render_visibility_link OpenStruct.new(visibility: "public")).to eq "badge"
    end
  end


  describe "#rights_license_links" do
    before {
      allow(Hyrax::RightsLicenseService).to receive(:new).and_return ServiceMock.new
    }
    it "calls RightsLicenseService.new" do
      expect(Hyrax::RightsLicenseService).to receive(:new)
      expect(subject.rights_license_links OpenStruct.new(value: ["uno", "due", "tre", "quattro"])).to eq "Link: Here: uno uno, Link: Here: due due, Link: Here: tre tre, Link: Here: quattro quattro"
    end
  end

  
  describe "#t_uri" do
    context "when no scope provided" do
      it "calls I18n.t with empty array" do
        expect(I18n).to receive(:t).with("key", scope: [])
        subject.t_uri "key"
      end
    end

    context "when called with scope parameter of an array of strings" do
      it "calls I18n.t with array of strings with '.' replaced with '_'" do
        expect(I18n).to receive(:t).with("key", scope: ["gold_blue", "silver_green"])
        subject.t_uri "key", scope: ["gold.blue", "silver.green"]
      end
    end

    context "when called with scope parameter of an array of other objects (not strings)" do
      it "calls I18n.t with array of other objects (not strings)" do
        expect(I18n).to receive(:t).with("key", scope: [123, 1.23])
        subject.t_uri "key", scope: [123, 1.23]
      end
    end
  end


end
