require 'rails_helper'
require_relative '../../../lib/tasks/task_logger'

RSpec.describe Deepblue::TaskLogger do

  describe "#format_message" do
    subject { described_class.new(STDOUT) }

    it "returns message parameter as string with a newline appended" do
      expect(subject.format_message(nil, nil, nil, "the message")).to eq "the message\n"
    end
  end

end
