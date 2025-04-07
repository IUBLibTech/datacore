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


  pending "#headers"

  pending "#self.issue_types_for_locale"

end
