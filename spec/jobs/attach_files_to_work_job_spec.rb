require 'rails_helper'

class MockJobWork
  def id
    "work id"
  end

  def to_s
    "MockJobWork"
  end

  def file_set_ids
    ["id1", "id2", "id3"]
  end

  def permissions
    [MockPermission.new("public", "read"), MockPermission.new("private", "edit")]
  end
end

class MockPermission
  attr_accessor :name, :access

  def initialize(name, access)
    @name = name
    @access = access
  end

  def to_hash
    { name: @name, access: @access }
  end
end

class MockUpload
  def initialize(id)
    @id = id
  end

  def id
    @id
  end

  def to_s
    "MockUpload"
  end
end

class MockPathname
  def initialize(path)
    @path = path
  end

  def join(addition)
    "#{@path}, #{addition}"
  end
end

class MockJobWork
  def id
    "work id"
  end

  def file_set_ids
    ["file_set_id1", "file_set_id2"]
  end
end

class MockFileUpload
  def file
    OpenStruct.new(path: "file path")
  end

  def file_set_uri
    "file set uri"
  end

  def update(file_set_uri:)
  end
end

class MockFileSetActor
  def initialize(fileset)
    @fileset = fileset
  end
  def file_set
    @fileset
  end

  def create_metadata(metadata)
  end

  def attach_to_work(work, uploaded_file_id:)
  end

  def create_content(file, continue_job_chain_later: false, uploaded_file_ids: [], bypass_fedora: false)
  end
end


class MockFileSet
  def permissions_attributes=(attrs)
  end

  def uri
    'file set uri'
  end
end

class MockHyraxUploadedFile

  def class
    "MockHyraxUploadedFile"
  end

  def inspect
    "inspection"
  end
end




