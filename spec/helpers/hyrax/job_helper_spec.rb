class JobHelperMock
  include ::JobHelper
end


RSpec.describe JobHelper, type: :helper do
  subject { JobHelperMock.new }

  describe '#job_options_value' do
    context "when there are no options" do
      it "return default_value" do
        expect(subject.job_options_value "", key: "key", default_value: "crystalline").to eq "crystalline"
      end
    end

    context "when options does not have key" do
      it "return default_value" do
        expect(subject.job_options_value Hash["jump", "shout"], key: "twist", default_value: "symphony").to eq "symphony"
      end
    end

    context "when options has key and verbose is false" do
      it "returns value of options key" do
        expect(subject.job_options_value Hash["twist", "shout"], key: "twist", default_value: "exponential", verbose: false).to eq "shout"
      end
    end

    context "when options has key and verbose is true" do
      before {
        allow(Deepblue::LoggingHelper).to receive(:debug)
      }
      it "calls LoggingHelper.debug" do
        expect(Deepblue::LoggingHelper).to receive(:debug).with "set key jump to jive"
        expect(subject.job_options_value Hash["jump", "jive"], key: "jump", default_value: "blacklisted", verbose: true).to eq "jive"
      end
    end
  end

end
