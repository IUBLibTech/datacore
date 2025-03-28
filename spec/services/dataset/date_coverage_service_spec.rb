require 'rails_helper'


RSpec.describe Dataset::DateCoverageService do

  describe '#params_to_interval' do

    it "returns interval with day precision" do

      params = { :date_coverage_begin_year => "2001", :date_coverage_begin_month => "1", :date_coverage_begin_day => "5",
                 :date_coverage_end_year => "2001", :date_coverage_end_month => "1", :date_coverage_end_day => "10" }

      expect(Dataset::DateCoverageService.params_to_interval params).to eq Date.edtf('2001-01-05/2001-01-10')
    end

    it "returns interval with month precision" do

      params = { :date_coverage_begin_year => "2001", :date_coverage_begin_month => "1", :date_coverage_begin_day => "",
                 :date_coverage_end_year => "2001", :date_coverage_end_month => "2", :date_coverage_end_day => "" }

      expect(Dataset::DateCoverageService.params_to_interval params).to eq Date.edtf('2001-01/2001-02')
    end

    it "returns interval with year precision" do

      params = { :date_coverage_begin_year => "2002", :date_coverage_begin_month => "", :date_coverage_begin_day => "",
                 :date_coverage_end_year => "2003", :date_coverage_end_month => "", :date_coverage_end_day => "" }

      expect(Dataset::DateCoverageService.params_to_interval params).to eq Date.edtf('2002/2003')
    end


    it "returns Start Date when no End Date" do

      params = { :date_coverage_begin_year => "2007", :date_coverage_begin_month => "5", :date_coverage_begin_day => "6",
                 :date_coverage_end_year => "", :date_coverage_end_month => "", :date_coverage_end_day => "" }

      expect(Dataset::DateCoverageService.params_to_interval params).to eq Date.edtf('2007-05-06')
    end

    it "returns unknown to End Date when no Start Date" do

      params = { :date_coverage_begin_year => "", :date_coverage_begin_month => "", :date_coverage_begin_day => "",
                 :date_coverage_end_year => "2010", :date_coverage_end_month => "10", :date_coverage_end_day => "10" }

      expect(Dataset::DateCoverageService.params_to_interval params).to eq Date.edtf('unknown/2010-10-10')
    end


    it "returns nil when no date values" do
      params = { :date_coverage_begin_year => "", :date_coverage_begin_month => "", :date_coverage_begin_day => "",
                 :date_coverage_end_year => "", :date_coverage_end_month => "", :date_coverage_end_day => "" }

      expect(Dataset::DateCoverageService.params_to_interval(params)).to eq nil
    end

    it "returns nil when reversed date values" do
      params = { :date_coverage_begin_year => "2001", :date_coverage_begin_month => "1", :date_coverage_begin_day => "6",
                 :date_coverage_end_year => "2001", :date_coverage_end_month => "1", :date_coverage_end_day => "5" }

      expect(Dataset::DateCoverageService.params_to_interval(params)).to eq nil
    end
  end

  describe '#interval_to_params' do

    it "returns date params" do

      params = { :date_coverage_begin_year => "2002", :date_coverage_begin_month => "2", :date_coverage_begin_day => "6",
                 :date_coverage_end_year => "2004", :date_coverage_end_month => "8", :date_coverage_end_day => "16" }

      expect(Dataset::DateCoverageService.interval_to_params Date.edtf('2002-02-06/2004-08-16')).to eq params
    end

    it "returns nil when not called with interval" do

      expect(Dataset::DateCoverageService.interval_to_params Date.new(2001,2,25) ).to eq nil
    end

    it "returns nil when Start and End Date reversed" do

      expect(Dataset::DateCoverageService.interval_to_params Date.edtf('2004-08-16/2002-02-06') ).to eq nil
    end


  end

end
