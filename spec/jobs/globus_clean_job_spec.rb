require 'rails_helper'


RSpec.describe GlobusCleanJob do

  describe "#perform" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:debug).with "Globus: globus_clean_job(concern_id) begin globus clean"
      allow(GlobusJob).to receive(:target_download_dir).with("concern_id").and_return "download dir"
      allow(GlobusJob).to receive(:target_prep_dir).with( "concern_id", prefix: nil ).and_return "directory"
      allow(GlobusJob).to receive(:target_prep_tmp_dir).with( "concern_id", prefix: nil ).and_return "dir temp"
      allow(GlobusJob).to receive(:lock_file).with("concern_id").and_return "lock file concern_id"

      allow(subject).to receive(:globus_email_rds).with( description: "cleaned work concern_id directories")
      allow(Deepblue::LoggingHelper).to receive(:debug).with "Globus: globus_clean_job(concern_id) end globus clean"
    }

    context "calls with globus_locked is true and clean_download is false" do
      before {
        allow(subject).to receive(:globus_locked?).and_return true
      }

      it "does not reset or clean directories" do
        expect(Deepblue::LoggingHelper).to receive(:debug).with "Globus: globus_clean_job(concern_id) begin globus clean"

        expect(Deepblue::LoggingHelper).to receive(:debug).with "Globus: globus_clean_job(concern_id) end globus clean"
        expect(subject).not_to receive(:globus_error_reset)

        subject.perform "concern_id"
      end
    end


    context "calls with globus_locked is false and clean_download is false" do
      before {
        allow(subject).to receive(:globus_locked?).and_return false

        allow(GlobusJob).to receive(:clean_dir).with( "dir temp", delete_dir: true)
        allow(GlobusJob).to receive(:clean_dir).with( "directory", delete_dir: true )
        allow(subject).to receive(:globus_error_reset)
      }

      it "cleans target prep directories and resets" do
        expect(Deepblue::LoggingHelper).to receive(:debug).with "Globus: globus_clean_job(concern_id) begin globus clean"

        expect(GlobusJob).to receive(:clean_dir).with( "dir temp", delete_dir: true)
        expect(GlobusJob).to receive(:clean_dir).with( "directory", delete_dir: true )
        expect(subject).to receive(:globus_error_reset)
        expect(GlobusJob).not_to receive(:clean_file)

        expect(Deepblue::LoggingHelper).to receive(:debug).with "Globus: globus_clean_job(concern_id) end globus clean"

        subject.perform "concern_id"
      end
    end


    context "calls with globus_locked is true and clean_download is true" do
      before {
        allow(subject).to receive(:globus_locked?).and_return true

        allow(subject).to receive(:globus_ready_file).and_return "ready"
        allow(GlobusJob).to receive(:clean_dir).with "download dir", delete_dir: true
        allow(GlobusJob).to receive(:clean_file).with "ready"
      }

      it "does not reset but cleans target download directory and ready file" do
        expect(Deepblue::LoggingHelper).to receive(:debug).with "Globus: globus_clean_job(concern_id) begin globus clean"

        expect(subject).not_to receive(:globus_error_reset)

        expect(GlobusJob).to receive(:clean_dir).with "download dir", delete_dir: true
        expect(GlobusJob).to receive(:clean_file).with "ready"

        expect(Deepblue::LoggingHelper).to receive(:debug).with "Globus: globus_clean_job(concern_id) end globus clean"

        subject.perform "concern_id", clean_download: true
      end
    end

    after {
      expect(GlobusJob).to have_received(:target_download_dir).with "concern_id"
      expect(GlobusJob).to have_received(:target_prep_dir).with( "concern_id", prefix: nil )
      expect(GlobusJob).to have_received(:target_prep_tmp_dir).with( "concern_id", prefix: nil )
      expect(GlobusJob).to have_received(:lock_file).with "concern_id"

      expect(subject).to have_received(:globus_email_rds).with( description: "cleaned work concern_id directories")

      expect(subject.instance_variable_get(:@globus_concern_id)).to eq "concern_id"
      expect(subject.instance_variable_get(:@globus_log_prefix)).to eq "Globus: globus_clean_job(concern_id)"
      expect(subject.instance_variable_get(:@globus_lock_file)).to eq "lock file concern_id"
      expect(subject.instance_variable_get(:@globus_job_quiet)).to eq false

      expect(subject.instance_variable_get(:@target_download_dir)).to eq "download dir"
      expect(subject.instance_variable_get(:@target_prep_dir)).to eq "directory"
      expect(subject.instance_variable_get(:@target_prep_dir_tmp)).to eq "dir temp"
    }
  end

end
