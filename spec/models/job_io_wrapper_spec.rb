class MockFileActor
  def class
    OpenStruct.new(name: "MockFileActor")
  end

  def ingest_file (caller, continue_job_chain:, continue_job_chain_later:, current_user:, delete_input_file:, uploaded_file_ids:, bypass_fedora:)
  end
end

class MockUploadedFile

  def uploader
    OpenStruct.new(filename: "the file name", content_type: "image/jpeg")
  end
end

class MockFileParam

  def class
    "MockFileParam"
  end

  def to_s
    "Mock File Param"
  end
end



RSpec.describe JobIoWrapper do


  describe "#self.create_with_varied_file_handling!" do
    context "when incorrect parameters are provided" do
      it "raises an Exception with a custom error message" do
        begin
          JobIoWrapper.create_with_varied_file_handling!(user: "user", file: MockFileParam.new, relation: "relation", file_set: OpenStruct.new(id: "ID:123"))
        rescue Exception => e
          expect(e.message).to eq "Require Hyrax::UploadedFile or File-like object, received MockFileParam object: Mock File Param"
        end
      end
    end

    skip "Add a test for Hyrax::UploadedFile"
    skip "Add a test for a file object with path"
  end


  describe "#original_name" do

    skip "Add a test for when calling parent method returns a value"

    context "when calling parent method does not return a value" do
      before {
        allow(subject).to receive(:extracted_original_name).and_return "Concentrated Extract"
      }
      it "calls extracted_original_name" do
        expect(subject).to receive(:extracted_original_name)
        expect(subject.original_name).to eq "Concentrated Extract"
      end
    end
  end


  describe "#mime_type" do

    skip "Add a test for when calling parent method returns a value"

    context "when calling parent method does not return a value" do
      before {
        allow(subject).to receive(:extracted_mime_type).and_return "Mimetic"
      }
      it "calls extracted_mime_type" do
        expect(subject).to receive(:extracted_mime_type)
        expect(subject.mime_type).to eq "Mimetic"
      end
    end
  end


  describe "#file_set" do
    before {
      allow(subject).to receive(:file_set_id).and_return "K-400"
      allow(FileSet).to receive(:find).with("K-400").and_return "Found Set"
    }

    it "returns FileSet.find" do
      expect(subject.file_set).to eq "Found Set"
    end
  end


  describe "#file_actor" do
    before {
      allow(subject).to receive(:file_set).and_return "file set"
      allow(subject).to receive(:relation).and_return "relational"
      allow(subject).to receive(:user).and_return "current user"
      allow(Hyrax::Actors::FileActor).to receive(:new).with("file set", :relational, "current user").and_return "file actor"
    }
    it "returns new FileActor" do
      expect(subject.file_actor).to eq "file actor"
    end
  end


  describe "#ingest_file" do
    file_actor = MockFileActor.new
    before {
      allow(subject).to receive(:file_actor).and_return file_actor
      allow(subject).to receive(:caller_locations).with(1, 1).and_return ["caller locations"]
      allow(subject).to receive(:relation).and_return "relativity"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["caller locations", "actor.class=MockFileActor", "relation=relativity", "continue_job_chain=true",
                                                                   "continue_job_chain_later=true", "delete_input_file=true", "uploaded_file_ids=[123, 456, 789]",
                                                                   "bypass_fedora=false", ""]
    }

    context "when user_id is nil" do
      it "ingests file without user_id and logs action" do
        expect(file_actor).to receive(:ingest_file).with(subject, continue_job_chain: true, continue_job_chain_later: true, current_user: nil, delete_input_file: true,
                                                         uploaded_file_ids: [123, 456, 789], bypass_fedora: false)
        expect(User).not_to receive(:find)
        subject.ingest_file uploaded_file_ids: [123, 456, 789]
      end
    end

    context "when user_id has a value" do
      before {
        allow(subject).to receive(:user_id).and_return "D-398"
        allow(User).to receive(:find).with("D-398").and_return OpenStruct.new(user_key: 12345)
      }
      it "ingests file with user_id and logs action" do
        expect(file_actor).to receive(:ingest_file).with(subject, continue_job_chain: true, continue_job_chain_later: true, current_user: 12345, delete_input_file: true,
                                                         uploaded_file_ids: [123, 456, 789], bypass_fedora: false)
        expect(User).to receive(:find).with("D-398")
        subject.ingest_file uploaded_file_ids: [123, 456, 789]
      end
    end

    after {
      expect(Deepblue::LoggingHelper).to have_received(:bold_debug).with ["caller locations", "actor.class=MockFileActor", "relation=relativity", "continue_job_chain=true",
                                                                    "continue_job_chain_later=true", "delete_input_file=true", "uploaded_file_ids=[123, 456, 789]", "bypass_fedora=false", ""]
    }
  end


  # private methods

  describe "#extracted_original_name" do
    context "when uploaded_file has a value" do
      before {
        allow(subject).to receive(:uploaded_file).and_return MockUploadedFile.new
      }
      it "returns uploader file name" do
        expect(subject).to receive(:uploaded_file)
        expect(File).not_to receive(:basename)
        expect(subject.send(:extracted_original_name)).to eq "the file name"
      end
    end

    context "when uploaded_file has no value" do
      context "when path is present" do
        before {
          allow(subject).to receive(:path).and_return "the file path"
          allow(File).to receive(:basename).with("the file path").and_return "the file basename"
        }
        it "returns File basename path" do
          expect(File).to receive(:basename).with("the file path")
          expect(subject.send(:extracted_original_name)).to eq "the file basename"
        end
      end

      context "when path is not present" do
        it "returns nil" do
          expect(File).not_to receive(:basename)

          expect(subject.send(:extracted_original_name)).to be_blank
        end
      end
    end


    describe "#extracted_mime_type" do
      context "when uploaded_file has a value" do
        before {
          allow(subject).to receive(:uploaded_file).and_return MockUploadedFile.new
        }
        it "returns uploader content type" do
          expect(Hydra::PCDM::GetMimeTypeForFile).not_to receive(:call)
          expect(subject.send(:extracted_mime_type)).to eq "image/jpeg"
        end
      end

      context "when uploaded_file has no value" do
        before {
          allow(subject).to receive(:original_name).and_return "the original name"
          allow(Hydra::PCDM::GetMimeTypeForFile).to receive(:call).with("the original name").and_return "image/png"
        }
        it "returns mime type for file original name" do
          expect(Hydra::PCDM::GetMimeTypeForFile).to receive(:call)
          expect(subject.send(:extracted_mime_type)).to eq "image/png"
        end
      end
    end
  end


  describe "#file" do
    context "when instance variable has a value" do
      before {
        subject.instance_variable_set :@file, "file object"
      }
      it "returns instance variable" do
        expect(subject).not_to receive(:file_from_path)
        expect(subject).not_to receive(:file_from_uploaded_file!)
        expect(subject.send(:file)).to eq "file object"
      end
    end

    context "when instance variable does not have a value" do

      context "when file_from_path returns a value" do
        before {
          allow(subject).to receive(:file_from_path).and_return "file from path"
        }
        it "sets instance variable to file_from_path and returns it" do
          expect(subject).to receive(:file_from_path)
          expect(subject).not_to receive(:file_from_uploaded_file!)
          expect(subject.send(:file)).to eq "file from path"
          expect(subject.instance_variable_get :@file).to eq "file from path"
        end
      end

      context "when file_from_path does not return a value" do
        context "when file_from_uploaded_file returns a value" do
          before {
            allow(subject).to receive(:file_from_path).and_return nil
            allow(subject).to receive(:file_from_uploaded_file!).and_return "file from uploaded file"
          }
          it "sets instance variable to file_from_uploaded_file and returns it" do
            expect(subject).to receive(:file_from_path)
            expect(subject).to receive(:file_from_uploaded_file!)
            expect(subject.send(:file)).to eq "file from uploaded file"
            expect(subject.instance_variable_get :@file).to eq "file from uploaded file"
          end
        end

        context "when file_from_uploaded_file does not return a value" do
          before {
            allow(subject).to receive(:file_from_path).and_return nil
            allow(subject).to receive(:file_from_uploaded_file!).and_return nil
          }
          it "returns nil" do
            expect(subject).to receive(:file_from_path)
            expect(subject).to receive(:file_from_uploaded_file!)
            expect(subject.send(:file)).to be_blank
          end
        end
      end
    end
  end


  describe "#file_from_uploaded_file!" do
    before {
      allow(subject).to receive(:path).and_return "The Path"
    }

    context "when uploaded_file has no value" do
      it "raises error" do
        expect(subject).to receive(:raise).with("path 'The Path' was unusable and uploaded_file empty")
        expect{subject.send(:file_from_uploaded_file!)}.to raise_error
      end
    end

    context "when uploaded_file has a value" do
      before {
        upload_file = OpenStruct.new(uploader: OpenStruct.new(file: OpenStruct.new(path: "uploaded file uploader file path"),
                                                              sanitized_file: OpenStruct.new(file: "uploaded file uploader sanitized file")))
        allow(subject).to receive(:uploaded_file).and_return upload_file
      }
      it "return sanitized uploaded file" do
        expect(subject).not_to receive(:raise)
        expect(subject.send(:file_from_uploaded_file!)).to eq "uploaded file uploader sanitized file"
      end
    end
  end


  describe "#file_from_path" do
    context "when path is not present" do
      it "does not open file path" do
        expect(File).not_to receive(:exist?)
        expect(File).not_to receive(:readable?)
        expect(File).not_to receive(:open)

        subject.send(:file_from_path)
      end
    end

    context "when path is present" do
      before {
        allow(subject).to receive(:path).and_return "pathological"
      }

      context "when file does not exist" do
        before {
          allow(File).to receive(:exist?).with("pathological").and_return false
        }
        it "does not open file path" do
          expect(File).to receive(:exist?)
          expect(File).not_to receive(:readable?)
          expect(File).not_to receive(:open)

          subject.send(:file_from_path)
        end
      end

      context "when file exists" do
        before {
          allow(File).to receive(:exist?).with("pathological").and_return true
        }

        context "when file is not readable" do
          before {
            allow(File).to receive(:readable?).with("pathological").and_return false
          }
          it "does not open file path" do
            expect(File).to receive(:exist?)
            expect(File).to receive(:readable?)
            expect(File).not_to receive(:open)
            subject.send(:file_from_path)
          end
        end

        context "when readable file exists" do
          before {
            allow(File).to receive(:readable?).with("pathological").and_return true
            allow(File).to receive(:open).with("pathological", 'rb')
          }
          it "open file path" do
            expect(File).to receive(:open).with("pathological", 'rb')
            subject.send(:file_from_path)
          end
        end
      end
    end
  end

  describe "#static_defaults" do
    it "returns string" do
      expect(subject.send(:static_defaults)).to eq "original_file"
    end
  end

end
