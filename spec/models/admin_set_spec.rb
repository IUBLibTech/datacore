require 'rails_helper'

RSpec.describe AdminSet do

  describe '#to_s' do
        it 'when title present returns title' do
          subject.title = ["Excellent Title"]
          expect(subject.to_s).to eq ['Excellent Title']
        end

        it 'when title not present returns No Title' do
          subject.title = nil
          expect(subject.to_s).to eq 'No Title'
        end
  end
end