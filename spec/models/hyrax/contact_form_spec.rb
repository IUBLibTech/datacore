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

  describe "#self.issue_types_for_locale" do
    before {
      allow(I18n).to receive(:t).with('hyrax.contact_form.issue_types.depositing').and_return "depositing"
      allow(I18n).to receive(:t).with('hyrax.contact_form.issue_types.changing').and_return "changing"
      allow(I18n).to receive(:t).with('hyrax.contact_form.issue_types.browsing').and_return "browsing"
      allow(I18n).to receive(:t).with('hyrax.contact_form.issue_types.reporting').and_return "reporting"
      allow(I18n).to receive(:t).with('hyrax.contact_form.issue_types.general').and_return "general"
      allow(I18n).to receive(:t).with('hyrax.contact_form.issue_types.size').and_return "size"
    }
    it "returns array" do
      expect(Hyrax::ContactForm.issue_types_for_locale).to eq ["depositing", "changing", "browsing", "reporting", "general", "size"]
    end
  end

end
