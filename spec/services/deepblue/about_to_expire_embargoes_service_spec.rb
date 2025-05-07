require 'rails_helper'

class MockAsset
  def initialize( id:, model_name: )
    @id = id
    @model_name = model_name
  end
  def id
    @id.to_s
  end
  def model_name
    @model_name
  end
  def to_ary
    [self]
  end
end

class MockLeadTime
  def initialize(days:)
    @days = days
  end
  def to_s
    @days.to_s + " days"
  end
  def days
    @days
  end
end

RSpec.describe Deepblue::AboutToExpireEmbargoesService do
  subject { described_class.new }

  describe "#initialize" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "from"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with("class", anything).and_return "object class"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                         "from",
                                                         "object class",
                                                         "email_owner=true",
                                                         "expiration_lead_days=",
                                                         "skip_file_sets=true",
                                                         "test_mode=true",
                                                         "to_console=false",
                                                         "verbose=false",
                                                         ""]
    }

    it "calls LoggingHelper.bold_debug" do
      expect(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      expect(Deepblue::LoggingHelper).to receive(:called_from).and_return "from"
      expect(Deepblue::LoggingHelper).to receive(:obj_class).with("class", anything).and_return "object class"

      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                   "from",
                                                                   "object class",
                                                                   "email_owner=true",
                                                                   "expiration_lead_days=",
                                                                   "skip_file_sets=true",
                                                                   "test_mode=true",
                                                                   "to_console=false",
                                                                   "verbose=false",
                                                                   ""]
      Deepblue::AboutToExpireEmbargoesService.new
    end

    it "sets instance variables" do
      subject.instance_variable_get(:@email_owner) == true
      subject.instance_variable_get(:@expiration_lead_days) == nil
      subject.instance_variable_get(:@skip_file_sets) == true
      subject.instance_variable_get(:@test_mode) == true
      subject.instance_variable_get(:@to_console) == false
      subject.instance_variable_get(:@verbose) == false

    end
  end

  describe "#run" do
    mock_asset = MockAsset.new id:1001, model_name: "model name"

    before {
      # stubbing initialize
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                   "from",
                                                                   "object class",
                                                                   "email_owner=true",
                                                                   "expiration_lead_days=",
                                                                   "skip_file_sets=true",
                                                                   "test_mode=true",
                                                                   "to_console=false",
                                                                   "verbose=false",
                                                                   ""]

      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "from"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with("class", anything).and_return "object class"

      allow(DateTime).to receive(:now).and_return DateTime.new(2025, 5, 5)
      allow(subject).to receive(:assets_under_embargo).and_return(mock_asset)

      allow(subject).to receive(:about_to_expire_embargoes_for_lead_days).with lead_days: 7
      allow(subject).to receive(:about_to_expire_embargoes_for_lead_days).with lead_days: 1
    }

    context "when @expiration_lead_days is blank" do
      it "calls LoggingHelper.bold_debug, calls about_to_expire_embargoes_for_lead_days with default values" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                      "from",
                                                                      "object class",
                                                                      "@email_owner=true",
                                                                      "@expiration_lead_days=",
                                                                      "@skip_file_sets=true",
                                                                      "@test_mode=true",
                                                                      "@to_console=false",
                                                                      "@verbose=false",
                                                                      ""]
        expect(subject).to receive(:about_to_expire_embargoes_for_lead_days).with lead_days: 7
        expect(subject).to receive(:about_to_expire_embargoes_for_lead_days).with lead_days: 1

        subject.run

        subject.instance_variable_get(:@now) == DateTime.new(2025, 5, 5)
        subject.instance_variable_get(:@assets) == [mock_asset]
      end
    end

    context "when @expiration_lead_days is an integer greater than zero" do
      before {
        subject.instance_variable_set(:@expiration_lead_days, "27")

        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                     "from",
                                                                     "object class",
                                                                     "@email_owner=true",
                                                                     "@expiration_lead_days=27",
                                                                     "@skip_file_sets=true",
                                                                     "@test_mode=true",
                                                                     "@to_console=false",
                                                                     "@verbose=false",
                                                                     ""]
        allow(subject).to receive(:about_to_expire_embargoes_for_lead_days).with lead_days: 27
      }

      it "calls LoggingHelper.bold_debug, calls about_to_expire_embargoes_for_lead_days with @expiration_lead_days" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                      "from",
                                                                      "object class",
                                                                      "@email_owner=true",
                                                                      "@expiration_lead_days=27",
                                                                      "@skip_file_sets=true",
                                                                      "@test_mode=true",
                                                                      "@to_console=false",
                                                                      "@verbose=false",
                                                                      ""]
        expect(subject).to receive(:about_to_expire_embargoes_for_lead_days).with lead_days: 27
        subject.run
      end
    end

    context "when @expiration_lead_days is 0 or less" do
      before {
        subject.instance_variable_set(:@expiration_lead_days, "0")

        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                     "from",
                                                                     "object class",
                                                                     "@email_owner=true",
                                                                     "@expiration_lead_days=0",
                                                                     "@skip_file_sets=true",
                                                                     "@test_mode=true",
                                                                     "@to_console=false",
                                                                     "@verbose=false",
                                                                     ""]
      }

      it "calls LoggingHelper.bold_debug, calls about_to_expire_embargoes_for_lead_days with default values" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                      "from",
                                                                      "object class",
                                                                      "@email_owner=true",
                                                                      "@expiration_lead_days=0",
                                                                      "@skip_file_sets=true",
                                                                      "@test_mode=true",
                                                                      "@to_console=false",
                                                                      "@verbose=false",
                                                                      ""]
        expect(subject).to receive(:about_to_expire_embargoes_for_lead_days).with lead_days: 7
        expect(subject).to receive(:about_to_expire_embargoes_for_lead_days).with lead_days: 1
        subject.run
      end
    end
  end


  describe "#about_to_expire_embargoes_for_lead_days" do
    before {
      allow(subject).to receive(:run_msg).with "about_to_expire_embargoes_for_lead_days: lead_days=21 days"
      subject.instance_variable_set(:@now, DateTime.new(2025, 2, 2))
      allow(subject).to receive(:run_msg).with "lead_date=20250202"
      allow(subject).to receive(:run_msg).with "1001 embargo_release_date=20250303"
      subject.instance_variable_set(:@email_owner, "email owner")
      subject.instance_variable_set(:@test_mode, "test mode")
      subject.instance_variable_set(:@verbose, "verbose")
    }

    context "when @skip_file_sets is true and asset.model_name is 'FileSet'" do
      before {
        subject.instance_variable_set(:@skip_file_sets, true)

        asset = MockAsset.new(id: 1001, model_name: "FileSet")
        subject.instance_variable_set(:@assets, [asset])
        allow(subject).to receive(:asset_embargo_release_date).with(asset: asset).and_return DateTime.new(2025, 3, 3)
      }
      it "skips loop through @assets " do
        expect(subject).to receive(:run_msg).with "about_to_expire_embargoes_for_lead_days: lead_days=21 days"
        expect(subject).to receive(:run_msg).with "lead_date=20250223"

        subject.about_to_expire_embargoes_for_lead_days lead_days: MockLeadTime.new(days: 21)
      end
    end

    context "when @skip_file_sets is false and asset.model_name is 'FileSet'" do
      before {
        subject.instance_variable_set(:@skip_file_sets, false)

        asset = MockAsset.new(id: 1001, model_name: "FileSet")
        subject.instance_variable_set(:@assets, [asset])
        allow(subject).to receive(:asset_embargo_release_date).with(asset: asset).and_return DateTime.new(2025, 3, 3)
      }
      it "outputs embargo_release_date" do
        expect(subject).to receive(:run_msg).with "about_to_expire_embargoes_for_lead_days: lead_days=21 days"
        expect(subject).to receive(:run_msg).with "lead_date=20250223"
        expect(subject).to receive(:run_msg).with "1001 embargo_release_date=20250303"

        subject.about_to_expire_embargoes_for_lead_days lead_days: MockLeadTime.new(days: 21)
      end
    end

    context "when @skip_file_sets is true and asset.model_name is not 'FileSet'" do
      before {
        subject.instance_variable_set(:@skip_file_sets, true)

        asset = MockAsset.new(id: 1001, model_name: "model name")
        subject.instance_variable_set(:@assets, [asset])
        allow(subject).to receive(:asset_embargo_release_date).with(asset: asset).and_return DateTime.new(2025, 3, 3)
      }

      it "outputs embargo_release_date" do
        expect(subject).to receive(:run_msg).with "about_to_expire_embargoes_for_lead_days: lead_days=21 days"
        expect(subject).to receive(:run_msg).with "lead_date=20250223"
        expect(subject).to receive(:run_msg).with "1001 embargo_release_date=20250303"

        subject.about_to_expire_embargoes_for_lead_days lead_days: MockLeadTime.new(days: 21)
      end
    end

    context "when embargo_release_date equals lead_date" do
      asset = MockAsset.new(id: 1001, model_name: "model name")

      before {
        subject.instance_variable_set(:@skip_file_sets, false)

        subject.instance_variable_set(:@assets, [asset])
        allow(subject).to receive(:asset_embargo_release_date).with(asset: asset).and_return DateTime.new(2025, 2, 23)
      }

      context "when @test_mode is false" do
        mockLeadTime = MockLeadTime.new(days: 21)

        before {
          subject.instance_variable_set(:@test_mode, false)
          allow(subject).to receive(:about_to_expire_embargo_email).with( asset: asset,
                                                                          expiration_days: mockLeadTime,
                                                                          email_owner: "email owner",
                                                                          test_mode: false,
                                                                          verbose: "verbose" )
        }
        it "calls about_to_expire_embargo_email" do
          expect(subject).to receive(:run_msg).with "about_to_expire_embargoes_for_lead_days: lead_days=21 days"
          expect(subject).to receive(:run_msg).with "lead_date=20250223"
          expect(subject).to receive(:run_msg).with "1001 embargo_release_date=20250223"
          expect(subject).to receive(:about_to_expire_embargo_email).with( asset: asset,
                                                                           expiration_days: mockLeadTime,
                                                                           email_owner: "email owner",
                                                                           test_mode: false,
                                                                           verbose: "verbose" )

          subject.about_to_expire_embargoes_for_lead_days lead_days: mockLeadTime
        end
      end

      context "when @test_mode is true" do
        before {
          subject.instance_variable_set(:@test_mode, true)
        }
        it "outputs message" do
          expect(subject).to receive(:run_msg).with "about_to_expire_embargoes_for_lead_days: lead_days=21 days"
          expect(subject).to receive(:run_msg).with "lead_date=20250223"
          expect(subject).to receive(:run_msg).with "1001 embargo_release_date=20250223"

          expect(subject).to receive(:run_msg).with "about to call about_to_expire_embargo_email for asset 1001"

          subject.about_to_expire_embargoes_for_lead_days lead_days: MockLeadTime.new(days: 21)
        end
      end
    end
  end


  describe "#run_msg" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:debug).with "message"
    }

    context "when @to_console is false" do
      before {
        subject.instance_variable_set(:@to_console, false)
      }
      it "calls LoggingHelper.debug" do
        expect(Deepblue::LoggingHelper).to receive(:debug).with "message"

        subject.run_msg "message"
      end
    end

    context "when @to_console is true" do
      before {
        subject.instance_variable_set(:@to_console, true)
      }
      it "calls LoggingHelper.debug" do
        expect(Deepblue::LoggingHelper).to receive(:debug).with "message"
        expect(subject).to receive(:puts).with("message")

        subject.run_msg "message"
      end
    end
  end

end
