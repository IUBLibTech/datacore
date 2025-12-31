require 'rails_helper'

class MockFileActor

  def ingest_file(io_wrapper, continue_job_chain_later:, bypass_fedora:)
  end
end

class MockFileSet
  def initialize (id, label, created)
    @id = id
    @label = label
    @created = created
  end

  def id
    @id
  end

  def parent
    OpenStruct.new(id: @id)
  end

  def creator=(creator)
  end

  def depositor=(depositor_id)
  end

  def label
    @label
  end

  def label=(label)
    @label = label
  end

  def latest_version
    OpenStruct.new(label: @label, created: @created)
  end

  def date_uploaded=(date_uploaded)
  end

  def date_modified=(date_modified)
  end

  def save
  end

  def reload
  end

  def destroy
  end

  def provenance_update_version(current_user:, event_note:, new_create_date:, new_revision_id:, prior_create_date:, prior_revision_id:, revision_id:)
  end
end

class MockWork

  def initialize(id, new_record = false)
    @id = id
    @new_record = new_record
  end

  def id
    @id
  end

  def reload
  end

  def new_record?
    @new_record
  end

  def visibility
    true
  end

  def ordered_members
    @ordered_members ||= []
  end

  def representative=(file_set)
  end

  def thumbnail=(file_set)
  end

  def save
  end
end

class MockLinkWork

  def initialize()
    @thumbnail = "thumbnail"
    @rep = "representative"
    @rendering_ids = ["rendering id", "thumbnail id", "representative id"]
  end

  def total_file_size_subtract_file_set!(file_set)
  end

  def thumbnail_id
    "thumbnail id"
  end

  def representative_id
    "representative id"
  end

  def rendering_ids
    @rendering_ids
  end

  def thumbnail
    @thumbnail
  end

  def thumbnail=(thumbnail)
    @thumbnail = thumbnail
  end

  def representative
    @rep
  end
  def representative=(representative)
    @rep = representative
  end

  def rendering_ids=(rendering_ids)
    @rendering_ids = rendering_ids
  end

  def save!
  end
end

class MockDepositor

  def initialize(user_key)
    @user_key = user_key
  end

  def user_key
    @user_key
  end
end

class MockFileUpload

  def original_name
    "original name"
  end
end

class MockBuildFileActor

  def initialize(answer)
    @answer = answer
  end
  def revert_to (id)
    @answer
  end
end

class MockUploadedFile < Hyrax::UploadedFile

  def initialize(filename)
    @filename = filename
  end
  def uploader
    OpenStruct.new(filename: @filename)
  end

  def file_url
    "http://www.example.com/index.html"
  end
end




