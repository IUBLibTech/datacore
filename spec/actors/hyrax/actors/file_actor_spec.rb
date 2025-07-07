require 'rails_helper'

class MockFile
  def initialize(path)
    @filepath =  OpenStruct.new(path: path)
  end

  def uploader
    @filepath
  end
end

class MockIO
  def initialize(path)
    @file = MockFile.new(path)
    # @path = path
  end

  def uploaded_file
    @file
  end
end

class MockRepo
  def initialize(id)
    @id = id
  end

  def id
    @id
  end

  def restore_version(revision_id)
  end
end

class MockFileSet
  def initialize(id, save, label, created)
    @id = id
    @save = save
    @label = label
    @created = created
  end

  def id
    @id
  end

  def save
    @save
  end

  def latest_version
     OpenStruct.new(label:@label, created: @created)
  end

  def provenance_update_version(current_user:, event_note:, new_create_date:, new_revision_id:, prior_create_date:, prior_revision_id:, revision_id:)
  end
end



RSpec.describe Hyrax::Actors::FileActor do

  describe "#initialize" do
    it "creates instance variables" do
      actor_file = Hyrax::Actors::FileActor.new("file set", "relation", "user")

      actor_file.instance_variable_get(:@file_set) == "file set"
      actor_file.instance_variable_get(:@relation) == :relation
      actor_file.instance_variable_get(:@user) == "user"
    end
  end


  describe "#ingest_file" do
    before {
      allow(::Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(::Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
    }

    context "when bypass_fedora and file_set.save is negative" do
      fileset = OpenStruct.new(save: false)
      subject { described_class.new(fileset, "relational", "the user") }

      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "io=io)", "user=the user", "continue_job_chain=true", "continue_job_chain_later=true",
                                                                     "delete_input_file=true", "uploaded_file_ids=[11, 22, 33]", "bypass_fedora=true", ""])
        allow(Hydra::Works::AddExternalFileToFileSet).to receive(:call).with(fileset, true, :relational, versioning: false)
      }
      it "logs arguments and calls AddExternalFileToFileSet" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "io=io)", "user=the user", "continue_job_chain=true", "continue_job_chain_later=true",
                                                                      "delete_input_file=true", "uploaded_file_ids=[11, 22, 33]", "bypass_fedora=true", ""])
        expect(Hydra::Works::AddExternalFileToFileSet).to receive(:call).with(fileset, true, :relational, versioning: false)

        expect(subject.ingest_file("io", current_user: "the user", uploaded_file_ids: [11,22,33], bypass_fedora: true)).to eq false
      end
    end


    context "when not bypass_fedora" do
      fileset = OpenStruct.new(save: true)
      mockRepo = MockRepo.new(id: "repo")

      subject { described_class.new(fileset, "relational", "the user") }

      before {
        allow(subject).to receive(:related_file).and_return mockRepo
        allow(Hyrax::VersioningService).to receive(:create).with(mockRepo, "user")
     }

      context "when continue_job_chain_later is true" do
        io = MockIO.new("one true path")

        before {
          allow(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "io=#{io})", "user=the user", "continue_job_chain=true", "continue_job_chain_later=true",
                                                                       "delete_input_file=true", "uploaded_file_ids=[11, 22, 33]", "bypass_fedora=false", ""])
          allow(Hydra::Works::AddFileToFileSet).to receive(:call).with(fileset, "one true path", :relational, versioning: false)

          allow(CharacterizeJob).to receive(:perform_later).with(fileset, {:id=>"repo"}, "one true path", current_user: "the user", uploaded_file_ids: [11,22,33])
        }
        it "logs arguments and calls AddFileToFileSet" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "io=#{io})", "user=the user", "continue_job_chain=true", "continue_job_chain_later=true",
                                                                        "delete_input_file=true", "uploaded_file_ids=[11, 22, 33]", "bypass_fedora=false", ""])
          expect(Hydra::Works::AddFileToFileSet).to receive(:call).with(fileset, io, :relational, versioning: false)
          expect(Hyrax::VersioningService).to receive(:create).with(mockRepo, "the user")
          expect(CharacterizeJob).to receive(:perform_later).with(fileset, {:id=>"repo"}, "one true path", current_user: "the user", uploaded_file_ids: [11,22,33])
          subject.ingest_file(io, current_user: "the user", uploaded_file_ids: [11,22,33])
        end
      end


      context "when continue_job_chain_later is false" do
        io = MockIO.new("path finder")

        before {
          allow(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "io=#{io})", "user=the user", "continue_job_chain=true", "continue_job_chain_later=false",
                                                                       "delete_input_file=true", "uploaded_file_ids=[11, 22, 33]", "bypass_fedora=false", ""])
          allow(Hydra::Works::AddFileToFileSet).to receive(:call).with(fileset, io, :relational, versioning: false)
          allow(CharacterizeJob).to receive(:perform_now).with(fileset, {:id=>"repo"}, "path finder", continue_job_chain: true, continue_job_chain_later:false, current_user: "user",
                                                               delete_input_file: true, uploaded_file_ids: [11,22,33])
        }
        it "logs arguments and calls AddFileToFileSet" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "io=#{io})", "user=the user", "continue_job_chain=true", "continue_job_chain_later=false",
                                                                        "delete_input_file=true", "uploaded_file_ids=[11, 22, 33]", "bypass_fedora=false", ""])
          expect(Hydra::Works::AddFileToFileSet).to receive(:call).with(fileset, io, :relational, versioning: false)
          expect(Hyrax::VersioningService).to receive(:create).with(mockRepo, "the user")
          expect(CharacterizeJob).to receive(:perform_now).with(fileset, {:id=>"repo"}, "path finder", continue_job_chain: true, continue_job_chain_later:false,
                                                                current_user: "the user", delete_input_file: true, uploaded_file_ids: [11,22,33])
          subject.ingest_file(io, continue_job_chain_later: false, current_user: "the user", uploaded_file_ids: [11,22,33])
        end
      end
    end
  end


  describe "#revert_to" do
    repo = MockRepo.new(id: "repo")

    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"

      allow(subject).to receive(:related_file).and_return repo
    }

    context "when file_set.save is negative" do
      fileset = MockFileSet.new("a great file", false, "brand new release", "hot off the presses")
      subject { described_class.new(fileset, "relational", "the user") }

      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "user=the user", "file_set.id=a great file", "relation=relational",
                                                                     "revision_id=revise revise revise" ])
      }
      it "returns false" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "user=the user", "file_set.id=a great file", "relation=relational",
                                                                     "revision_id=revise revise revise" ])
        expect(repo).to receive(:restore_version).with("revise revise revise")
        expect(subject.revert_to("revise revise revise")).to eq false
      end
    end

    
    context "when file_set.save is positive" do
      file_set = MockFileSet.new("a classic file", true, "oldie but goodie", "long ago")
      subject { described_class.new(file_set, "relational", "the user") }

      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "user=the user", "file_set.id=a classic file", "relation=relational",
                                                                     "revision_id=publish or perish" ])
        allow(Hyrax::VersioningService).to receive(:create).with(repo, "the user")
        allow(CharacterizeJob).to receive(:perform_later).with(file_set, "repo", current_user: "the user")
      }
      it "returns false" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "user=the user", "file_set.id=a classic file", "relation=relational",
                                                                      "revision_id=publish or perish" ])
        expect(repo).to receive(:restore_version).with("publish or perish")
        expect(file_set).to receive(:provenance_update_version).with(current_user: "the user", event_note: "revert_to", new_create_date: "long ago",
                                                                     new_revision_id: "oldie but goodie", prior_create_date: "long ago", prior_revision_id: "oldie but goodie",
                                                                     revision_id: "publish or perish")
        expect(Hyrax::VersioningService).to receive(:create).with(repo, "the user")
        expect(CharacterizeJob).to receive(:perform_later).with(file_set, {:id=>"repo"}, current_user: "the user")

        subject.revert_to("publish or perish")
      end
    end
  end


  describe "#==" do
    context "when argument is not a self.class" do
      subject { described_class.new(double, "relativity", double) }

      it "returns false" do
        expect(subject.== "plot twist").to eq false
      end
    end

    context "when argument is a self.class" do
      context "when values are equal" do
        it "returns true" do
          skip "Add a test"
        end
      end

      context "when values are not equal" do
        it "returns false" do
          skip "Add a test"
        end
      end
    end

  end

end
