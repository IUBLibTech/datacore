require 'rails_helper'


RSpec.describe Deepblue::UploadLogger do

  describe "#format_message" do
    subject { described_class.new(STDOUT) }

    it "returns message parameter as string with a newline appended" do
      expect(subject.format_message(nil, nil, nil, "the message")).to eq "the message\n"
    end
  end


  describe "constants" do
    it do
      expect(Deepblue::UPLOAD_LOGGER.class).to eq Deepblue::UploadLogger
    end
  end

  skip "Add a test for code in module outside of class"
end
