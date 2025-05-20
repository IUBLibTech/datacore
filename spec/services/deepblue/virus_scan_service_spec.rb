require 'rails_helper'

class VirusScanServiceMock
  include ::Deepblue::VirusScanService
end

RSpec.describe Deepblue::VirusScanService do
  subject { VirusScanServiceMock.new }

  describe 'constants' do
    it do
      expect( Deepblue::VirusScanService::VIRUS_SCAN_ERROR ).to eq 'scan error'
      expect( Deepblue::VirusScanService::VIRUS_SCAN_NOT_VIRUS ).to eq 'not virus'
      expect( Deepblue::VirusScanService::VIRUS_SCAN_SKIPPED ).to eq 'scan skipped'
      expect( Deepblue::VirusScanService::VIRUS_SCAN_SKIPPED_SERVICE_UNAVAILABLE ).to eq 'scan skipped service unavailable'
      expect( Deepblue::VirusScanService::VIRUS_SCAN_SKIPPED_TOO_BIG ).to eq 'scan skipped too big'
      expect( Deepblue::VirusScanService::VIRUS_SCAN_UNKNOWN ).to eq 'scan unknown'
      expect( Deepblue::VirusScanService::VIRUS_SCAN_VIRUS ).to eq 'virus'
    end
  end

  describe "#virus_scan_detected_virus?" do
    context "when argument equals VIRUS_SCAN_VIRUS constant" do
      it "returns true" do
        expect(subject.virus_scan_detected_virus? scan_result: "virus").to eq true
      end
    end

    context "when argument does not equal VIRUS_SCAN_VIRUS constant" do
      it "returns false" do
        expect(subject.virus_scan_detected_virus? scan_result: "scanned virus").to eq false
      end
    end
  end

  describe "#virus_scan_service_name" do
    it do
      expect(subject.virus_scan_service_name).to eq Hydra::Works.default_system_virus_scanner.name
    end
  end

  describe "#virus_scan_skipped?" do
    context "if scan_result blank" do
      it "returns false" do
        expect(subject.virus_scan_skipped? scan_result: "").to eq false
      end
    end

    context "if scan_result does not start with 'scan skipped'" do
      it "returns false" do
        expect(subject.virus_scan_skipped? scan_result: "scanning the surrounding parsecs").to eq false
      end
    end

    context "if scan_result does start with 'scan skipped'" do
      it "returns true" do
        expect(subject.virus_scan_skipped? scan_result: "scan skipped, yippee ki yi yay").to eq true
      end
    end
  end

  describe "#virus_scan_timestamp_now" do
    before {
      allow(Time).to receive(:now).and_return(DateTime.new(2025, 2, 3, 4, 5, 6))
    }
    it do
      expect(subject.virus_scan_timestamp_now).to eq "2025-02-03 04:05:06"
    end
  end

end
