require 'rails_helper'

RSpec.describe Hyrax::StatsUsagePresenter do

  describe "#created" do

    context "date_for_analytics defined" do
      before {
        allow(subject).to receive(:date_for_analytics).and_return( DateTime.new(2001,12,31) )
      }
      it 'returns date_for_analytics' do
        expect(subject.created).to eq DateTime.new(2001,12,31)
      end
    end
  end

end
