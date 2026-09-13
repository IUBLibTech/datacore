require 'rails_helper'


RSpec.describe EmailLogger do

  describe "#format_message" do
    subject { described_class.new(STDOUT) }

    it "returns message parameter as string with a newline appended" do
      expect(subject.format_message(nil, nil, nil, 1001)).to eq "1001\n"
    end
  end


  describe "constants" do
    it do
      expect(EMAIL_LOGGER.class).to eq EmailLogger
    end
  end

  skip "Add a test for code in module outside of class"
end
