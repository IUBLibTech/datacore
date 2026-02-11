require 'rails_helper'

class MockWrapper
  def uploaded_file
    "wrapper file upload"
  end

  def ingest_file(continue_job_chain: ,
                  continue_job_chain_later: ,
                  delete_input_file: ,
                  uploaded_file_ids: ,
                  bypass_fedora: )
  end
end

RSpec.describe IngestJob do

  pending "#after_perform"


  describe "#perform" do
    mock_wrapper = MockWrapper.new

    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:obj_to_json).with("wrapper", mock_wrapper).and_return "candy"
      allow(Deepblue::LoggingHelper).to receive(:obj_to_json).with("uploaded_file", "wrapper file upload").and_return "File Upload"
      allow(Deepblue::UploadHelper).to receive(:uploaded_file_id).with( "wrapper file upload" ).and_return "uploaded file ID"

      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "wrapper=#{mock_wrapper}", "candy", "notification=false",
                                                                    "continue_job_chain=true", "continue_job_chain_later=true", "delete_input_file=true",
                                                                    "uploaded_file=wrapper file upload", "File Upload",
                                                                    "uploaded_file.id=uploaded file ID",
                                                                    "uploaded_file_ids=[]", "bypass_fedora=false", "" ]
    }

    it "calls LoggingHelper.bold_debug and ingest_file" do
      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "wrapper=#{mock_wrapper}", "candy", "notification=false",
                                                                    "continue_job_chain=true", "continue_job_chain_later=true", "delete_input_file=true",
                                                                    "uploaded_file=wrapper file upload", "File Upload",
                                                                    "uploaded_file.id=uploaded file ID",
                                                                    "uploaded_file_ids=[]", "bypass_fedora=false", "" ]
      expect(mock_wrapper).to receive(:ingest_file).with(continue_job_chain: true, continue_job_chain_later: true, delete_input_file: true,
                                                         uploaded_file_ids: [], bypass_fedora: false)

      subject.perform(mock_wrapper)
    end
  end

end
