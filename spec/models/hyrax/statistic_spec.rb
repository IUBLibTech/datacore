require 'rails_helper'


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
    context 'calls combined_stats' do
      let(:fooMyClass) do
        Class.new(Hyrax::Statistic) {}
      end

      before {
        allow(fooMyClass).to receive(:cache_column).and_return "cache column"
        allow(fooMyClass).to receive(:event_type).and_return "event type"
        allow(fooMyClass).to receive(:combined_stats).with("object", "start date", "cache column", "event type", "user id").and_return "combined stats"
      }

      it 'returns integer' do
        expect(fooMyClass.statistics("object", "start date", "user id")).to eq "combined stats"
      end
    end
  end

  describe "#ga_statistics" do
    context "when Hyrax::Analytics.profile does not return a value" do
      let(:fooMyClass) do
        Class.new(Hyrax::Statistic) {}
      end

      before {
        allow(fooMyClass).to receive(:polymorphic_path).with( "object" ).and_return "pathfinder"
        allow(Rails.logger).to receive(:info).with( "Statistic.ga_statistics path=pathfinder" )
      }
      it "returns blank" do
        expect(fooMyClass.ga_statistics("start date", "object")).to be_blank
      end
    end

    context "when Hyrax::Analytics.profile returns a value" do
      it "" do
        skip "Add a test"
      end
    end
  end

end