RSpec.describe AttachFilesToWorkJob do

  describe "constants" do
    it do
      expect(AttachFilesToWorkJob::ATTACH_FILES_TO_WORK_JOB_IS_VERBOSE).to eq true
      expect(AttachFilesToWorkJob::ATTACH_FILES_TO_WORK_UPLOAD_FILES_ASYNCHRONOUSLY).to eq false
    end
  end


  #pending "#perform"

  describe "#perform" do

    context "when no Exception occurs" do
      work = MockJobWork.new
      upload_file1 = MockUpload.new("fileupload1")
      upload_file2 = MockUpload.new("fileupload2")

      before {
        allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
        allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "from"
        allow(Deepblue::LoggingHelper).to receive(:bold_debug)

        allow(subject).to receive(:proxy_or_depositor).with work
        allow(User).to receive(:find_by_user_key).with("user key").and_return "the best user"
        allow(Deepblue::UploadHelper).to receive(:log)
        allow(subject).to receive(:validate_files!).with [upload_file1, upload_file2]
        allow(subject).to receive(:visibility_attributes).and_return "metadata"
        allow(subject).to receive(:upload_file).with work, upload_file1, "the best user", [{:access=>"read", :name=>"public"}, {:access=>"edit", :name=>"private"}],
                                                     "metadata", uploaded_file_ids: ["fileupload1", "fileupload2"], bypass_fedora: true
        allow(subject).to receive(:upload_file).with work, upload_file2, "the best user", [{:access=>"read", :name=>"public"}, {:access=>"edit", :name=>"private"}],
                                                     "metadata", uploaded_file_ids: ["fileupload1", "fileupload2"], bypass_fedora: true
        allow(Rails.logger).to receive(:error)
        allow(subject).to receive(:notify_attach_files_to_work_job_complete).with( failed_to_upload: [upload_file1, upload_file2],
                                                                                   uploaded_files: [upload_file1, upload_file2], user: "the best user", work: work )
      }

      it "validates and uploads files" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug)
        expect(subject).to receive(:proxy_or_depositor).with work
        expect(Deepblue::UploadHelper).to receive(:log)
        expect(subject).to receive(:validate_files!).with [upload_file1, upload_file2]
        expect(subject).to receive(:visibility_attributes)

        expect(subject).to receive(:upload_file).with work, upload_file1, "the best user", [{:access=>"read", :name=>"public"}, {:access=>"edit", :name=>"private"}],
                                                     "metadata", uploaded_file_ids: ["fileupload1", "fileupload2"], bypass_fedora: true
        expect(subject).to receive(:upload_file).with work, upload_file2, "the best user", [{:access=>"read", :name=>"public"}, {:access=>"edit", :name=>"private"}],
                                                     "metadata", uploaded_file_ids: ["fileupload1", "fileupload2"], bypass_fedora: true
        expect(Rails.logger).to receive(:error)
        expect(subject).to receive(:notify_attach_files_to_work_job_complete).with( failed_to_upload: [upload_file1, upload_file2],
                                                                                   uploaded_files: [upload_file1, upload_file2], user: "the best user", work: work )

        subject.perform(work, [upload_file1, upload_file2], "user key", :bypass_fedora => true)
      end
    end

    skip "test if failed based on changes to @processed" # currently assumes failed bc no change to @processed

    skip "test when Exception occurs"
  end



  # private methods

  describe "#attach_files_to_work_job_complete_email_user" do
    context "when email parameter is blank" do
      it "returns nil" do
        expect(subject.send(:attach_files_to_work_job_complete_email_user, email: "", lines: ["hi", "what's up"], subject: nil, work: nil)).to be_nil
      end
    end

    context "when lines parameter is blank" do
      it "returns nil" do
        expect(subject.send(:attach_files_to_work_job_complete_email_user, email: "example@org", lines: [], subject: nil, work: nil)).to be_nil
      end
    end

    context "when parameters are valid" do
      before {
        allow(Deepblue::EmailHelper).to receive(:log).with( class_name: "AttachFilesToWorkJob",
                                                            current_user: nil,
                                                            event: "upload",
                                                            event_note: 'files attached to work',
                                                            id: "working",
                                                            to: "example@org",
                                                            from: "example@org",
                                                            subject: "subjective",
                                                            body: ["hi", "what's up"])
        allow(Deepblue::EmailHelper).to receive(:send_email).with( to: "example@org", from: "example@org", subject: "subjective", body: "hi\nwhat's up" )
      }
      it "calls EmailHelper.log and EmailHelper.send_email" do
        expect(Deepblue::EmailHelper).to receive(:log).with( class_name: "AttachFilesToWorkJob",
                                                             current_user: nil,
                                                             event: "upload",
                                                             event_note: 'files attached to work',
                                                             id: "working",
                                                             to: "example@org",
                                                             from: "example@org",
                                                             subject: "subjective",
                                                             body: ["hi", "what's up"] )
        expect(Deepblue::EmailHelper).to receive(:send_email).with( to: "example@org", from: "example@org", subject: "subjective", body: "hi\nwhat's up" )

        subject.send(:attach_files_to_work_job_complete_email_user, email: "example@org", lines: ["hi", "what's up"],
                     subject: "subjective", work: OpenStruct.new(id: "working"))
      end
    end
  end


  describe "#data_set_url" do
    context "when " do
      before {
        allow(Deepblue::EmailHelper).to receive(:data_set_url).with( data_set: "work work" )
      }

      it "calls Deepblue::EmailHelper.data_set_url" do
        expect(Deepblue::EmailHelper).to receive(:data_set_url).with( data_set: "work work" )

        subject.send(:data_set_url, "work work")
      end
    end

    context "when Exception occurs" do
      before {
        allow(Deepblue::EmailHelper).to receive(:data_set_url).and_raise(Exception)
        allow(Rails.logger).to receive(:error)
      }

      it "calls Rails.logger.error and returns Exception as string" do
        expect(Rails.logger).to receive(:error)
        expect(subject.send(:data_set_url, "work work")).to eq "Exception"
      end
    end
  end


  describe "#file_stats" do
    context "when uploaded_file parameter file_set_uri field has a value" do
      before {
        allow(ActiveFedora::Base).to receive(:uri_to_id).with("file set uri").and_return "file set id"
        allow(FileSet).to receive(:find).with("file set id").and_return OpenStruct.new(original_name_value: "OG name val", file_size_value: "file size val")
      }
      it "gets file name and size based on file_set_uri" do
        expect(ActiveFedora::Base).to receive(:uri_to_id)
        expect(FileSet).to receive(:find)
        expect(Pathname).not_to receive(:new)

        expect(subject.send(:file_stats, OpenStruct.new(file_set_uri: "file set uri",
                                                        uploader: OpenStruct.new(path: "uploader path")))).to eq ["OG name val", "file size val"]
      end
    end

    context "when uploaded_file parameter file_set_uri field has NO value" do
      before {
        allow(Pathname).to receive(:new).with("uploader path").and_return OpenStruct.new(basename: "base name")
      }
      context "when uploader.path File does NOT exist" do
        before {
          allow(File).to receive(:exist?).with("uploader path").and_return false
        }
        it "gets file name based on uploader.path field on uploaded_file parameter" do
          expect(ActiveFedora::Base).not_to receive(:uri_to_id)
          expect(FileSet).not_to receive(:find)

          expect(subject.send(:file_stats,
                              OpenStruct.new(file_set_uri: nil,
                                             uploader: OpenStruct.new(path: "uploader path")))).to eq ["base name (large file still processing)", "(size TBD)"]
        end
      end

      context "when uploader.path File exists" do
        before {
          allow(File).to receive(:exist?).with("uploader path").and_return true
          allow(File).to receive(:size).with("uploader path").and_return "123 MB"
        }
        it "gets file name and size based on uploader.path field on uploaded_file parameter" do
          expect(File).to receive(:size).with("uploader path")
          expect(ActiveFedora::Base).not_to receive(:uri_to_id)
          expect(FileSet).not_to receive(:find)

          expect(subject.send(:file_stats,
                              OpenStruct.new(file_set_uri: nil,
                                             uploader: OpenStruct.new(path: "uploader path")))).to eq ["base name (large file still processing)", "123 MB"]
        end
      end

      after {
        expect(Pathname).to have_received(:new).with("uploader path")
        expect(File).to have_received(:exist?).with("uploader path")
      }
    end

    context "when Exception occurs" do
      before {
        allow(ActiveFedora::Base).to receive(:uri_to_id).with("file set uri").and_raise(Exception)
        allow(Rails.logger).to receive(:error)
      }
      it "calls Rails.logger.error and returns Exception as string" do
        expect(Rails.logger).to receive(:error)

        expect(subject.send(:file_stats, OpenStruct.new(file_set_uri: "file set uri"))).to eq ["Exception", ""]
      end
    end
  end


  describe "#notify_attach_files_to_work_job_complete" do
    context "when notify_user_file_upload_and_ingest_are_complete and notify_managers_file_upload_and_ingest_are_complete are both false" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:notify_user_file_upload_and_ingest_are_complete).and_return false
        allow(DeepBlueDocs::Application.config).to receive(:notify_managers_file_upload_and_ingest_are_complete).and_return false
      }

      it "returns nil" do
        expect(subject.send(:notify_attach_files_to_work_job_complete, failed_to_upload: nil, uploaded_files: [], user: nil, work: nil)).to be_nil
      end
    end

    context "when an Exception occurs" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:notify_user_file_upload_and_ingest_are_complete).and_raise(Exception)
        allow(Rails.logger).to receive(:error)
        allow(Deepblue::LoggingHelper).to receive(:bold_debug)
      }

      it "calls Rails.logger.error and LoggingHelper.bold_debug" do
        expect(Rails.logger).to receive(:error)
        expect(Deepblue::LoggingHelper).to receive(:bold_debug)

        subject.send(:notify_attach_files_to_work_job_complete, failed_to_upload: nil, uploaded_files: [], user: nil, work: nil)
      end
    end

    skip "Add tests for when notify_user_file_upload_and_ingest_are_complete and notify_managers_file_upload_and_ingest_are_complete are true"
  end


  describe "#proxy_or_depositor" do
    context "when on_behalf_of field on work parameter is blank" do
      it "returns depositor field" do
        expect(subject.send(:proxy_or_depositor, OpenStruct.new(on_behalf_of: "", depositor: "depositor"))).to eq "depositor"
      end
    end

    context "when on_behalf_of field on work parameter has a value" do
      it "returns on_behalf_of field" do
        expect(subject.send(:proxy_or_depositor, OpenStruct.new(on_behalf_of: "supervisor", depositor: "depositor"))).to eq "supervisor"
      end
    end
  end


  describe "#upload_file" do
    work = MockJobWork.new
    uploaded_file = MockFileUpload.new
    uploaded_file_ids =  ["upload file id1", "upload file id2"]

    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:obj_attribute_names).with( "uploaded_file", uploaded_file ).and_return "obj attribute names"
      allow(Deepblue::LoggingHelper).to receive(:obj_to_json).with( "uploaded_file", uploaded_file ).and_return "json obj"
      allow(Deepblue::UploadHelper).to receive(:uploaded_file_id).with( uploaded_file ).and_return "uploaded file id"
      allow(Deepblue::UploadHelper).to receive(:uploaded_file_path).with( uploaded_file ).and_return "path"
      allow(Deepblue::UploadHelper).to receive(:uploaded_file_size).with( uploaded_file ).and_return "size"

      allow(Deepblue::LoggingHelper).to receive(:bold_debug)
      allow(Deepblue::UploadHelper).to receive(:log)
    }

    context "when uploaded_file file_size_category is :standard" do
      fileset = MockFileSet.new
      fileset_actor = MockFileSetActor.new(fileset)

      before {
        allow(subject).to receive(:file_size_category).with(uploaded_file).and_return :standard
        allow(subject).to receive(:copy_to_outbox!).with(uploaded_file, work)
        allow(FileSet).to receive(:create).and_return "FileSet create"
        allow(Hyrax::Actors::FileSetActor).to receive(:new).with("FileSet create", "user").and_return fileset_actor
      }

      it "calls copy_to_outbox! and UploadHelper.log" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug)
        expect(Deepblue::UploadHelper).to receive(:log)
        expect(subject).to receive(:copy_to_outbox!).with(uploaded_file, work)
        expect(Hyrax::Actors::FileSetActor).to receive(:new).with("FileSet create", "user")
        expect(fileset).to receive(:permissions_attributes=).with("work permissions")
        expect(fileset_actor).to receive(:create_metadata).with("metadata")
        expect(fileset_actor).to receive(:attach_to_work).with(work, uploaded_file_id: "uploaded file id")
        expect(uploaded_file).to receive(:update).with(file_set_uri: "file set uri")
        expect(fileset_actor).to receive(:create_content).with(uploaded_file, continue_job_chain_later: false, uploaded_file_ids: uploaded_file_ids,
                                                               bypass_fedora: false)
        subject.send(:upload_file, work, uploaded_file, "user", "work permissions", "metadata", uploaded_file_ids: uploaded_file_ids)
      end
    end

    context "when uploaded_file file_size_category is :large or :excessive" do
      before {
        allow(subject).to receive(:move_to_inbox!).with(uploaded_file, work)
      }

      sizes = [:large, :excessive]
      sizes.each do |size|
        before {
          allow(subject).to receive(:file_size_category).with(uploaded_file).and_return size
        }
        it "calls move_to_inbox! and UploadHelper.log" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug)
          expect(Deepblue::UploadHelper).to receive(:log)
          expect(subject).to receive(:move_to_inbox!).with(uploaded_file, work)

          subject.send(:upload_file, work, uploaded_file, "user", "work permissions", "metadata", uploaded_file_ids: uploaded_file_ids)
        end
      end
    end

    context "when Exception occurs" do
      before {
        allow(subject).to receive(:file_size_category).with(uploaded_file).and_return :error
        allow(Rails.logger).to receive(:error)
        allow(File).to receive(:size).with "file path"
      }
      it "calls Rails.logger error and UploadHelper.log twice" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug)
        expect(Deepblue::UploadHelper).to receive(:log).twice
        expect(Rails.logger).to receive(:error)

        subject.send(:upload_file, work, uploaded_file, "user", "work permissions", "metadata", uploaded_file_ids: uploaded_file_ids)

        rescue Exception
          # raises Exception
      end
    end

    skip "Add a test for @processed end value"
  end


  describe "#visibility_attributes" do
    it "returns a subsection of attributes hash parameter" do
      sliced = { :visibility => "good", :visibility_during_lease => "public", :visibility_after_lease => "private", :lease_expiration_date => "soon",
                 :embargo_release_date => "someday", :visibility_during_embargo => "restricted", :visibility_after_embargo => "open" }
      attr = sliced.merge(:engagement => "high")

      expect(subject.send(:visibility_attributes, attr)).to eq sliced
    end
  end


  describe "#validate_files!" do
    context "when all uploaded files are valid" do
      it "returns uploaded_files parameter" do
        uploaded_file = Hyrax::UploadedFile.new
        expect(subject.send(:validate_files!, [uploaded_file])).to eq [uploaded_file]
      end
    end

    context "when NOT all uploaded files are valid" do
      before {
        allow(Rails.logger).to receive(:error).with "Hyrax::UploadedFile required, but MockHyraxUploadedFile received: inspection"
      }
      it "calls Rails.logger.error and raises ArgumentError" do
        expect(Rails.logger).to receive(:error).with "Hyrax::UploadedFile required, but MockHyraxUploadedFile received: inspection"

        subject.send(:validate_files!, [Hyrax::UploadedFile.new, MockHyraxUploadedFile.new])

        rescue ArgumentError => e
          expect(e.message).to eq "Hyrax::UploadedFile required, but MockHyraxUploadedFile received: inspection"
          # raises Exception
      end
    end
  end


  describe "#file_size_category" do
    file_sizes = [{"size" => -1,                  "result" => :error},
                  {"size" => (5 * (2**30)),       "result" => :standard},
                  {"size" => (100 * (2**30)),     "result" => :large},
                  {"size" => (100 * (2**30)) + 1, "result" => :excessive}]

    file_sizes.each do |file_size|
      context "when File.size returns #{file_size["size"]}" do
        before {
          allow(File).to receive(:size).with("uploaded file uploader path").and_return file_size["size"]
        }

        it "returns #{file_size["result"]}" do
          expect(subject.send(:file_size_category, OpenStruct.new(uploader: OpenStruct.new(path: "uploaded file uploader path")))).to eq file_size["result"]
        end
      end
    end

    context "when calling File.size raises an Exception" do
      before {
        allow(File).to receive(:size).with("uploaded file uploader path").and_raise(Exception)
        allow(Rails.logger).to receive(:error)
      }

      it "returns :error" do
        expect(subject.send(:file_size_category, OpenStruct.new(uploader: OpenStruct.new(path: "uploaded file uploader path", inspect: "inspected")))).to eq :error

        rescue Exception
          # raises Exception
      end

      skip "Add a test for Rails.logger.error"
    end
  end


  describe "#copy_to_outbox!" do
    before {
      allow(Settings.ingest).to receive(:outbox).and_return "ingest outbox"
      allow(subject).to receive(:dropbox_action!).with("uploaded file", "work", "ingest outbox", :cp)
    }

    it "calls dropbox_action! with parameters" do
      expect(subject).to receive(:dropbox_action!).with("uploaded file", "work", "ingest outbox", :cp)

      subject.send(:copy_to_outbox!, "uploaded file", "work")
    end
  end


  describe '#move_to_inbox!' do
    before {
      allow(Settings.ingest).to receive(:large_inbox).and_return "ingest large box"
      allow(subject).to receive(:dropbox_action!).with("uploaded file", "work", "ingest large box", :mv)
    }

    it "calls dropbox_action! with parameters" do
      expect(subject).to receive(:dropbox_action!).with("uploaded file", "work", "ingest large box", :mv)

      subject.send(:move_to_inbox!, "uploaded file", "work")
    end
  end


  describe "#dropbox_action!" do
    before {
      allow(Pathname).to receive(:new).with("uploaded file uploader path").and_return OpenStruct.new(basename: "origin file")
      allow(Pathname).to receive(:new).with("destination dir").and_return ["destination dir"]
      allow(FileUtils).to receive(:send).with("action", "uploaded file uploader path", "destination dir, work id_origin file")
    }

    it "calls FileUtils.send" do
      expect(Pathname).to receive(:new).with("uploaded file uploader path").and_return OpenStruct.new(basename: "origin file")
      expect(Pathname).to receive(:new).with("destination dir").and_return MockPathname.new("destination dir")
      expect(FileUtils).to receive(:send).with("action", "uploaded file uploader path", "destination dir, work id_origin file")

      subject.send(:dropbox_action!, OpenStruct.new(uploader: OpenStruct.new(path: "uploaded file uploader path")),
                                     OpenStruct.new(id: "work id"), "destination dir", "action")
    end

  end

end
