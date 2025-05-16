require 'rails_helper'

RSpec.describe AdminSet do

  describe 'constants' do
     it do
        expect( AdminSet::DEFAULT_ID).to eq 'admin_set/default'
        expect( AdminSet::DEFAULT_TITLE ).to eq ['Default Admin Set']
     end
  end

  pending "describe constant DEFAULT_WORKFLOW_NAME"

  describe "#default_set?" do
    context "when id equals the default id constant" do
      before {
        allow(subject).to receive(:id).and_return('admin_set/default')
      }
      it "returns true" do
        expect(subject.default_set?).to eq true
      end
    end

    context "when id does not equal the default id constant" do
      before {
        allow(subject).to receive(:id).and_return('another_set')
      }
      it "returns false" do
        expect(subject.default_set?).to eq false
      end
    end
  end

  pending "constant DEFAULT_WORKFLOW_NAME"

  pending "#self.find_or_create_default_admin_set_id"

  describe '#to_s' do
    context "when title present"
      before {
        allow(subject).to receive(:title).and_return(["Excellent Title"])
      }
      it 'returns title' do
        expect(subject.to_s).to eq ['Excellent Title']
      end
    end

    context "when title not present" do
      before {
        allow(subject).to receive(:title).and_return(nil)
      }
      it 'returns No Title' do
        expect(subject.to_s).to eq 'No Title'
      end
    end

  pending "#permission_template"

  pending "#active_workflow"

  pending "#reset_access_controls!"


end
