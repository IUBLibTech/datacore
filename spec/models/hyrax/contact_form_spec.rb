require 'rails_helper'

RSpec.describe Hyrax::ContactForm do

describe '#spam?' do

  it 'returns true when contact_method present' do
    subject.contact_method = "exists"

    expect( subject.spam? ).to eq true
  end

  it 'returns false when contact_method not present' do
    subject.contact_method = nil

    expect( subject.spam? ).to eq false
  end

end
end