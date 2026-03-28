require 'rails_helper'


RSpec.describe GlobusRestartJob do

  describe "#perform" do
    before {
      allow(GlobusCopyJob).to receive(:perform_later).with("concern_id", user_email: nil, log_prefix:"Globus: ")
    }

    context "when force_restart false" do
      it "calls GlobusCopyJob.perform_later" do
        expect(GlobusJob).not_to receive(:lock_file)
        expect(subject).not_to receive(:globus_unlock)
        expect(GlobusCopyJob).to receive(:perform_later).with("concern_id", user_email: nil, log_prefix:"Globus: ")

        subject.perform "concern_id"

        expect(subject.instance_variable_get(:@globus_log_prefix)).to be_nil
        expect(subject.instance_variable_get(:@globus_lock_file)).to be_nil
      end
    end

    context "when force_restart true" do
      before {
        allow(GlobusJob).to receive(:lock_file).with("concern_id").and_return "lock file concern_id"
        allow(subject).to receive(:globus_unlock)
      }

      it "calls GlobusJob.lock_file, globus_unlock and GlobusCopyJob.perform_later" do
        expect(GlobusJob).to receive(:lock_file).with("concern_id")
        expect(subject).to receive(:globus_unlock)
        expect(GlobusCopyJob).to receive(:perform_later).with("concern_id", user_email: nil, log_prefix:"Globus: ")

        subject.perform "concern_id", force_restart: true

        expect(subject.instance_variable_get(:@globus_log_prefix)).to eq "Globus: globus_restart_job"
        expect(subject.instance_variable_get(:@globus_lock_file)).to eq "lock file concern_id"
      end
    end

  end

end
