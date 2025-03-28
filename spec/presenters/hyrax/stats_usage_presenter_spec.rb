require 'rails_helper'

RSpec.describe Hyrax::StatsUsagePresenter do

  describe "#created" do

    it 'returns date_for_analytics' do
      analytical_date = DateTime.new(2001,12,31)
      allow(subject).to receive(:date_for_analytics).and_return(analytical_date)

      expect(subject.created).to be analytical_date
    end
  end

end