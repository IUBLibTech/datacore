require 'rails_helper'


RSpec.describe CharacterizeJob do

  describe "#perform" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "file_set=file set)", "repository_file_id=file id",
                                                                    "filepath=file path", "continue_job_chain=true",
                                                                    "continue_job_chain_later=true", "current_user=current user",
                                                                    "delete_input_file=true", "uploaded_file_ids=[]", "" ]
    }

    context "when no exception is raised" do
      before {
        allow(Deepblue::IngestHelper).to receive(:characterize).with( "file set", "file id", "file path", continue_job_chain: true,
                                                                      continue_job_chain_later: true,
                                                                      current_user: "current user",
                                                                      delete_input_file: true,
                                                                      uploaded_file_ids: [] )
      }
      it "calls LoggingHelper.bold_debug and IngestHelper.characterize" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "file_set=file set)", "repository_file_id=file id",
                                                                      "filepath=file path", "continue_job_chain=true",
                                                                      "continue_job_chain_later=true", "current_user=current user",
                                                                      "delete_input_file=true", "uploaded_file_ids=[]", "" ]
        expect(Deepblue::IngestHelper).to receive(:characterize).with( "file set", "file id", "file path", continue_job_chain: true,
                                                                       continue_job_chain_later: true,
                                                                       current_user: "current user",
                                                                       delete_input_file: true,
                                                                       uploaded_file_ids: [] )

        subject.perform("file set", "file id", "file path", current_user: "current user")
      end
    end


    context "when an exception is raised calling IngestHelper.characterize" do
      before {
        allow(Deepblue::IngestHelper).to receive(:characterize).with( "file set", "file id", "file path", continue_job_chain: true,
                                                                      continue_job_chain_later: true,
                                                                      current_user: "current user",
                                                                      delete_input_file: true,
                                                                      uploaded_file_ids: [] ).and_raise(Exception, "characterize error")
      }
      it "calls LoggingHelper.bold_debug and Rails.logger.error" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "file_set=file set)", "repository_file_id=file id",
                                                                       "filepath=file path", "continue_job_chain=true",
                                                                       "continue_job_chain_later=true", "current_user=current user",
                                                                       "delete_input_file=true", "uploaded_file_ids=[]", "" ]
        expect(Deepblue::IngestHelper).to receive(:characterize).with( "file set", "file id", "file path", continue_job_chain: true,
                                                                        continue_job_chain_later: true,
                                                                        current_user: "current user",
                                                                        delete_input_file: true,
                                                                        uploaded_file_ids: [] ).and_raise(Exception, "characterize error")
        expect(Rails.logger).to receive(:error).with("CharacterizeJob.perform(file set,file id,file path) Exception: characterize error")

        subject.perform("file set", "file id", "file path", current_user: "current user")
      end
    end

  end


end
