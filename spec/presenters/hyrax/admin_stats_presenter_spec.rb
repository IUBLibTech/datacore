# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::AdminStatsPresenter do
  let(:stats_filters) { { start_date: start_date, end_date: end_date } }
  let(:start_date) { "" }
  let(:end_date) { "" }
  let(:limit) { 10 }
  let(:instance) { described_class.new(stats_filters, limit) }

  describe "#valid_dates" do
    context "without a start date" do
      it "returns true" do
        expect(instance.valid_dates).to be true
      end
    end
    context "with a start date (only)" do
      context "before/on today" do
        let(:start_date) { Date.current.to_s }
        it "returns true" do
          expect(instance.valid_dates).to be true
        end
      end
      context "after today" do
        let(:start_date) { (Date.current + 1).to_s }
        it "returns false" do
          expect(instance.valid_dates).to be false
        end
      end
    end
    context "with an end date" do
      let(:end_date) { "2011-11-11" }
      context "without a start date" do
        it "returns true" do
          expect(instance.valid_dates).to be true
        end
      end
      context "after the start date" do
        let(:start_date) { "2010-10-10" }
        it "returns true" do
          expect(instance.valid_dates).to be true
        end
      end
      context "preceding the start date" do
        let(:start_date) { "2012-12-12" }
        it "returns false" do
          expect(instance.valid_dates).to be false
        end
      end
    end
  end

  describe "#clear_invalid_dates!" do
    context "with valid dates" do
      let(:start_date) { "2010-10-10" }
      let(:end_date) { "2011-11-11" }
      it "does not clear filters" do
        expect(stats_filters[:start_date]).to be_present
        expect(stats_filters[:end_date]).to be_present
        instance.clear_invalid_dates!
        expect(stats_filters[:start_date]).to be_present
        expect(stats_filters[:end_date]).to be_present
      end
    end
    context "with invalid dates" do
      let(:start_date) { "2012-12-12" }
      let(:end_date) { "2011-11-11" }
      it "clears the date values" do
        expect(stats_filters[:start_date]).to be_present
        expect(stats_filters[:end_date]).to be_present
        instance.clear_invalid_dates!
        expect(stats_filters[:start_date]).to be_nil
        expect(stats_filters[:end_date]).to be_nil
      end
    end
  end
end
