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

  pending "#statistics"
  pending "#ga_statistics"

end
