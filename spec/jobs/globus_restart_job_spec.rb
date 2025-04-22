require 'rails_helper'


RSpec.describe GlobusRestartJob do

  describe "#perform" do

    context "calls with force_restart false" do
      before {
        allow(GlobusCopyJob).to receive(:perform_later).with("concern_id", user_email: nil, log_prefix:"Globus: ")
      }

      it "calls GlobusCopyJob.perform_later" do
        expect(GlobusCopyJob).to receive(:perform_later).with("concern_id", user_email: nil, log_prefix:"Globus: ")

        subject.perform "concern_id"
      end
    end

    context "calls with force_restart true" do
      before {
        allow(GlobusJob).to receive(:lock_file).with("concern_id")
        allow(GlobusCopyJob).to receive(:perform_later).with("concern_id", user_email: nil, log_prefix:"Globus: ")
        allow(subject).to receive(:globus_unlock)
      }

      it "calls GlobusJob.lock_file, globus_unlock and GlobusCopyJob.perform_later" do
        expect(GlobusJob).to receive(:lock_file).with("concern_id")
        expect(GlobusCopyJob).to receive(:perform_later).with("concern_id", user_email: nil, log_prefix:"Globus: ")
        expect(subject).to receive(:globus_unlock)

        subject.perform "concern_id", force_restart: true
      end
    end

  end

end
