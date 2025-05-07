require 'rails_helper'


RSpec.describe Dataset::DateCoverageService do

  describe '#params_to_interval' do

    context "when called with year, month, and day for begin_date and end_date" do
      it "returns interval with day precision" do

        params = { :date_coverage_begin_year => "2001", :date_coverage_begin_month => "1", :date_coverage_begin_day => "5",
                   :date_coverage_end_year => "2001", :date_coverage_end_month => "1", :date_coverage_end_day => "10" }

        expect(Dataset::DateCoverageService.params_to_interval params).to eq Date.edtf('2001-01-05/2001-01-10')
      end
    end

    context "when called with year and month for begin_date and end_date" do
      it "returns interval with month precision" do

        params = { :date_coverage_begin_year => "2001", :date_coverage_begin_month => "1", :date_coverage_begin_day => "",
                   :date_coverage_end_year => "2001", :date_coverage_end_month => "2", :date_coverage_end_day => "" }

        expect(Dataset::DateCoverageService.params_to_interval params).to eq Date.edtf('2001-01/2001-02')
      end
    end

    context "when called with year begin_date and end_date" do
      it "returns interval with year precision" do

        params = { :date_coverage_begin_year => "2002", :date_coverage_begin_month => "", :date_coverage_begin_day => "",
                   :date_coverage_end_year => "2003", :date_coverage_end_month => "", :date_coverage_end_day => "" }

        expect(Dataset::DateCoverageService.params_to_interval params).to eq Date.edtf('2002/2003')
      end
    end

    context "when called with begin_date but no end_date" do
      it "returns Start Date" do

        params = { :date_coverage_begin_year => "2007", :date_coverage_begin_month => "5", :date_coverage_begin_day => "6",
                   :date_coverage_end_year => "", :date_coverage_end_month => "", :date_coverage_end_day => "" }

        expect(Dataset::DateCoverageService.params_to_interval params).to eq Date.edtf('2007-05-06')
      end
    end

    context "when called with end_date but no begin_date" do
      it "returns unknown to End Date" do

        params = { :date_coverage_begin_year => "", :date_coverage_begin_month => "", :date_coverage_begin_day => "",
                   :date_coverage_end_year => "2010", :date_coverage_end_month => "10", :date_coverage_end_day => "10" }

        expect(Dataset::DateCoverageService.params_to_interval params).to eq Date.edtf('unknown/2010-10-10')
      end
    end

    context "when called with no date values" do
      it "returns blank " do
        params = { :date_coverage_begin_year => "", :date_coverage_begin_month => "", :date_coverage_begin_day => "",
                   :date_coverage_end_year => "", :date_coverage_end_month => "", :date_coverage_end_day => "" }

        expect(Dataset::DateCoverageService.params_to_interval(params)).to be_blank
      end
    end

    context "when called with reversed date values" do
      it "returns blank" do
        params = { :date_coverage_begin_year => "2001", :date_coverage_begin_month => "1", :date_coverage_begin_day => "6",
                   :date_coverage_end_year => "2001", :date_coverage_end_month => "1", :date_coverage_end_day => "5" }

        expect(Dataset::DateCoverageService.params_to_interval(params)).to be_blank
      end
    end
  end


  describe '#interval_to_params' do

    context "when called with an interval" do
      it "returns date params of interval" do

        params = { :date_coverage_begin_year => "2002", :date_coverage_begin_month => "2", :date_coverage_begin_day => "6",
                   :date_coverage_end_year => "2004", :date_coverage_end_month => "8", :date_coverage_end_day => "16" }

        expect(Dataset::DateCoverageService.interval_to_params Date.edtf('2002-02-06/2004-08-16')).to eq params
      end
    end

    context "when called with argument that is not an interval" do
      it "returns blank when not called with interval" do

        expect(Dataset::DateCoverageService.interval_to_params Date.new(2001,2,25) ).to be_blank
      end
    end

    context "when called with interval in reverse chronological order" do
      it "returns blank" do

        expect(Dataset::DateCoverageService.interval_to_params Date.edtf('2004-08-16/2002-02-06') ).to be_blank
      end
    end


  end

end
