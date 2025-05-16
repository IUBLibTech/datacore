require 'rails_helper'

RSpec.describe Hyrax::ContactForm do

  describe '#spam?' do
    context "when contact_method present" do
      before {
        allow(subject).to receive(:contact_method).and_return "exists"
      }
      it 'returns true' do
        expect( subject.spam? ).to eq true
      end
    end

    context "when contact_method not present" do
      before {
        allow(subject).to receive(:contact_method).and_return nil
      }
      it 'returns false' do
        expect( subject.spam? ).to eq false
      end
    end
  end

  describe "#headers" do
    before {
      allow(Hyrax.config).to receive(:subject_prefix).and_return "prefix"
      allow(subject).to receive(:subject).and_return "subject"
      allow(Hyrax.config).to receive(:contact_email).and_return "contact email"
      allow(subject).to receive(:email).and_return "email"
    }
    it "returns hash" do
      expect(subject.headers[:subject]).to eq "prefix subject"
      expect(subject.headers[:to]).to eq "contact email"
      expect(subject.headers[:from]).to eq "email"
    end
  end

  pending "#self.issue_types_for_locale"

end
