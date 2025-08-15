require 'rails_helper'


RSpec.describe Hyrax::ApplicationJob::CreateDerivativesJob do

  describe "#perform" do

    context "calls without any errors" do
      before {
        allow(Deepblue::IngestHelper).to receive(:create_derivatives).with("file_set", "file_id", "filepath",
                                                                           current_user: nil, delete_input_file: true, uploaded_file_ids: [])
      }
      it "calls Deepblue::IngestHelper create_derivatives" do
        expect(Deepblue::IngestHelper).to receive(:create_derivatives).with("file_set", "file_id", "filepath",
                                                                            current_user: nil, delete_input_file: true, uploaded_file_ids: [])

        subject.perform "file_set", "file_id", "filepath"
      end
    end

    context "calls with error" do
      before {
        allow(Deepblue::IngestHelper).to receive(:create_derivatives).with("file_set", "file_id", "filepath",
                current_user: nil, delete_input_file: true, uploaded_file_ids: []) { raise StandardError.new "This is an exception" }
      }
      
      it "calls Rails.logger.error" do
        expect(Rails.logger).to receive(:error).with("CreateDerivativesJob.perform(file_set,file_id,filepath) StandardError: This is an exception")

        subject.perform "file_set", "file_id", "filepath"
      end
    end
  end


end