RSpec.describe Hyrax::Actors::FileSetActor do

  subject { described_class.new("file set", "active user") }


  describe "#initialize" do
    it "creates instance variables" do
      actor_file = Hyrax::Actors::FileSetActor.new("file set", "user")

      actor_file.instance_variable_get(:@file_set) == "file set"
      actor_file.instance_variable_get(:@user) == "user"
    end
  end


  describe "#create_content" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:obj_to_json).with("file", "a file").and_return "json string"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "file=a file", "json string", "relation=original", "from_url=false",
                                                                   "continue_job_chain_later=true", "uploaded_file_ids=[101, 202]", "bypass_fedora=false", ""]
    }

    context "when file_set.save evaluates to false and file_set.title is blank" do
      fileset = OpenStruct.new(label: "the fileset", title: "", save: false)
      subject { described_class.new(fileset, "the user") }

      before {
        allow(subject).to receive(:remove_work_id_from_label).with(fileset)
      }
      it "file set label and title are the same" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "file=a file", "json string", "relation=original", "from_url=false",
                                                                     "continue_job_chain_later=true", "uploaded_file_ids=[101, 202]", "bypass_fedora=false", ""]
        expect(subject).not_to receive(:label_for)
        expect(subject).to receive(:remove_work_id_from_label).with(fileset)

        expect(subject.create_content("a file", "original", uploaded_file_ids: [101, 202])).to eq false
        expect(subject.file_set.label).to eq "the fileset"
        expect(subject.file_set.title).to eq ["the fileset"]
      end
    end


    context "when file_set.save is true and from_url is false and file_set.label is nil and file_set.title is not blank" do
      file_set = OpenStruct.new(label: nil, title: "Grand Title", save: true)
      subject { described_class.new(file_set, "the user") }

      before {
        allow(subject).to receive(:label_for).with("a file", bypass_fedora: false).and_return "Fabulous Label"
        allow(subject).to receive(:remove_work_id_from_label).with(file_set)
        allow(subject).to receive(:wrapper!).with( file: "a file", relation: "original" ).and_return "io wrapper"
        allow(IngestJob).to receive(:perform_now).with("io wrapper", continue_job_chain_later: true, uploaded_file_ids: [101, 202], bypass_fedora: false )
      }
      it "file set label and title are different" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "file=a file", "json string", "relation=original", "from_url=false",
                                                                      "continue_job_chain_later=true", "uploaded_file_ids=[101, 202]", "bypass_fedora=false", ""]
        expect(subject).to receive(:label_for).with("a file", bypass_fedora: false)
        expect(subject).to receive(:remove_work_id_from_label).with(file_set)
        expect(subject).to receive(:wrapper!).with( file: "a file", relation: "original" )
        expect(IngestJob).to receive(:perform_now).with("io wrapper", continue_job_chain_later: true, uploaded_file_ids: [101, 202], bypass_fedora: false )

        subject.create_content("a file", "original", uploaded_file_ids: [101, 202])
        expect(subject.file_set.label).to eq "Fabulous Label"
        expect(subject.file_set.title).to eq "Grand Title"
      end
    end


    context "when file_set.save is true and from_url is true" do

      context "when continue_job_chain_later is true" do
        fileSet = OpenStruct.new(label: "Good Label", title: "Acceptable Title", parent: "Parental", save: true)
        builtFile = MockFileActor.new

        subject { described_class.new(fileSet, "the user") }

        before {
          allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "file=a file", "json string", "relation=original", "from_url=true",
                                                                       "continue_job_chain_later=true", "uploaded_file_ids=[101, 202]", "bypass_fedora=false", ""]
          allow(subject).to receive(:remove_work_id_from_label).with(fileSet)
          allow(subject).to receive(:wrapper!).with( file: "a file", relation: "original" ).and_return "io wrapper"

          allow(subject).to receive(:build_file_actor).with("original").and_return builtFile

          allow(VisibilityCopyJob).to receive(:perform_later).with("Parental")
          allow(InheritPermissionsJob).to receive(:perform_later).with("Parental")
        }
        it "calls perform later functions" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "file=a file", "json string", "relation=original", "from_url=true",
                                                                        "continue_job_chain_later=true", "uploaded_file_ids=[101, 202]", "bypass_fedora=false", ""]
          expect(subject).not_to receive(:label_for)
          expect(subject).to receive(:remove_work_id_from_label).with(fileSet)
          expect(subject).to receive(:wrapper!).with( file: "a file", relation: "original" )
          expect(subject).to receive(:build_file_actor).with("original")
          expect(builtFile).to receive(:ingest_file).with("io wrapper", continue_job_chain_later: true, bypass_fedora: false)
          expect(VisibilityCopyJob).to receive(:perform_later).with("Parental")
          expect(InheritPermissionsJob).to receive(:perform_later).with("Parental")

          expect(VisibilityCopyJob).not_to receive(:perform_now)
          expect(InheritPermissionsJob).not_to receive(:perform_now)

          subject.create_content("a file", "original", from_url: true, uploaded_file_ids: [101, 202])
          expect(subject.file_set.label).to eq "Good Label"
          expect(subject.file_set.title).to eq "Acceptable Title"
        end
      end

      context "when continue_job_chain_later is false" do
        doc_set = OpenStruct.new(label: "OK Label", title: "Absent Title", parent: "Parental", save: true)
        built_file = MockFileActor.new

        subject { described_class.new(doc_set, "the user") }

        before {
          allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "file=a file", "json string", "relation=original", "from_url=true",
                                                                       "continue_job_chain_later=false", "uploaded_file_ids=[101, 202]", "bypass_fedora=false", ""]
          allow(subject).to receive(:remove_work_id_from_label).with(doc_set)
          allow(subject).to receive(:wrapper!).with( file: "a file", relation: "original" ).and_return "io wrapper"

          allow(subject).to receive(:build_file_actor).with("original").and_return built_file

          allow(VisibilityCopyJob).to receive(:perform_now).with("Parental")
          allow(InheritPermissionsJob).to receive(:perform_now).with("Parental")
        }
        it "calls perform now functions" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "file=a file", "json string", "relation=original", "from_url=true",
                                                                        "continue_job_chain_later=false", "uploaded_file_ids=[101, 202]", "bypass_fedora=false", ""]
          expect(subject).not_to receive(:label_for)
          expect(subject).to receive(:remove_work_id_from_label).with(doc_set)
          expect(subject).to receive(:wrapper!).with( file: "a file", relation: "original" )
          expect(subject).to receive(:build_file_actor).with("original")
          expect(built_file).to receive(:ingest_file).with("io wrapper", continue_job_chain_later: false, bypass_fedora: false)
          expect(VisibilityCopyJob).to receive(:perform_now).with("Parental")
          expect(InheritPermissionsJob).to receive(:perform_now).with("Parental")

          expect(VisibilityCopyJob).not_to receive(:perform_later)
          expect(InheritPermissionsJob).not_to receive(:perform_later)

          subject.create_content("a file", "original", from_url: true, continue_job_chain_later: false, uploaded_file_ids: [101, 202])
          expect(subject.file_set.label).to eq "OK Label"
          expect(subject.file_set.title).to eq "Absent Title"
        end
      end
    end
  end


  describe "#update_content" do
    fileset = MockFileSet.new("working file set", "controversial publication", "recently")
    subject { described_class.new(fileset,"admin user") }

    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "user=admin user", "file_set.id=working file set", "file=large file",
                                                                   "relation=distant" ]

      allow(Hyrax::TimeService).to receive(:time_in_utc).and_return "it's utc time"

      allow(subject).to receive(:wrapper!).with(file: "large file", relation: "distant").and_return "wrapped!"
      allow(IngestJob).to receive(:perform_later).with("wrapped!", notification: true)
    }

    it "sets current version to latest version" do
      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "user=admin user", "file_set.id=working file set", "file=large file",
                                                                    "relation=distant" ]
      expect(fileset).to receive(:provenance_update_version).with(current_user: "admin user",
                                                                  event_note: "update_content",
                                                                  new_create_date: '',
                                                                  new_revision_id: '',
                                                                  prior_create_date: "recently",
                                                                  prior_revision_id: "controversial publication",
                                                                  revision_id: '')
      expect(fileset).to receive(:date_modified=).with("it's utc time")
      expect(fileset).to receive(:save)
      expect(fileset).to receive(:reload)

      expect(subject).to receive(:wrapper!).with(file: "large file", relation: "distant")
      expect(IngestJob).to receive(:perform_later).with("wrapped!", notification: true)

      subject.update_content("large file", "distant")
    end
  end


  describe "#create_metadata" do
    fileset = MockFileSet.new("set of files", "popular article", "sometime")
    user = OpenStruct.new(user_key: 'top user')
    subject { described_class.new(fileset, user) }

    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(subject).to receive(:depositor_id).with(user).and_return "depositor id"
      allow(Hyrax::TimeService).to receive(:time_in_utc).and_return "it's that time again"
    }

    context "when argument given is not a block and assign_visibility returns false" do
      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "file_set_params={\"params\"=>\"file set\"}" ]
        allow(subject).to receive(:assign_visibility?).with({"params" => "file set"}).and_return false
      }
      it "returns nil" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "file_set_params={\"params\"=>\"file set\"}" ]
        expect(fileset).to receive(:depositor=).with("depositor id")
        expect(fileset).to receive(:date_uploaded=).with("it's that time again")
        expect(fileset).to receive(:date_modified=).with("it's that time again")
        expect(fileset).to receive(:creator=).with(["top user"])
        expect(subject).to receive(:assign_visibility?).with({"params" => "file set"})

        expect(Hyrax::Actors::Environment).not_to receive(:new)
        expect(Hyrax::CurationConcern.file_set_create_actor).not_to receive(:create)

        expect(subject.create_metadata({"params" => "file set"})).to be_blank
      end
    end

    context "when argument given is a block and assign_visibility returns true" do
      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "file_set_params={}" ]
        allow(subject).to receive(:ability).and_return 'ability'
        allow(subject).to receive(:assign_visibility?).and_return true
        allow(subject).to receive(:ability).and_return 'ability'
        allow(Hyrax::Actors::Environment).to receive(:new).with(fileset, "ability", {}).and_return "test environment"
        allow(Hyrax::CurationConcern.file_set_create_actor).to receive(:create).with("test environment")
      }
      it "calls CurationConcern.file_set_create_actor.create and yields block with file_set" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "file_set_params={}" ]
        expect(fileset).to receive(:depositor=).with("depositor id")
        expect(fileset).to receive(:date_uploaded=).with("it's that time again")
        expect(fileset).to receive(:date_modified=).with("it's that time again")
        expect(fileset).to receive(:creator=).with(["top user"])

        expect(subject).to receive(:assign_visibility?)
        expect(Hyrax::CurationConcern.file_set_create_actor).to receive(:create).with("test environment")
        expect(subject.create_metadata do |param| "#{param.id} for #{param.label}" end).to eq "set of files for popular article"
      end
    end
  end


  describe "#attach_to_work" do
    fileset = MockFileSet.new("boxed set", "published thesis", "in the distant past")
    user = OpenStruct.new(user_key: 'this user')
    work = MockWork.new("work id")

    subject { described_class.new(fileset, user) }

    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "work.id=work id", "file_set_params={\"params\"=>\"file set\"}" ]
    }
    context "when Exception does not occur" do
      before {
        allow(subject).to receive(:acquire_lock_for).with "work id"
      }
      it "calls bold_debug and acquires lock" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "work.id=work id", "file_set_params={\"params\"=>\"file set\"}" ]
        expect(subject).to receive(:acquire_lock_for).with "work id"
        subject.attach_file_to_work(work, {"params" => "file set"}, uploaded_file_id: "uploaded file id")
      end

      it "updates and saves work and calls UploadHelper.log inside lock" do
        skip "Add a test"
      end
    end

    context "when Exception occurs" do
      before {
        allow(subject).to receive(:acquire_lock_for).with("work id").and_raise(Exception, "Exception Message")
        allow(Rails.logger).to receive(:error)
        allow(Deepblue::LoggingHelper).to receive(:bold_debug)
        allow(Deepblue::UploadHelper).to receive(:log)
      }

      it "catches an exception and logs it" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "work.id=work id", "file_set_params={\"params\"=>\"file set\"}" ]
        expect(Rails.logger).to receive(:error)
        expect(Deepblue::LoggingHelper).to receive(:bold_debug)
        expect(Deepblue::UploadHelper).to receive(:log)

        subject.attach_file_to_work(work, {"params" => "file set"}, uploaded_file_id: "uploaded file id")
      end
    end
  end


  describe "#revert_content" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "revision_id=X555", "relation=original_file" ]
    }

    context "when revert_to with revision_id returns false" do
      before{
        allow(subject).to receive(:build_file_actor).with(:original_file).and_return MockBuildFileActor.new(false)
      }

      it "returns false" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "revision_id=X555", "relation=original_file" ]
        expect(Hyrax.config.callback).not_to receive(:run)

        expect(subject.revert_content("X555")).to eq false
      end
    end

    context "when revert_to with revision_id returns true" do
      before{
        allow(subject).to receive(:build_file_actor).with(:original_file).and_return MockBuildFileActor.new(true)
        allow(Hyrax.config.callback).to receive(:run).with(:after_revert_content, "file set", "active user", "X555")
      }

      it "calls Hyrax.config.callback.run and returns true" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "revision_id=X555", "relation=original_file" ]
        expect(subject).to receive(:build_file_actor).with(:original_file)
        expect(Hyrax.config.callback).to receive(:run).with(:after_revert_content, "file set", "active user", "X555")

        expect(subject.revert_content("X555")).to eq true
      end
    end

    context "when an Exception occurs" do
      before {
        allow(subject).to receive(:build_file_actor).with(:original_file).and_return raise_exception
      }

      it "logs the error" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "revision_id=Z666", "relation=original_file" ]
        expect(Rails.logger).to receive(:error)
        expect(Deepblue::LoggingHelper).to receive(:bold_debug)

        expect(subject.revert_content("Z666")).to eq false
      end

      skip "Add a test that includes error and bold_debug parameters checks"
    end
  end


  describe "#update_metadata" do
    filesetmock = MockFileSet.new("library", "entertaining review", "on a summer\'s day")
    usermock = OpenStruct.new(user_key: 'responsible user')
    subject { described_class.new(filesetmock, usermock) }

    before {
      allow(subject).to receive(:ability).and_return 'ability'
      allow(Hyrax::Actors::Environment).to receive(:new).with(filesetmock, "ability", "attributes").and_return "testing 123"
      allow(Hyrax::CurationConcern.file_set_update_actor).to receive(:update).with("testing 123")
    }
    it "calls CurationConcern.file_set_update_actor.update" do
      expect(Hyrax::Actors::Environment).to receive(:new).with(filesetmock, "ability", "attributes")
      expect(Hyrax::CurationConcern.file_set_update_actor).to receive(:update).with("testing 123")

      subject.update_metadata("attributes")
    end
  end


  describe "#destroy" do
    file_set_mock = MockFileSet.new("zeppelin library", "over the rainbow", "in a dream")

    subject { described_class.new(file_set_mock, "responsible user") }

    before {
      allow(subject).to receive(:unlink_from_work)
      allow(Hyrax.config.callback).to receive(:run).with(:after_destroy, "zeppelin library", 'responsible user')
    }

    it do
      expect(subject).to receive(:unlink_from_work)
      expect(file_set_mock).to receive(:destroy)
      expect(Hyrax.config.callback).to receive(:run).with(:after_destroy, "zeppelin library", 'responsible user')
      subject.destroy
    end
  end


  describe "#file_actor_class" do
    it "file_actor_class is an instance of Hyrax::Actors::FileActor" do
      Hyrax::Actors::FileSetActor.new("file set", "user").file_actor_class.instance_of? Hyrax::Actors::FileActor
    end
  end


  describe "#ability" do
    context "when instance variable has a value" do
      before {
        subject.instance_variable_set(:@ability, "very able")
      }
      it "returns value of instance variable" do
        expect(::Ability).not_to receive(:new)
        expect(subject.send(:ability)).to eq "very able"
      end
    end

    context "when instance variable does not have a value" do
      before {
        allow(::Ability).to receive(:new).with("active user").and_return "activity level high"
      }
      it "sets instance variable and returns value" do
        expect(subject.send(:ability)).to eq "activity level high"

        subject.instance_variable_get(:@ability) == "activity level high"
      end
    end
  end


  describe "#build_file_actor" do
    before {
      allow(subject.file_actor_class).to receive(:new).with("file set", "relation", "active user")
    }
    it "calls file_actor_class.new" do
      expect(subject.file_actor_class).to receive(:new).with("file set", "relation", "active user")
      subject.send(:build_file_actor, "relation")
    end
  end


  describe "#wrapper!" do
    before {
      allow(JobIoWrapper).to receive(:create_with_varied_file_handling!).with(user: "active user",
                                                      file: "file",
                                                      relation: "relation",
                                                      file_set: "file set")
    }
    it "calls JobIoWrapper.create_with_varied_file_handling!" do
      expect(JobIoWrapper).to receive(:create_with_varied_file_handling!).with(user: "active user",
                                                                              file: "file",
                                                                              relation: "relation",
                                                                              file_set: "file set")
      subject.send(:wrapper!, file:"file", relation:"relation")
    end
  end


  describe "#label_for" do
    context "when bypass_fedora contains external_filename" do
      it "returns external_filename" do
        expect(subject.send(:label_for, "file", bypass_fedora: "bypass/fedora")).to eq "fedora"
      end
    end

    context "when file is an UploadedFile" do

      context "when file uploader has a filename" do
        it "returns filename" do
          expect(subject.send(:label_for, MockUploadedFile.new("Uploader File"))).to eq "Uploader File"
        end
      end

      context "when file uploader does not have a filename" do
        it "returns file url path" do
          expect(subject.send(:label_for, MockUploadedFile.new(""))).to eq "index.html"
        end
      end
    end

    context "when file responds to function original_name" do
      it "returns original name" do
        expect(subject.send(:label_for, MockFileUpload.new)).to eq "original name"
      end
    end

    context "when import_url present" do
      file_set = OpenStruct.new(import_url: "http://example.com/main.htm")
      subject { described_class.new(file_set, "newish user") }

      it "returns import url path" do
        expect(subject.send(:label_for, "file")).to eq "main.htm"
      end
    end

    context "when import_url is not present" do
      file_set = OpenStruct.new(import_url: nil)
      subject { described_class.new(file_set, "ancient user") }

      before {
        allow(File).to receive(:basename).with("file").and_return "file basename"
      }
      it "returns file basename" do
        expect(subject.send(:label_for, "file")).to eq "file basename"
      end
    end
  end


  describe "#remove_work_id_from_label" do
    context "when file_set.parent.id is present" do
      it "assigns label with file_set.parent.id removed" do
        file_set_mock = MockFileSet.new("opale", "opale_scent", "under the sea")
        expect(subject.send(:remove_work_id_from_label, file_set_mock)).to eq "scent"
      end
    end

    context "when file_set.parent.id is blank" do
      it "returns nil" do
        file_set_mock = MockFileSet.new(nil, "opalescent", "under the sea")
        expect(subject.send(:remove_work_id_from_label, file_set_mock)).to be_blank
      end
    end
  end


  describe "#assign_visibility?" do
    visibility_keys = %w[visibility embargo_release_date lease_expiration_date]

    visibility_keys.each do |key|
      context "when argument has relevant key #{key}" do  #loop it
        it "returns true" do
          expect(subject.send(:assign_visibility?, { "#{key}" => "yes" })).to eq true
        end
      end
    end

    context "when argument does not have relevant keys" do
      it "returns false" do
        expect(subject.send(:assign_visibility?, Hash.new(create_date: "yesterday", update_date: "today"))).to eq false
      end
    end

    context "when argument does not have keys" do
      it "returns false" do
        expect(subject.send(:assign_visibility?)).to eq false
      end
    end
  end


  describe "#depositor_id" do
    context "when argument has a user_key method" do
      it "returns result of user_key method" do
        expect(subject.send(:depositor_id, MockDepositor.new("user key"))).to eq "user key"
      end
    end

    context "when argument does not have method named user_key" do
      it "returns argument" do
        expect(subject.send(:depositor_id, "depositor")).to eq "depositor"
      end
    end
  end


  describe "#unlink_from_work" do

    context "when file_set.parent is not nil but file_set.id is not relevant" do
      parent = MockLinkWork.new
      file_set = OpenStruct.new(parent: parent, id: "parent id")
      subject { described_class.new(file_set, "frequent user") }

      it "returns nil" do
        expect(parent).to receive(:total_file_size_subtract_file_set!).with file_set
        expect(parent).not_to receive(:save!)

        expect(subject.send(:unlink_from_work)).to be_blank
      end
    end

    context "when file_set.id is equal to thumbnail_id" do
      parent = MockLinkWork.new
      file_set = OpenStruct.new(parent: parent, id: "thumbnail id")
      subject { described_class.new(file_set, "recent user") }

      it "sets thumbnail to nil, removes file_set.id from rendering_ids, and calls save! on work" do
        expect(parent).to receive(:total_file_size_subtract_file_set!).with file_set
        expect(parent).to receive(:save!)

        subject.send(:unlink_from_work)
        expect(parent.thumbnail).to be_blank
        expect(parent.representative).to eq "representative"
        expect(parent.rendering_ids).to eq ["rendering id", "representative id"]
      end
    end

    context "when file_set.id is equal to representative_id" do
      parent = MockLinkWork.new
      file_set = OpenStruct.new(parent: parent, id: "representative id")
      subject { described_class.new(file_set, "popular user") }

      it "sets representative to nil, removes file_set.id from rendering_ids, and calls save! on work" do
        expect(parent).to receive(:total_file_size_subtract_file_set!).with file_set
        expect(parent).to receive(:save!)

        subject.send(:unlink_from_work)
        expect(parent.thumbnail).to eq "thumbnail"
        expect(parent.representative).to be_blank
        expect(parent.rendering_ids).to eq ["rendering id", "thumbnail id"]
      end
    end

    context "when file_set.id is in rendering_ids" do
      parent = MockLinkWork.new
      file_set = OpenStruct.new(parent: parent, id: "rendering id")
      subject { described_class.new(file_set, "absent user") }

      it "removes file_set.id from rendering_ids, and calls save! on work" do
        expect(parent).to receive(:total_file_size_subtract_file_set!).with file_set
        expect(parent).to receive(:save!)

        subject.send(:unlink_from_work)
        expect(parent.thumbnail).to eq "thumbnail"
        expect(parent.representative).to eq "representative"
        expect(parent.rendering_ids).to eq ["thumbnail id", "representative id"]
      end
    end
  end

end
