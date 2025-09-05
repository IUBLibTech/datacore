require 'rails_helper'


RSpec.describe GlobusCleanJob do

  describe "#perform" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:debug).with "Globus: globus_clean_job(concern_id) begin globus clean"

      allow(subject).to receive(:globus_email_rds).with( description: "cleaned work concern_id directories")
      allow(Deepblue::LoggingHelper).to receive(:debug).with "Globus: globus_clean_job(concern_id) end globus clean"
    }

    context "calls with globus_locked is true and clean_download is false" do
      before {
        allow(GlobusJob).to receive(:target_download_dir).with "concern_id"
        allow(GlobusJob).to receive(:target_prep_dir).with( "concern_id", prefix: nil )
        allow(GlobusJob).to receive(:target_prep_tmp_dir).with( "concern_id", prefix: nil )
        allow(GlobusJob).to receive(:lock_file).with "concern_id"

        allow(subject).to receive(:globus_locked?).and_return true
      }

      it "calls Deepblue::LoggingHelper debug" do
        expect(Deepblue::LoggingHelper).to receive(:debug).with "Globus: globus_clean_job(concern_id) begin globus clean"

        expect(GlobusJob).to receive(:target_download_dir).with "concern_id"
        expect(GlobusJob).to receive(:target_prep_dir).with( "concern_id", prefix: nil )
        expect(GlobusJob).to receive(:target_prep_tmp_dir).with( "concern_id", prefix: nil )
        expect(GlobusJob).to receive(:lock_file).with "concern_id"

        expect(subject).to receive(:globus_email_rds).with( description: "cleaned work concern_id directories")
        expect(Deepblue::LoggingHelper).to receive(:debug).with "Globus: globus_clean_job(concern_id) end globus clean"

        subject.perform "concern_id"
      end
    end


    context "calls with globus_locked is false and clean_download is false" do
      before {
        allow(GlobusJob).to receive(:target_download_dir).with "concern_id"
        allow(GlobusJob).to receive(:target_prep_dir).with( "concern_id", prefix: nil ).and_return "directory"
        allow(GlobusJob).to receive(:target_prep_tmp_dir).with( "concern_id", prefix: nil ).and_return "dir temp"
        allow(GlobusJob).to receive(:lock_file).with "concern_id"

        allow(subject).to receive(:globus_locked?).and_return false

        allow(GlobusJob).to receive(:clean_dir).with( "dir temp", delete_dir: true)
        allow(GlobusJob).to receive(:clean_dir).with( "directory", delete_dir: true )
        allow(subject).to receive(:globus_error_reset)
      }

      it "calls Deepblue::LoggingHelper debug" do
        expect(Deepblue::LoggingHelper).to receive(:debug).with "Globus: globus_clean_job(concern_id) begin globus clean"

        expect(GlobusJob).to receive(:target_download_dir).with "concern_id"
        expect(GlobusJob).to receive(:target_prep_dir).with( "concern_id", prefix: nil )
        expect(GlobusJob).to receive(:target_prep_tmp_dir).with( "concern_id", prefix: nil )
        expect(GlobusJob).to receive(:lock_file).with "concern_id"

        expect(GlobusJob).to receive(:clean_dir).with( "dir temp", delete_dir: true)
        expect(GlobusJob).to receive(:clean_dir).with( "directory", delete_dir: true )
        expect(subject).to receive(:globus_error_reset)

        expect(subject).to receive(:globus_email_rds).with( description: "cleaned work concern_id directories")
        expect(Deepblue::LoggingHelper).to receive(:debug).with "Globus: globus_clean_job(concern_id) end globus clean"

        subject.perform "concern_id"
      end
    end


    context "calls with globus_locked is true and clean_download is true" do
      before {
        allow(GlobusJob).to receive(:target_download_dir).with("concern_id").and_return "download dir"
        allow(GlobusJob).to receive(:target_prep_dir).with( "concern_id", prefix: nil )
        allow(GlobusJob).to receive(:target_prep_tmp_dir).with( "concern_id", prefix: nil )
        allow(GlobusJob).to receive(:lock_file).with "concern_id"

        allow(subject).to receive(:globus_locked?).and_return true

        allow(subject).to receive(:globus_ready_file).and_return "ready"
        allow(GlobusJob).to receive(:clean_dir).with "download dir", delete_dir: true
        allow(GlobusJob).to receive(:clean_file).with "ready"
      }

      it "calls Deepblue::LoggingHelper debug" do
        expect(Deepblue::LoggingHelper).to receive(:debug).with "Globus: globus_clean_job(concern_id) begin globus clean"

        expect(GlobusJob).to receive(:target_download_dir).with "concern_id"
        expect(GlobusJob).to receive(:target_prep_dir).with( "concern_id", prefix: nil )
        expect(GlobusJob).to receive(:target_prep_tmp_dir).with( "concern_id", prefix: nil )
        expect(GlobusJob).to receive(:lock_file).with "concern_id"

        expect(GlobusJob).to receive(:clean_dir).with "download dir", delete_dir: true
        expect(GlobusJob).to receive(:clean_file).with "ready"

        expect(subject).to receive(:globus_email_rds).with( description: "cleaned work concern_id directories")
        expect(Deepblue::LoggingHelper).to receive(:debug).with "Globus: globus_clean_job(concern_id) end globus clean"

        subject.perform "concern_id", clean_download: true
      end
    end

  end

end
