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

class DocumentMock

  def visibility
    "visible"
  end
end

RSpec.describe HyraxHelper, type: :helper do
  subject { HyraxHelperMock.new }

  describe '#available_translations' do
    it "returns hash of available translations" do
      expect(subject.available_translations).to eq 'en' => 'English'
    end
  end

  describe '#human_readable_file_size' do
    before {
      allow(ActiveSupport::NumberHelper::NumberToHumanSizeConverter).to receive(:convert).with("tropical", precision: 3)
    }
    it "calls NumberToHumanSizeConverter.convert" do
      expect(ActiveSupport::NumberHelper::NumberToHumanSizeConverter).to receive(:convert).with("tropical", precision: 3)
      subject.human_readable_file_size :value => ["tropical", "temperate"]
    end
  end

  describe "#self.nbsp_or_value" do
    skip "Add a test"
  end

  describe "#render_visibility_link" do
    it "calls visibility_badge" do
      expect(subject).to receive(:visibility_badge).with("visible")
      subject.render_visibility_link DocumentMock.new
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

  describe "t_uri" do
    it "calls I18n.t with empty array when no scope provided" do
      expect(I18n).to receive(:t).with("key", scope: [])
      subject.t_uri "key"
    end

    it "calls I18n.t with array of strings" do
      expect(I18n).to receive(:t).with("key", scope: ["gold_blue", "silver_green"])
      subject.t_uri "key", scope: ["gold.blue", "silver.green"]
    end

    it "calls I18n.t with array of other objects (not strings)" do
      expect(I18n).to receive(:t).with("key", scope: [123, 1.23])
      subject.t_uri "key", scope: [123, 1.23]
    end
  end

end
