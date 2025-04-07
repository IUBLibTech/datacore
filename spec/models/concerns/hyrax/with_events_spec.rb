require 'rails_helper'

class EventfulMock
  include ::Hyrax::WithEvents

end


RSpec.describe Hyrax::WithEvents  do
  subject { EventfulMock.new }

  pending "#stream"

  describe '#event_class' do
    it "returns class name" do
      expect(subject.event_class).to eq("EventfulMock")
    end
  end

  pending "#events"

  pending "#log_event"

end
