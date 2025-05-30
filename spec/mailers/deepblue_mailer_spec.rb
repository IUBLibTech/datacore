require 'rails_helper'

RSpec.describe DeepblueMailer do

  describe '#send_an_email' do
    before {
      allow(subject).to receive(:mail).with(to: "to", from: "from", subject: "subject", body: "body")
    }

    it "calls email function" do
      expect(subject).to receive(:mail).with(to: "to", from: "from", subject: "subject", body: "body")

      subject.send_an_email to: "to", from: "from", subject: "subject", body: "body"
    end
  end

end
