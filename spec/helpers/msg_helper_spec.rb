RSpec.describe MsgHelper, type: :helper do

  describe "constants" do
    it do
      expect(MsgHelper::FIELD_SEP).to eq "; "
    end
  end

  describe "#self.creator" do
    it "returns creator(s) as a string" do
      expect(MsgHelper.creator OpenStruct.new(creator: ["Abigail Adams", "Ben Beardsley"])).to eq "Abigail Adams; Ben Beardsley"
    end
  end

  describe "#self.description" do
    it "returns description(s) as a string" do
      expect(MsgHelper.description OpenStruct.new(description: ["stream-of-consciousness", "methodical", "technical"]),
                                   field_sep: ' ~ ').to eq "stream-of-consciousness ~ methodical ~ technical"
    end
  end

  describe "#self.globus_link" do
    before {
      allow(GlobusJob).to receive(:external_url).with("4567").and_return "globus url link"
    }
    it "returns description(s) as a string" do
      expect(GlobusJob).to receive(:external_url).with("4567")
      expect(MsgHelper.globus_link OpenStruct.new(id: "4567")).to eq "globus url link"
    end
  end

  describe "#self.publisher" do
    it "returns publisher(s) as a string" do
      expect(MsgHelper.publisher OpenStruct.new(publisher: ["Bjork", "Martin, Max", "Ga Ga, Lady"])).to eq "Bjork; Martin, Max; Ga Ga, Lady"
    end
  end

  describe "#self.subject_discipline" do
    it "returns subject_discipline(s) as a string" do
      expect(MsgHelper.subject_discipline OpenStruct.new(subject_discipline: ["arts", "crafts", "sciences"]), field_sep: '... ').to eq "arts... crafts... sciences"
    end
  end

  describe "#self.title" do
    it "returns title(s) as a string" do
      expect(MsgHelper.title OpenStruct.new(title: ["The Alpha", "The Omega"])).to eq "The Alpha; The Omega"
    end
  end

  describe "#self.work_location" do
    it "returns class name and id as string" do
      expect(MsgHelper.work_location curation_concern: OpenStruct.new(id: 123, class: OpenStruct.new(name: "The Jurassic"))).to eq "work location for: The Jurassic 123"
    end
  end
end
