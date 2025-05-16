require 'rails_helper'

class StatisticsMock < Hyrax::Statistic

end

RSpec.describe Hyrax::Statistic do

  pending "#statistics_for"

  pending "#build_for"

  describe '#convert_date' do
    context 'convert DateTime to integer times one thousand' do
      let(:fooMyClass) do
        Class.new(Hyrax::Statistic) {}
      end

      it 'returns integer' do
        expect(fooMyClass.convert_date(DateTime.new(2001,2,3))).to eq 981158400000
      end
    end
  end

  describe "#statistics" do
    context 'convert DateTime to integer times one thousand' do
      let(:fooMyClass) do
        Class.new(Hyrax::Statistic) {}
      end

      before {
        allow(fooMyClass).to receive(:cache_column).and_return "cache column"
        allow(fooMyClass).to receive(:event_type).and_return "event type"
        allow(fooMyClass).to receive(:statistics).with("object", "start date", "user id")
      }

      it 'returns integer' do
        fooMyClass.statistics("object", "start date", "user id")
      end
    end
  end

  pending "#ga_statistics"

end
