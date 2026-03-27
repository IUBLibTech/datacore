require 'tasks/new_content_service'

class MockCreatedUser

  def save(validate: false)
  end
end

class MockMeasurement

  def initialize (label = "", real_seconds = 0)
    @label = label
    @real_seconds = real_seconds
  end

  def label
    @label
  end

  def to_str
    @label
  end

  def + obj
    "#{@label}#{obj.label}"
  end

  def format message
    message
  end

  def real
    @real_seconds
  end

  def instance_variable_set( label, id )
  end
end

class MockConcernCreation

  def provenance_workflow( current_user:,
                           workflow_name:,
                           workflow_state:,
                           workflow_state_prior: '' )
  end

  def provenance_migrate( current_user:,
                          migrate_direction: 'import')
  end

  def provenance_ingest( current_user:,
                         calling_class:,
                         ingest_id:,
                         ingester:,
                         ingest_timestamp:)
  end

  def provenance_fixity_check (current_user:,
                               fixity_check_status:,
                               fixity_check_note:)
  end
end

class MockParent

  def provenance_child_add (current_user:,
                            child_id:,
                            ingest_id:,
                            ingester:,
                            ingest_timestamp:)
  end
end

class MockLogger

  def info message
  end

  def error message
  end
end

class PathnameMock
  def initialize(path)
    @path = path
  end

  def join(string)
    "#{@path}#{string}"
  end

  def to_s
    @path.to_s
  end

  def realdirpath
  end
end

class MockDoiMint

  def initialize(doi)
    @doi = doi
  end

  def doi_mint ( current_user: , event_note: 'NewContentService', job_delay: 60 )
  end

  def doi
    @doi
  end

  def doi=(doi)
  end

  def save!
  end

  def reload
  end
end

class MockFileSetWork

  def initialize id = "XYZ890"
    @id = id
    @ordered_members = []
  end

  def add_member(member)
    @ordered_members << member
  end

  def id
    @id
  end

  def reload
  end

  def ordered_members
    @ordered_members
  end

  def total_file_size_add_file_set file_set
  end

  def representative_id
    @representative_id
  end

  def representative_id= id
    @representative_id = id
  end

  def representative= file_set
  end

  def thumbnail= file_set
  end

  def thumbnail_id
    @thumbnail_id
  end

  def thumbnail_id= thumbnail_id
    @thumbnail_id = thumbnail_id
  end

  def save!
  end
end

class MockCollectionWork

  def initialize collection_ids
    @member_of_collections = []
    @member_of_collection_ids = collection_ids
  end

  def member_of_collection_ids
    @member_of_collection_ids
  end

  def add_member(member)
    @member_of_collections << member
  end

  def member_of_collections
    @member_of_collections
  end

  def save!
  end

  def id
    "work id"
  end
end

class MockZipFiles
  def zip filenames, file_ids
      [["path 1", "filename 1", "file ids 1"],["path 2", "filename 2", "file ids 2"]]
  end
end

class MockAdminSet

  def select
  end
end

class MockVisibilityWork

  def initialize id
    @id = id
  end

  def id
    @id
  end

  def visibility= visibility
    @visibility = visibility
  end

  def visibility
    @visibility
  end

  def admin_set= admin_set
  end

  def active_workflow
    "active workflow"
  end

  def to_global_id
    @id.to_i * 1000
  end

  def reload
  end

  def save!
  end
end

class MockWorkflow

  def update!(workflow_state_id:, workflow_state:)
  end
end

class MockBuild
  def apply_depositor_metadata(depositor)
  end

  def save!
  end

  def reload
  end
end

class MockBuildWork < MockBuild
  def owner=(depositor)
  end

  def update(admin_set:)
  end
end

class MockBuildCollection < MockBuild

  def collection_type= collection_type
  end

  def visibility= visibility
  end
end

class MockBuildFileSet < MockBuild

  def label= label
  end

  def date_uploaded= date_uploaded
  end

  def date_modified= date_modified
  end

  def date_created= date_created
  end
end


class MockUpdateFileSet
  def initialize(original_name, visibility)
    @original_name_value = original_name
    @visibility = visibility
  end

  def original_name_value
    @original_name_value
  end

  def visibility
    @visibility
  end

  def save!
  end
end

RSpec.describe Deepblue::NewContentService do

  subject { Deepblue::NewContentService.new(path_to_yaml_file: "yaml path", cfg_hash: "cfg hash", base_path: "base path", options: {"verbose" => false}) }

  describe 'constants' do
    it do
      expect( described_class::DEFAULT_DATA_SET_ADMIN_SET_NAME ).to eq "DataSet Admin Set"
      expect( described_class::DEFAULT_DIFF_ATTRS_SKIP ).to eq [ :creator_ordered,
                                                                 :curation_notes_admin_ordered,
                                                                 :curation_notes_user_ordered,
                                                                 :date_created, :date_modified,
                                                                 :description_ordered,
                                                                 :keyword_ordered, :language_ordered,
                                                                 :referenced_by_ordered, :title_ordered,
                                                                 :visibility ]
      expect( described_class::DEFAULT_DIFF_ATTRS_SKIP_IF_BLANK ).to eq [ :creator_ordered,
                                                                          :curation_notes_admin,
                                                                          :curation_notes_admin_ordered,
                                                                          :curation_notes_user,
                                                                          :curation_notes_user_ordered,
                                                                          :checksum_algorithm, :checksum_value,
                                                                          :date_published,
                                                                          :description_ordered,
                                                                          :doi,
                                                                          :fundedby_other,
                                                                          :keyword_ordered, :language_ordered,
                                                                          :prior_identifier,
                                                                          :referenced_by_ordered, :title_ordered ]
      expect( described_class::DEFAULT_DIFF_USER_ATTRS_SKIP ).to eq [ :created_at,
                                                                      :current_sign_in_at, :current_sign_in_ip,
                                                                      :email, :encrypted_password,
                                                                      :id,
                                                                      :updated_at ]
      expect( described_class::DEFAULT_DIFF_COLLECTIONS_RECURSE ).to eq false
      expect( described_class::DEFAULT_UPDATE_ADD_FILES ).to eq true
      expect( described_class::DEFAULT_UPDATE_ATTRS_SKIP ).to eq [ :creator_ordered,
                                                                   :curation_notes_admin_ordered,
                                                                   :curation_notes_user_ordered,
                                                                   :date_created, :date_modified, :date_uploaded,
                                                                   :edit_users,
                                                                   :keyword_ordered, :language_ordered,
                                                                   :original_name,
                                                                   :referenced_by_ordered, :title_ordered,
                                                                   :visibility ]
      expect( described_class::DEFAULT_UPDATE_ATTRS_SKIP_IF_BLANK ).to eq [ :creator_ordered,
                                                                            :curation_notes_admin,
                                                                            :curation_notes_admin_ordered,
                                                                            :curation_notes_user,
                                                                            :curation_notes_user_ordered,
                                                                            :checksum_algorithm, :checksum_value,
                                                                            :description_ordered, :doi,
                                                                            :fundedby_other, :keyword_ordered,
                                                                            :language_ordered,
                                                                            :prior_identifier,
                                                                            :referenced_by_ordered, :title_ordered ]
      expect( described_class::DEFAULT_UPDATE_COLLECTIONS_RECURSE ).to eq false
      expect( described_class::DEFAULT_UPDATE_DELETE_FILES ).to eq true
      expect( described_class::DEFAULT_UPDATE_USER_ATTRS_SKIP ).to eq [ :created_at,
                                                                        :current_sign_in_at, :current_sign_in_ip,
                                                                        :email, :encrypted_password,
                                                                        :id,
                                                                        :updated_at ]
      expect( described_class::DEFAULT_USER_CREATE ).to eq true
      expect( described_class::DEFAULT_VERBOSE ).to eq true
      expect( described_class::DIFF_DATES ).to eq false
      expect( described_class::DOI_MINT_NOW ).to eq 'mint_now'
      expect( described_class::MODE_APPEND ).to eq 'append'
      expect( described_class::MODE_BUILD ).to eq 'build'
      expect( described_class::MODE_DIFF ).to eq 'diff'
      expect( described_class::MODE_MIGRATE ).to eq 'migrate'
      expect( described_class::MODE_UPDATE ).to eq 'update'
      expect( described_class::DEFAULT_UPDATE_BUILD_MODE ).to eq described_class::MODE_MIGRATE
      expect( described_class::SOURCE_DBDv1 ).to eq 'DBDv1' # rubocop:disable Style/ConstantName
      expect( described_class::SOURCE_DBDv2 ).to eq 'DBDv2' # rubocop:disable Style/ConstantName
      expect( described_class::STOP_NEW_CONTENT_SERVICE_FILE_NAME ).to eq 'stop_umrdr_new_content'
    end
  end

  describe "#initialize" do
    skip "Add a test"
  end


  describe "#load_yaml_file" do
    context "when file exists" do
      before {
        allow(File).to receive(:exist?).with("yaml file").and_return true
        allow(YAML).to receive(:load_file).with("yaml file").and_return "cfg hash"
      }
      it "loads and returns file" do
        expect(Deepblue::NewContentService.load_yaml_file("yaml file")).to eq "cfg hash"
      end
    end

    context "when file does not exist" do
      before {
        allow(File).to receive(:exist?).with("yaml file").and_return false
      }
      it "logs error and returns nil" do
        expect(Deepblue::NewContentService).to receive(:puts).with "yaml file not found: ' yaml file'"
        expect(Rails.logger).to receive(:error).with "yaml file not found: ' yaml file'"
        expect(Deepblue::NewContentService.load_yaml_file("yaml file")).to be_nil
      end
    end
  end


  describe "#run" do
    logger = MockLogger.new
    before {
      allow(subject).to receive(:logger).and_return logger
    }

    context "when the function runs successfully" do
      before {
        allow(subject).to receive(:validate_config)
      }
      it "calls validate_config and build_repo_contents" do
        subject.run
      end
    end

    content_service_errors = [{"name" => Deepblue::NewContentService::RestrictedVocabularyError, "message" => "restricted vocabulary"},
                              {"name" => Deepblue::NewContentService::TaskConfigError, "message" => "config task"},
                              {"name" => Deepblue::NewContentService::UserNotFoundError, "message" => "user not found"},
                              {"name" => Deepblue::NewContentService::VisibilityError, "message" => "visibility"},
                              {"name" => Deepblue::NewContentService::WorkNotFoundError, "message" => "work not found"},
                              {"name" => Exception, "message" => "error message"}]
    content_service_errors.each do |error|
      context "when a #{error['name']} occurs" do
        before {
          allow(subject).to receive(:validate_config).and_raise(error["name"], error["message"])
        }
        it "calls logger.error with error message" do
          if error["name"] != Exception
            expect(logger).to receive(:error).with error["message"]
          else
            expect(logger).to receive(:error).with(start_with("Exception: error message at ")) #anything
          end

          subject.run
        end
      end
    end

    after {
      expect(subject).to have_received(:validate_config)
    }
  end


  # protected methods

  describe "#comment_work" do
    context "when @verbose is false" do
      before {
        subject.instance_variable_set(:@verbose, false)
      }
      it "returns nil" do
        expect(subject).not_to receive(:log_msg)

        expect(subject.send(:comment_work, work_hash: "work hash")).to be_nil
      end
    end

    context "when @verbose is true" do
      before {
        subject.instance_variable_set(:@verbose, true)
        allow(subject).to receive(:mode).and_return "Mode"
      }

      hash_values = [{:comment => "I must comment", :total_file_count => nil, :total_file_size_human_readable => nil},
                     {:comment => nil, :total_file_count => "42", :total_file_size_human_readable => nil},
                     {:comment => nil, :total_file_count => nil, :total_file_size_human_readable => "7 MB"}]
      hash_values.each do |hash|
        context "when value is present in work_hash parameter" do
          before {
            allow(subject).to receive(:log_msg).with "Mode: #{hash[:comment]}"
            allow(subject).to receive(:log_msg).with "Mode: Total file count: #{hash[:total_file_count]}"
            allow(subject).to receive(:log_msg).with "Mode: Total file size: #{hash[:total_file_size_human_readable]}#"
          }
          it "logs hash values" do
            expect(subject).to receive(:log_msg).with "Mode: #{hash[:comment]}" if hash[:comment].present?
            expect(subject).to receive(:log_msg).with "Mode: Total file count: #{hash[:total_file_count]}" if hash[:total_file_count].present?
            expect(subject).to receive(:log_msg).with "Mode: Total file size: #{hash[:total_file_size_human_readable]}" if hash[:total_file_size_human_readable].present?

            subject.send(:comment_work, work_hash: hash)
          end
        end
      end
    end
  end


  describe "#continue_new_content_service" do
    context "when @stop_new_content_service evaluates to true" do
      before {
        subject.instance_variable_set(:@stop_new_content_service, true)
      }
      it "returns false" do
        subject.send(:continue_new_content_service)
      end
    end

    context "when @stop_new_content_service evaluates to false" do
      before {
        subject.instance_variable_set(:@stop_new_content_service, false)
      }

      instance_vars = ["@stop_new_content_service_file", "@stop_new_content_service_ppid_file"]
      instance_vars.each do |instance_var|
        context "when #{instance_var} exists" do
          before {
            subject.instance_variable_set(:"#{instance_var}", OpenStruct.new(exist?: true))
          }
          it "sets @stop_new_content_service to true and returns false" do
            expect(subject.send(:continue_new_content_service)).to eq false

            expect(subject.instance_variable_get(:@stop_new_content_service)).to eq true
          end
        end
      end

      instance_vars.each do |instance_var|
        context "when #{instance_var} does not exist" do
          before {
            subject.instance_variable_set(:"#{instance_var}", OpenStruct.new(exist?: false))
          }
          it "returns true" do
            expect(subject.send(:continue_new_content_service)).to eq true

            expect(subject.instance_variable_get(:@stop_new_content_service)).to eq false
          end
        end
      end
    end
  end


  describe "#add_file_set_to_work" do
    context "when file_set parent parameter is present and work parameter id field equals file_set parameter parent_id field" do
      it "returns nil" do
        expect(subject).not_to receive(:log_provenance_add_child)

        expect(subject.send(:add_file_set_to_work, work: OpenStruct.new(id: "ABC123"), file_set: OpenStruct.new(parent: "guardian", parent_id: "ABC123")))
          .to be_nil
      end
    end

    context "when work parameter id field NOT equal to file_set parameter parent_id field" do
      context "when file_set parent parameter is present and work parameter thumbnail field is present" do
        it "calls functions on work parameter" do
          file_set_work = MockFileSetWork.new
          file_set_work.thumbnail_id = "thumbnail id"
          file_set = OpenStruct.new(parent: "guardian", parent_id: "ABC123")

          expect(file_set_work).to receive(:reload)

          expect(subject).to receive(:log_provenance_add_child).with(parent: file_set_work, child: file_set)
          expect(file_set_work).to receive(:total_file_size_add_file_set).with file_set
          expect(file_set_work).to receive(:representative=).with(file_set)
          expect(file_set_work).not_to receive(:thumbnail=)
          expect(file_set_work).to receive(:save!)

          subject.send(:add_file_set_to_work, work: file_set_work, file_set: file_set)
          expect(file_set_work.ordered_members).to eq [file_set]
        end
      end

      context "when file_set parent parameter is blank and work parameter representative_id is present" do
        it "calls functions on work parameter" do
          file_set_work = MockFileSetWork.new
          file_set_work.representative_id = "rep id"
          file_set = OpenStruct.new(parent_id: "XYZ890")

          expect(file_set_work).to receive(:reload)

          expect(subject).to receive(:log_provenance_add_child).with(parent: file_set_work, child: file_set)
          expect(file_set_work).to receive(:total_file_size_add_file_set).with file_set
          expect(file_set_work).to receive(:thumbnail=).with(file_set)
          expect(file_set_work).not_to receive(:representative=)
          expect(file_set_work).to receive(:save!)

          subject.send(:add_file_set_to_work, work: file_set_work, file_set: file_set)
          expect(file_set_work.ordered_members).to eq [file_set]
        end
      end
    end
  end


  describe "add_file_sets_to_work" do
    context "when work_hash parameter includes file_set_ids" do
      work_hash = {:file_set_ids => "file set ids"}

      before {
        allow(subject).to receive(:add_file_sets_to_work_from_file_set_ids).with(work_hash: work_hash, work: "work").and_return "from file set ids"
      }
      it "calls add_file_sets_to_work_from_file_set_ids and returns results" do
        expect(subject).to receive(:add_file_sets_to_work_from_file_set_ids).with(work_hash: work_hash, work: "work")
        expect(subject).not_to receive(:add_file_sets_to_work_from_files)

        expect(subject.send(:add_file_sets_to_work, work_hash: work_hash, work: "work")).to eq "from file set ids"
      end
    end

    context "when work_hash parameter does NOT include file_set_ids" do
      work_hash = {:file_set_ids => ""}

      before {
        allow(subject).to receive(:add_file_sets_to_work_from_files).with(work_hash: work_hash, work: "work").and_return "from files"
      }
      it "calls add_file_sets_to_work_from_files and returns results" do
        expect(subject).not_to receive(:add_file_sets_to_work_from_file_set_ids)
        expect(subject).to receive(:add_file_sets_to_work_from_files).with(work_hash: work_hash, work: "work")

        expect(subject.send(:add_file_sets_to_work, work_hash: work_hash, work: "work")).to eq "from files"
      end
    end
  end


  describe "#add_file_sets_file_size" do
    context "when @verbose is false" do
      before {
        subject.instance_variable_set(:@verbose, false)
      }
      it "returns empty string" do
        expect(subject.send(:add_file_sets_file_size)).to be_blank
      end
    end

    context "when @verbose is true" do
      before {
        subject.instance_variable_set(:@verbose, true)
      }

      context "when parameters are blank" do
        it "returns empty string" do
          expect(subject.send(:add_file_sets_file_size)).to be_blank
        end
      end

      context "when file_set_hash parameter is present" do

        context "when value of file_size_human_readable in file_set_hash parameter is blank" do
          it "returns empty string" do
            expect(subject.send(:add_file_sets_file_size, file_set_hash: {:file_size_human_readable => nil})).to be_blank
          end
        end

        context "when value of file_size_human_readable in file_set_hash parameter is present" do
          it "returns size as a string" do
            expect(Deepblue::TaskHelper).not_to receive(:human_readable_size)

            expect(subject.send(:add_file_sets_file_size, file_set_hash: {:file_size_human_readable => "XXL"})).to eq " with size XXL"
          end
        end
      end

      context "when file_set_hash parameter is blank" do
        context "when path parameter is present" do
          context "when File does not exist" do
            before {
              allow(File).to receive(:exist?).with("file path").and_return false
            }
            it "returns empty string" do
              expect(File).not_to receive(:new).with("file path")

              expect(subject.send(:add_file_sets_file_size, path: "file path")).to be_blank
            end
          end

          context "when File exists" do
            before {
              allow(File).to receive(:exist?).with("file path").and_return true
              allow(File).to receive(:new).with("file path").and_return OpenStruct.new(size: "40")
              allow(Deepblue::TaskHelper).to receive(:human_readable_size).with("40").and_return "40 MB"
            }
            it "returns File size as string" do
              expect(File).to receive(:new).with("file path")
              expect(Deepblue::TaskHelper).to receive(:human_readable_size).with("40")

              expect(subject.send(:add_file_sets_file_size, path: "file path")).to eq " with size 40 MB"
            end
          end
        end

        after {
          expect(File).to have_received(:exist?).with("file path")
        }
      end
    end
  end


  describe "#add_file_sets_to_work_from_file_set_ids" do

    context "when continue_new_content_service returns true" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return true
      }
      context "when file set ids are present in work hash" do
        work = MockFileSetWork.new
        before {
          allow(subject).to receive(:mode).and_return "re-build"
          allow(subject).to receive(:add_file_sets_file_size).with(file_set_hash: "file 22").and_return "222 KB"
          allow(subject).to receive(:add_file_sets_file_size).with(file_set_hash: "file 33").and_return "3 MB"
          allow(subject).to receive(:build_file_set_from_hash).with(id: "22", file_set_hash: "file 22", parent: work, file_set_of: 1,
                                                                    file_set_count: 2, file_size: "222 KB", build_mode: "re-build").and_return "file set 22"
          allow(subject).to receive(:build_file_set_from_hash).with(id: "33", file_set_hash: "file 33", parent: work, file_set_of: 2,
                                                                    file_set_count: 2, file_size: "3 MB", build_mode: "re-build").and_return "file set 33"
          allow(subject).to receive(:add_file_set_to_work).with(work: work, file_set: "file set 22")
          allow(subject).to receive(:add_file_set_to_work).with(work: work, file_set: "file set 33")
        }
        it "" do
          expect(subject).to receive(:build_file_set_from_hash).with(id: "22", file_set_hash: "file 22", parent: work, file_set_of: 1,
                                                                    file_set_count: 2, file_size: "222 KB", build_mode: "re-build")
          expect(subject).to receive(:build_file_set_from_hash).with(id: "33", file_set_hash: "file 33", parent: work, file_set_of: 2,
                                                                    file_set_count: 2, file_size: "3 MB", build_mode: "re-build")
          expect(subject).to receive(:add_file_set_to_work).with(work: work, file_set: "file set 22")
          expect(subject).to receive(:add_file_set_to_work).with(work: work, file_set: "file set 33")
          expect(work).to receive(:save!)
          expect(work).to receive(:reload)
          subject.send(:add_file_sets_to_work_from_file_set_ids,
                       work_hash: {:file_set_ids => [22,33], :f_22 => "file 22", :f_33 => "file 33"}, work: work)
        end
      end

      context "when file set ids are absent in work hash" do
        it "saves, reloads, and returns work" do
          work = MockFileSetWork.new
          expect(work).to receive(:save!)
          expect(work).to receive(:reload)

          expect(subject).not_to receive(:continue_new_content_service)
          expect(subject).not_to receive(:add_file_sets_file_size)

          expect(subject.send(:add_file_sets_to_work_from_file_set_ids, work_hash: {:file_set_ids => []}, work: work)).to eq work
        end
      end
    end

    context "when file set ids are present in work hash and continue_new_content_service returns false" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return false
      }
      it "saves, reloads, and returns work" do
        work = MockFileSetWork.new
        expect(work).to receive(:save!)
        expect(work).to receive(:reload)

        expect(subject).to receive(:continue_new_content_service)
        expect(subject).not_to receive(:add_file_sets_file_size)

        expect(subject.send(:add_file_sets_to_work_from_file_set_ids, work_hash: {:file_set_ids => [12,22,33]}, work: work)).to eq work
      end
    end
  end


  describe "#add_file_sets_to_work_from_files" do
    context "when files value in work_hash parameter is blank" do
      it "returns work" do
        expect(subject).not_to receive(:continue_new_content_service)

        expect(subject.send(:add_file_sets_to_work_from_files, work_hash: {:files => ""}, work: "work, work!")).to eq "work, work!"
      end
    end

    context "when files value in work_hash parameter is present" do
      context "when continue_new_content_service returns true" do
        work = MockFileSetWork.new
        before {
          allow(subject).to receive(:continue_new_content_service).and_return true
          allow(subject).to receive(:add_file_sets_file_size).with(file_set_hash: nil, path: "path 1").and_return "file size 1"
          allow(subject).to receive(:build_file_set).with(id: nil, path: "path 1", work: work, filename: "filename 1", file_ids: "file ids 1",
                                                          file_set_of: 1, file_set_count: 2, file_size: "file size 1").and_return "file set 1"
          allow(subject).to receive(:add_file_set_to_work).with(work: work, file_set: "file set 1")

          allow(subject).to receive(:add_file_sets_file_size).with(file_set_hash: nil, path: "path 2").and_return "file size 2"
          allow(subject).to receive(:build_file_set).with(id: nil, path: "path 2", work: work, filename: "filename 2", file_ids: "file ids 2",
                                                          file_set_of: 2, file_set_count: 2, file_size: "file size 2").and_return "file set 2"
          allow(subject).to receive(:add_file_set_to_work).with(work: work, file_set: "file set 2")
        }

        scenarios = [{:included => true, :file_ids => "file ids", :file_names => "file names"},
                     {:included => false, :file_ids => nil, :file_names => nil}]
        scenarios.each do |scenario|
          context "when work_hash does #{scenario[:included] ? '' : 'NOT'} include file ids and filenames" do
            it "add file sets to work and returns work" do
              zip_files = MockZipFiles.new

              expect(subject).to receive(:add_file_sets_file_size).with(file_set_hash: nil, path: "path 1").and_return "file size 1"
              expect(subject).to receive(:build_file_set).with(id: nil, path: "path 1", work: work, filename: "filename 1", file_ids: "file ids 1",
                                                               file_set_of: 1, file_set_count: 2, file_size: "file size 1")
              expect(subject).to receive(:add_file_set_to_work).with(work: work, file_set: "file set 1")

              expect(subject).to receive(:add_file_sets_file_size).with(file_set_hash: nil, path: "path 2").and_return "file size 2"
              expect(subject).to receive(:build_file_set).with(id: nil, path: "path 2", work: work, filename: "filename 2", file_ids: "file ids 2",
                                                               file_set_of: 2, file_set_count: 2, file_size: "file size 2")
              expect(subject).to receive(:add_file_set_to_work).with(work: work, file_set: "file set 2")

              expect(work).to receive(:save!)
              expect(work).to receive(:reload)

              expect(subject).to receive(:continue_new_content_service)
              expect(subject.send(:add_file_sets_to_work_from_files, work_hash: {:files => zip_files, :file_ids => scenario[:file_ids],
                                                                                 :filenames => scenario[:file_names]}, work: work)).to eq work
            end
          end
        end
      end

      context "when continue_new_content_service returns false" do
        work = MockFileSetWork.new
        before {
          allow(subject).to receive(:continue_new_content_service).and_return false
        }
        it "saves, reloads, and returns work" do
          zip_files = MockZipFiles.new

          expect(work).to receive(:save!)
          expect(work).to receive(:reload)

          expect(subject).to receive(:continue_new_content_service)
          expect(subject.send(:add_file_sets_to_work_from_files, work_hash: {:files => zip_files, :file_ids => "file ids", :filenames => "file names"},
                              work: work)).to eq work
        end

        skip "add test for files.zip"
      end
    end
  end


  describe "#add_measurement" do
    before {
      allow(subject).to receive(:measurements).and_return [1,2,3,4]
    }
    it "appends measurement parameter to measurements function results and returns" do
      expect(subject).to receive(:measurements)

      expect(subject.send(:add_measurement, 5)).to eq [1,2,3,4,5]
    end
  end


  describe "#add_works_to_collection" do
    context "when works_from_hash call returns blank results" do
      before {
        allow(subject).to receive(:works_from_hash).with(hash: "collection_hash").and_return []
      }
      it "returns collection parameter" do
        allow(subject).to receive(:works_from_hash).with(hash: "collection hash")
        expect(subject.send(:add_works_to_collection, collection_hash: "collection_hash", collection: "collection")).to eq "collection"
      end
    end

    context "when works_from_hash call returns valid results" do
      before {
        allow(subject).to receive(:works_from_hash).with(hash: "collection hash").and_return [[36, 42]]
      }

      context "when continue_new_content_service returns false" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return false
        }
        it "saves, reloads, and returns collection parameter" do
          expect(subject).to receive(:continue_new_content_service)
          collection = MockFileSetWork.new
          expect(collection).to receive(:save!)
          expect(collection).to receive(:reload)
          expect(subject.send(:add_works_to_collection, collection_hash: "collection hash", collection: collection)).to eq collection
        end
      end

      context "when continue_new_content_service returns true" do
        collection = MockFileSetWork.new "collection id"
        collection_work_42 = MockCollectionWork.new []
        before {
          allow(subject).to receive(:continue_new_content_service).and_return true
          allow(subject).to receive(:work_hash_from_id).with(parent_hash: "collection hash", work_id: "36").and_return "work hash 36"
          allow(subject).to receive(:work_hash_from_id).with(parent_hash: "collection hash", work_id: "42").and_return "work hash 42"
          allow(subject).to receive(:build_or_find_work).with(work_hash: "work hash 36", parent: collection)
                                                        .and_return MockCollectionWork.new ["collection id"]

          allow(subject).to receive(:build_or_find_work).with(work_hash: "work hash 42", parent: collection).and_return collection_work_42
          allow(subject).to receive(:log_provenance_add_child).with(parent: collection, child: collection_work_42)
        }
        it "adds works to collection and returns collection parameter" do
          expect(subject).to receive(:works_from_hash)
          expect(subject).to receive(:continue_new_content_service)
          expect(subject).to receive(:work_hash_from_id).with(parent_hash: "collection hash", work_id: "36")
          expect(subject).to receive(:work_hash_from_id).with(parent_hash: "collection hash", work_id: "42")
          expect(subject).to receive(:build_or_find_work).with(work_hash: "work hash 36", parent: collection)
          expect(subject).to receive(:build_or_find_work).with(work_hash: "work hash 42", parent: collection)
          expect(subject).to receive(:log_provenance_add_child).with(parent: collection, child: collection_work_42)

          expect(collection).to receive(:save!)
          expect(collection).to receive(:reload)

          expect(subject.send(:add_works_to_collection, collection_hash: "collection hash", collection: collection)).to eq collection
        end

        skip "add a test for work.save! and work.member_of_collections"
      end
    end
  end


  describe "#add_work_to_parent_ids" do
    context "when value for in_collections in work_hash parameter is blank" do
      it "returns nil" do
        expect(subject.send(:add_work_to_parent_ids, work_hash: {in_collections: ""}, work: nil)).to be_nil
      end
    end

    context "when value for in_collections in work_hash parameter is present" do

      context "when collection can be found by id" do
        work = MockCollectionWork.new [99]
        before {
          allow(Collection).to receive(:find).with(101).and_return "collection 101"
          allow(subject).to receive(:log_provenance_add_child).with(parent: "collection 101", child: work)
        }
        it "" do
          expect(Collection).not_to receive(:find).with(99)
          expect(Collection).to receive(:find).with(101)
          expect(subject).to receive(:log_provenance_add_child).with(parent: "collection 101", child: work)
          expect(subject).not_to receive(:log_provenance_add_child).with(parent: "collection 99", child: work)
          expect(work).to receive(:save!).once
          subject.send(:add_work_to_parent_ids, work_hash: {in_collections: [99, 101]}, work: work)
        end

        skip "add a test for work.member_of_collections to equal [\"collection 101\"]"
      end

      context "when collection canNOT be found by id" do
        work = MockCollectionWork.new []
        before {
          allow(Collection).to receive(:find).with(45).and_raise(ActiveFedora::ObjectNotFoundError)
        }
        it "raises ActiveFedora::ObjectNotFoundError" do
          expect(subject).to receive(:puts).with "Collection 45 not found. Unable to add work work id to it."
          subject.send(:add_work_to_parent_ids, work_hash: {in_collections: [45]}, work: work)
        end
      end
    end
  end


  describe "#admin_set_default" do
    context "when @admin_set_default has a value" do
      before {
        subject.instance_variable_set :@admin_set_default, "admin set (default)"
      }
      it "returns @admin_set_default" do
        expect(AdminSet).not_to receive(:find)

        expect(subject.send(:admin_set_default)).to eq "admin set (default)"
      end
    end

    context "when @admin_set_default has NO value" do
      before {
        allow(AdminSet).to receive(:find).with("admin_set/default").and_return "new admin set value"
      }
      it "calls AdminSet.find, returns value and sets it to @admin_set_default" do
        expect(AdminSet).to receive(:find).with("admin_set/default")
        expect(subject.send(:admin_set_default)).to eq "new admin set value"

        expect(subject.instance_variable_get(:@admin_set_default)).to eq "new admin set value"
      end
    end
  end


  describe "#admin_set_data_set" do
    context "when @admin_set_data_set has a value" do
      before {
        subject.instance_variable_set :@admin_set_data_set, "admin set data set"
      }
      it "returns @admin_set_data_set" do
        expect(AdminSet).not_to receive(:all)

        expect(subject.send(:admin_set_data_set)).to eq "admin set data set"
      end
    end

    context "when @admin_set_data_set has NO value" do
      set1 = OpenStruct.new(title: "DataSet Admin Set", id: 1)
      set2 = OpenStruct.new(title: "DataSet Admin Set", id: 2)

      before {
        adminset = MockAdminSet.new
        allow(AdminSet).to receive(:all).and_return(adminset)
        allow(adminset).to receive(:select).and_return [set1, set2]
      }
      it "sets and returns @admin_set_data_set" do
        expect(AdminSet).to receive(:all)
        expect(subject.send(:admin_set_data_set)).to eq set1

        expect(subject.instance_variable_get(:@admin_set_data_set)).to eq set1
      end
    end
  end


  describe "#admin_set_data_set?" do
    context "when parameter admin_set is nil" do
      it "return false" do
        expect(subject.send(:admin_set_data_set?, nil)).to eq false
      end
    end

    context "when parameter admin_set is NOT nil" do

      context "when admin_set title field is equal to DataSet Admin Set" do
        it "returns true" do
          expect(subject.send(:admin_set_data_set?, OpenStruct.new(title: ["DataSet Admin Set"]))).to eq true
        end
      end

      context "when admin_set title field is NOT equal to DataSet Admin Set" do
        it "returns false" do
          expect(subject.send(:admin_set_data_set?, OpenStruct.new(title: ["Advanced Scientific Research"]))).to eq false
        end
      end
    end
  end


  describe "#admin_set_work" do
    context "when dbd_version_1 is true" do
      before {
        allow(Deepblue::TaskHelper).to receive(:dbd_version_1?).and_return true
        allow(subject).to receive(:admin_set_default)
      }
      it "calls admin_set_default" do
        expect(subject).to receive(:admin_set_default)
        expect(subject).not_to receive(:admin_set_data_set)

        subject.send(:admin_set_work)
      end
    end

    context "when dbd_version_1 is false" do
      before {
        allow(Deepblue::TaskHelper).to receive(:dbd_version_1?).and_return false
        allow(subject).to receive(:admin_set_data_set)
      }
      it "calls admin_set_data_set" do
        expect(subject).to receive(:admin_set_data_set)
        expect(subject).not_to receive(:admin_set_default)

        subject.send(:admin_set_work)
      end
    end

    after {
      expect(Deepblue::TaskHelper).to have_received(:dbd_version_1?)
    }
  end


  describe "#apply_visibility_and_workflow" do
    before {
      allow(subject).to receive(:visibility_from_hash).with(hash: "work hash").and_return "open"
    }

    context "when TaskHelper.dbd_version_1? returns true" do
      before {
        allow(Deepblue::TaskHelper).to receive(:dbd_version_1?).and_return true
      }
      it "returns nil" do
        work = MockVisibilityWork.new nil
        expect(subject.send(:apply_visibility_and_workflow, work: work, work_hash: "work hash", admin_set: "admin set")).to be_nil
      end
    end

    context "when TaskHelper.dbd_version_1? returns false" do
      before {
        allow(Deepblue::TaskHelper).to receive(:dbd_version_1?).and_return false
      }

      context "when admin_set_data_set? returns false" do
        before {
          allow(subject).to receive(:admin_set_data_set?).with("admin set").and_return false
        }
        it "returns nil" do
          work = MockVisibilityWork.new nil
          expect(subject.send(:apply_visibility_and_workflow, work: work, work_hash: "work hash", admin_set: "admin set")).to be_nil
        end
      end

      context "when admin_set_data_set? returns true" do
        work = MockVisibilityWork.new 121
        entity = MockWorkflow.new

        before {
          allow(subject).to receive(:admin_set_data_set?).with("admin set").and_return true
          allow(subject).to receive(:apply_work).with(work)
          allow(Sipity::Entity).to receive(:create!).with(proxy_for_global_id: "121000", workflow: "active workflow", workflow_state: nil).and_return entity
          allow(subject).to receive(:action_name).with("open").and_return "deposited"
          allow(Sipity::WorkflowAction).to receive(:find_or_create_by!).with(workflow: "active workflow", name: "deposited").and_return OpenStruct.new(id: "action id")
          allow(Sipity::WorkflowState).to receive(:find_or_create_by!).with(workflow: "active workflow", name: "deposited").and_return "workflow state"
          allow(subject).to receive(:log_provenance_workflow).with(curation_concern: work, workflow: "active workflow", workflow_state: "deposited")
        }
        it "applies visibility and workflow" do
          expect(subject).to receive(:apply_work).with(work)
          expect(Sipity::Entity).to receive(:create!).with(proxy_for_global_id: "121000", workflow: "active workflow", workflow_state: nil)
          expect(subject).to receive(:action_name).with("open")
          expect(Sipity::WorkflowAction).to receive(:find_or_create_by!).with(workflow: "active workflow", name: "deposited")
          expect(Sipity::WorkflowState).to receive(:find_or_create_by!).with(workflow: "active workflow", name: "deposited")

          expect(entity).to receive(:update!).with(workflow_state_id: "action id", workflow_state: "workflow state")
          expect(subject).to receive(:log_provenance_workflow).with(curation_concern: work, workflow: "active workflow", workflow_state: "deposited")

          subject.send(:apply_visibility_and_workflow, work: work, work_hash: "work hash", admin_set: "admin set")
        end
      end

      after {
        expect(subject).to have_received(:admin_set_data_set?).with("admin set")
      }
    end

    after {
      expect(subject).to have_received(:visibility_from_hash).with(hash: "work hash")
      expect(Deepblue::TaskHelper).to have_received(:dbd_version_1?)
    }
  end


  describe "#apply_work" do
    context "when work parameter id field is present" do
      it "returns nil" do
        work_1001 = MockVisibilityWork.new(1001)
        expect(subject.send(:apply_work, work_1001)).to be_nil
      end
    end

    context "when work parameter id field is nil" do
      it "saves and reloads work parameter" do
        work = MockVisibilityWork.new nil
        expect(work).to receive(:save!)
        expect(work).to receive(:reload)

        subject.send(:apply_work, work)
      end
    end
  end


  describe "#action_name" do
    visibilities = [{:visibility => "open", :action_name => "deposited"}, {:visibility => nil, :action_name => "pending_review"}]
    visibilities.each do |access|
      context "when visibility is equal to #{access[:visibility]}" do
        it "returns #{access[:action_name]}" do
          expect(subject.send(:action_name, access[:visibility])).to eq access[:action_name]
        end
      end
    end
  end


  describe "#attr_prefix" do
    fileset = FileSet.new
    fileset.id = 1
    collection = Collection.new
    collection.id = 2
    work = OpenStruct.new(id: 3)
    attributes = [{:object => fileset, :prefix => "file"},
                  {:object => collection, :prefix => "coll"},
                  {:object => work, :prefix => "work"}]
    attributes.each do |attribute|
      context "when parameter #{attribute[:object].class}" do
        it "returns id with prefix of #{attribute[:prefix]}" do
          expect(subject.send(:attr_prefix, attribute[:object])).to eq "#{attribute[:prefix]} #{attribute[:object].id}"
        end
      end
    end
  end


  describe "#build_admin_set_work" do
    before {
      allow(subject).to receive(:admin_set_work).and_return "admin set work"
    }

    context "when admin_set_id value of hash parameter is blank" do
      it "calls admin_set_work and returns result" do
        expect(AdminSet).not_to receive(:default_set?)
        expect(subject).to receive(:admin_set_work)

        expect(subject.send(:build_admin_set_work, hash: {:admin_set_id => ""})).to eq "admin set work"
      end
    end

    context "when admin_set_id value of hash parameter is present" do
      context "when admin_set_id is the default admin set" do
        before {
          allow(AdminSet).to receive(:default_set?).with("QRF-3").and_return true
        }
        it "calls admin_set_work and returns result" do
          expect(subject).to receive(:admin_set_work)
          expect(AdminSet).not_to receive(:find).with("QRF-3")

          expect(subject.send(:build_admin_set_work, hash: {:admin_set_id => "QRF-3"})).to eq "admin set work"
        end
      end

      context "when admin_set_id is NOT the default admin set" do
        before {
          allow(AdminSet).to receive(:default_set?).with("QRF-3").and_return false
        }
        context "when call to AdminSet.find is successful" do
          before {
            allow(AdminSet).to receive(:find).with("QRF-3").and_return "admin set found"
          }
          it "calls AdminSet.find and returns result" do
            expect(subject.send(:build_admin_set_work, hash: {:admin_set_id => "QRF-3"})).to eq "admin set found"
          end
        end

        context "when call to AdminSet.find fails" do
          context "when call to AdminSet.find results in an ActiveFedora::ObjectNotFoundError error" do
            before {
              allow(AdminSet).to receive(:find).with("QRF-3").and_raise(ActiveFedora::ObjectNotFoundError)
            }
            it "calls admin_set_work and returns result" do
              expect(subject.send(:build_admin_set_work, hash: {:admin_set_id => "QRF-3"})).to eq "admin set work"
            end
          end

          context "when call to AdminSet.find results in a Ldp::Gone error" do
            before {
              allow(AdminSet).to receive(:find).with("QRF-3").and_raise(Ldp::Gone)
            }
            it "calls admin_set_work and returns result" do
              expect(subject.send(:build_admin_set_work, hash: {:admin_set_id => "QRF-3"})).to eq "admin set work"
            end
          end

          after {
            expect(subject).to have_received(:admin_set_work)
          }
        end

        after {
          expect(AdminSet).to have_received(:find).with("QRF-3")
        }
      end

      after {
        expect(AdminSet).to have_received(:default_set?).with("QRF-3")
      }
    end
  end


  describe "#build_collection" do
    context "when continue_new_service evaluates to false" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return false
      }
      it "returns nil" do
        expect(subject).not_to receive(:find_existing_collection)

        expect(subject.send(:build_collection, id: 555, collection_hash: {})).to be_nil
      end
    end

    context "when continue_new_service evaluates to true" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return true
      }
      context "when find_existing_collection returns existing collection" do
        before {
          allow(subject).to receive(:find_existing_collection).and_return "collection"
        }
        it "returns collection" do
          expect(subject).not_to receive(:build_date)

          expect(subject.send(:build_collection, id: 29, collection_hash: {})).to eq "collection"
        end
      end

      context "when find_existing_collection does NOT return existing collection" do
        collection_hash = {:creator => "creator", :curation_notes_admin => "admin", :curation_notes_user => "user",
                                   :description => "", :edit_users => "edit users", :keyword => "keyword", :language => ["french", "tagalog"],
                                   :resource_type => "resource type", :title => ["title"]}
        collection = MockBuildCollection.new

        before {
          allow(subject).to receive(:find_existing_collection).and_return nil
          allow(subject).to receive(:build_date).with(hash: collection_hash, key: :date_created).and_return "date created"
          allow(subject).to receive(:build_date).with(hash: collection_hash, key: :date_modified).and_return "date modified"
          allow(subject).to receive(:build_date).with(hash: collection_hash, key: :date_uploaded).and_return "date uploaded"
          allow(subject).to receive(:default_description).with("").and_return ["default description"]
          allow(subject).to receive(:default_collection_resource_type).with(resource_type: "resource type").and_return ["resource type"]
          allow(subject).to receive(:build_doi).with(hash: collection_hash).and_return "build doi"
          allow(subject).to receive(:build_prior_identifier).with(hash: collection_hash, id: 45).and_return ["prior identifier"]
          allow(subject).to receive(:build_referenced_by).with(hash: collection_hash).and_return ["build referenced by"]
          allow(subject).to receive(:build_subject_discipline).with(hash: collection_hash).and_return ["subject discipline"]

          allow(subject).to receive(:build_collection_type).with(hash: collection_hash).and_return "collection type"
          allow(subject).to receive(:build_depositor).with(hash: collection_hash).and_return "build depositor"
          allow(subject).to receive(:update_cc_edit_users).with(curation_concern: collection, edit_users: ["edit users"] )
          allow(subject).to receive(:visibility_from_hash).with( hash: collection_hash ).and_return "open"
          allow(subject).to receive(:log_provenance_ingest).with( curation_concern: collection )
        }
        context "when mode is MODE_MIGRATE" do
          before {
            allow(subject).to receive(:mode).and_return "migrate"
            allow(Collection).to receive(:new).with( creator: ["creator"],
                                                     curation_notes_admin: ["admin"],
                                                     curation_notes_user: ["user"],
                                                     date_created: "date created",
                                                     date_modified: "date modified",
                                                     date_uploaded: "date uploaded",
                                                     description: ["default description"],
                                                     doi: "build doi",
                                                     id: 45,
                                                     keyword: ["keyword"],
                                                     language: ["french", "tagalog"],
                                                     prior_identifier: ["prior identifier"],
                                                     referenced_by: ["build referenced by"],
                                                     resource_type: ["resource type"],
                                                     subject_discipline: ["subject discipline"],
                                                     title: ["title"] ).and_return collection
            allow(subject).to receive(:log_provenance_migrate).with( curation_concern: collection, build_mode: "migrate" )
          }
          it "creates and returns a new collection with the id parameter passed in" do
            expect(Collection).to receive(:new).with( creator: ["creator"],
                                                      curation_notes_admin: ["admin"],
                                                      curation_notes_user: ["user"],
                                                      date_created: "date created",
                                                      date_modified: "date modified",
                                                      date_uploaded: "date uploaded",
                                                      description: ["default description"],
                                                      doi: "build doi",
                                                      id: 45,
                                                      keyword: ["keyword"],
                                                      language: ["french", "tagalog"],
                                                      prior_identifier: ["prior identifier"],
                                                      referenced_by: ["build referenced by"],
                                                      resource_type: ["resource type"],
                                                      subject_discipline: ["subject discipline"],
                                                      title: ["title"] )
            expect(subject).to receive(:log_provenance_migrate).with( curation_concern: collection, build_mode: "migrate" )
            expect(collection).to receive(:collection_type=).with "collection type"
            expect(collection).to receive(:apply_depositor_metadata).with "build depositor"
            expect(collection).to receive(:visibility=).with "open"
            expect(collection).to receive(:save!)
            expect(collection).to receive(:reload)

            expect(subject.send(:build_collection, id: 45, collection_hash: collection_hash)).to eq collection
          end
        end

        context "when mode is NOT MODE_MIGRATE" do
          before {
            allow(subject).to receive(:mode).and_return "append"
            allow(Collection).to receive(:new).with( creator: ["creator"],
                                                     curation_notes_admin: ["admin"],
                                                     curation_notes_user: ["user"],
                                                     date_created: "date created",
                                                     date_modified: "date modified",
                                                     date_uploaded: "date uploaded",
                                                     description: ["default description"],
                                                     doi: "build doi",
                                                     id: nil,
                                                     keyword: ["keyword"],
                                                     language: ["french", "tagalog"],
                                                     prior_identifier: ["prior identifier"],
                                                     referenced_by: ["build referenced by"],
                                                     resource_type: ["resource type"],
                                                     subject_discipline: ["subject discipline"],
                                                     title: ["title"] ).and_return collection
            allow(subject).to receive(:log_provenance_migrate).with( curation_concern: collection, build_mode: "append" )
          }
          it "creates a new collection with a nil id and returns it" do
            expect(Collection).to receive(:new).with( creator: ["creator"],
                                                      curation_notes_admin: ["admin"],
                                                      curation_notes_user: ["user"],
                                                      date_created: "date created",
                                                      date_modified: "date modified",
                                                      date_uploaded: "date uploaded",
                                                      description: ["default description"],
                                                      doi: "build doi",
                                                      id: nil,
                                                      keyword: ["keyword"],
                                                      language: ["french", "tagalog"],
                                                      prior_identifier: ["prior identifier"],
                                                      referenced_by: ["build referenced by"],
                                                      resource_type: ["resource type"],
                                                      subject_discipline: ["subject discipline"],
                                                      title: ["title"] )
            expect(subject).to receive(:log_provenance_migrate).with( curation_concern: collection, build_mode: "append" )
            expect(collection).to receive(:collection_type=).with "collection type"
            expect(collection).to receive(:apply_depositor_metadata).with "build depositor"
            expect(collection).to receive(:visibility=).with "open"
            expect(collection).to receive(:save!)
            expect(collection).to receive(:reload)

            expect(subject.send(:build_collection, id: 45, collection_hash: collection_hash)).to eq collection
          end
        end
      end

      after {
        expect(subject).to have_received(:find_existing_collection)
      }
    end

    after {
      expect(subject).to have_received(:continue_new_content_service)
    }
  end


  describe "#find_existing_collection" do
    context "when id parameter is blank" do
      it "returns nil" do
        expect(subject).not_to receive(:mode)

        expect(subject.send(:find_existing_collection, id: "")).to be_nil
      end
    end

    context "when id parameter is present" do
      context "when mode is MODE_APPEND" do
        before {
          allow(subject).to receive(:mode).and_return "append"
        }
        context "when collection is found" do
          collection = OpenStruct.new(title: ["collection 88"])
          before {
            allow(subject).to receive(:find_collection_using_prior_id).with( prior_id: 88 ).and_return collection
            allow(subject).to receive(:log_msg).with "append: found collection with id: 88 title: collection 88"
          }
          it "returns collection" do
            expect(subject).to receive(:mode).twice
            expect(subject).to receive(:find_collection_using_prior_id).with( prior_id: 88 )
            expect(subject).to receive(:log_msg).with "append: found collection with id: 88 title: collection 88"

            expect(subject.send(:find_existing_collection, id: 88)).to eq collection
          end
        end

        context "when collection is NOT found" do
          before {
            allow(subject).to receive(:find_collection_using_prior_id).with( prior_id: 88 ).and_return nil
          }
          it "returns nil" do
            expect(subject).to receive(:mode).once
            expect(subject).to receive(:find_collection_using_prior_id).with( prior_id: 88 )
            expect(subject).not_to receive(:log_msg)

            expect(subject.send(:find_existing_collection, id: 88)).to be_nil
          end
        end
      end

      context "when mode is MODE_MIGRATE" do
        before {
          allow(subject).to receive(:mode).and_return "migrate"
        }
        context "when collection is found" do
          collection = OpenStruct.new(title: ["collection 4"])
          before {
            allow(subject).to receive(:find_collection_using_id).with( id: 4 ).and_return collection
            allow(subject).to receive(:log_msg).with "migrate: found collection with id: 4 title: collection 4"
          }
          it "returns collection" do
            expect(subject).to receive(:mode).thrice
            expect(subject).to receive(:find_collection_using_id).with( id: 4 )
            expect(subject).to receive(:log_msg).with "migrate: found collection with id: 4 title: collection 4"

            expect(subject.send(:find_existing_collection, id: 4)).to eq collection
          end
        end

        context "when collection is NOT found" do
          before {
            allow(subject).to receive(:find_collection_using_id).with( id: 4 ).and_return nil
          }
          it "returns nil" do
            expect(subject).to receive(:mode).twice
            expect(subject).to receive(:find_collection_using_id).with( id: 4 )
            expect(subject).not_to receive(:log_msg)

            expect(subject.send(:find_existing_collection, id: 4)).to be_nil
          end
        end
      end

      context "when mode is NOT MODE_APPEND or MODE_MIGRATE" do   # for example, MODE_UPDATE
        before {
          allow(subject).to receive(:mode).and_return "update"
        }
        it "returns nil" do
          expect(subject).to receive(:mode).twice
          expect(subject).not_to receive(:log_msg)

          expect(subject.send(:find_existing_collection, id: 606)).to be_nil
        end
      end
    end
  end


  describe "#default_description" do
    collections = [{:description => "", :expected_result => ["Missing description"]},
                   {:description => nil, :expected_result => ["Missing description"]},
                   {:description => "accurate description", :expected_result => ["accurate description"]}]

    collections.each do |collection|
      context "when description is equal to '#{collection[:description]}'" do
        it "returns #{collection[:expected_result]}" do
          expect(subject.send(:default_description, collection[:description])).to eq collection[:expected_result]
        end
      end
    end
  end


  describe "#default_methodology" do
    methods = [{:description => "", :expected_result => ""},
               {:description => nil, :expected_result => "No Methodology Available"},
               {:description => "approved method", :expected_result => "approved method"}]

    methods.each do |method|
      context "when methodology parameter is equal to '#{method[:description]}'" do
        it "returns #{method[:expected_result]}" do
          expect(subject.send(:default_methodology, method[:description])).to eq method[:expected_result]
        end
      end
    end
  end


  describe "#default_collection_resource_type" do
    collections = [{:resource_type => nil, :expected_result => ["Collection"]},
                   {:resource_type => "", :expected_result => [""]},
                   {:resource_type => "resource type", :expected_result => ["resource type"]}]

    collections.each do |collection|
      context "when resource_type is equal to #{collection[:resource_type]}" do
        it "returns #{collection[:expected_result]}" do
          expect(subject.send(:default_collection_resource_type, resource_type: collection[:resource_type])).to eq collection[:expected_result]
        end
      end
    end
  end


  describe "#build_collection_type" do
    before {
      allow(Hyrax::CollectionType).to receive(:find_or_create_default_collection_type).and_return "default collection type"
    }
    context "when source is SOURCE_DBDv1" do
      before {
        allow(subject).to receive(:source).and_return "DBDv1"
      }
      it "returns default collection type" do
        expect(subject).to receive(:source)
        expect(Hyrax::CollectionType).not_to receive(:find_by)

        expect(subject.send(:build_collection_type, hash: nil)).to eq "default collection type"
      end
    end

    context "when source is NOT SOURCE_DBDv1" do
      before {
        allow(subject).to receive(:source).and_return "DBDv2"
      }
      context "when collection_type is present in hash parameter" do

        context "when result is found for hash parameter collection_type" do
          before {
            allow(Hyrax::CollectionType).to receive(:find_by).with( machine_id: "collection type" ).and_return "found collection type"
          }
          it "calls CollectionType.find_by and returns result" do
            expect(Hyrax::CollectionType).to receive(:find_by).with(machine_id: "collection type")
            expect(Hyrax::CollectionType).not_to receive(:find_by_gid).with("type gid")
            expect(Hyrax::CollectionType).not_to receive(:find_or_create_default_collection_type)

            expect(subject.send(:build_collection_type, hash: {:collection_type => "collection type"})).to eq "found collection type"
          end
        end

        context "when result is NOT found for hash parameter collection_type" do
          before {
            allow(Hyrax::CollectionType).to receive(:find_by).with( machine_id: "collection type" ).and_return nil
          }

          context "when collection_type_gid is present in hash parameter" do
            context "when result is found for hash parameter collection_type_gid" do
              before {
                allow(Hyrax::CollectionType).to receive(:find_by_gid).with("type gid").and_return 'found type gid'
              }
              it "calls CollectionType.find_by_gid and returns result" do
                expect(Hyrax::CollectionType).not_to receive(:find_or_create_default_collection_type)

                expect(subject.send(:build_collection_type, hash: {:collection_type => "collection type", :collection_type_gid => "type gid"}))
                  .to eq "found type gid"
              end
            end

            context "when result is NOT found for hash parameter collection_type_gid" do
              before {
                allow(Hyrax::CollectionType).to receive(:find_by_gid).with("type gid").and_return nil
                allow(Hyrax::CollectionType).to receive(:find_or_create_default_collection_type).and_return "default collection type"
              }
              it "calls CollectionType.find_or_create_default_collection_type and returns result" do
                expect(Hyrax::CollectionType).to receive(:find_or_create_default_collection_type)

                expect(subject.send(:build_collection_type, hash: {:collection_type => "collection type", :collection_type_gid => "type gid"})).to eq "default collection type"
              end
            end

            after {
              expect(Hyrax::CollectionType).to have_received(:find_by).with(machine_id: "collection type")
              expect(Hyrax::CollectionType).to have_received(:find_by_gid).with("type gid")
            }
          end
        end
      end

      context "when collection_type is blank in hash parameter" do
        context "when collection_type_gid is present in hash parameter" do

          context "when result is found for hash parameter collection_type_gid" do
            before {
              allow(Hyrax::CollectionType).to receive(:find_by_gid).with("type gid").and_return 'found type gid'
            }
            it "calls CollectionType.find_by_gid and returns result" do
              expect(Hyrax::CollectionType).not_to receive(:find_by)
              expect(Hyrax::CollectionType).not_to receive(:find_or_create_default_collection_type)

              subject.send(:build_collection_type, hash: {:collection_type => "", :collection_type_gid => "type gid"})
            end
          end

          context "when result is NOT found for hash parameter collection_type_gid" do
            before {
              allow(Hyrax::CollectionType).to receive(:find_by_gid).with("type gid").and_return nil
              allow(Hyrax::CollectionType).to receive(:find_or_create_default_collection_type).and_return "default collection type"
            }
            it "calls CollectionType.find_or_create_default_collection_type and returns result" do
              expect(Hyrax::CollectionType).not_to receive(:find_by)
              expect(Hyrax::CollectionType).to receive(:find_or_create_default_collection_type)

              expect(subject.send(:build_collection_type, hash: {:collection_type => "", :collection_type_gid => "type gid"})).to eq "default collection type"
            end
          end

          after {
            expect(Hyrax::CollectionType).to have_received(:find_by_gid).with("type gid")
          }
        end

        context "when collection_type_gid is blank in hash parameter" do
          before {
            allow(Hyrax::CollectionType).to receive(:find_or_create_default_collection_type).and_return "default collection type"
          }
          it "calls CollectionType.find_or_create_default_collection_type and returns result" do
            expect(Hyrax::CollectionType).not_to receive(:find)
            expect(Hyrax::CollectionType).not_to receive(:find_by_gid)
            expect(Hyrax::CollectionType).to receive(:find_or_create_default_collection_type)

            expect(subject.send(:build_collection_type, hash: {:collection_type => "", :collection_type_gid => ""})).to eq "default collection type"
          end
        end
      end
    end
  end


  describe "#build_collections" do
    context "when collections function evaluates to false" do
      before {
        allow(subject).to receive(:collections).and_return false
      }
      it "returns nil" do
        expect(subject).to receive(:collections)
        expect(subject).not_to receive(:user_create_users)

        expect(subject.send(:build_collections)).to be_nil
      end
    end

    context "when collections function evaluates to true" do
      before {
        allow(subject).to receive(:collections).and_return ["collection hash 1", "collection hash 2"]
        allow(subject).to receive(:user_key).and_return "user key"
        allow(subject).to receive(:user_create_users).with(emails: "user key")
      }

      context "when continue_new_content_service evaluates to false" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return false
        }
        it "returns nil" do
          expect(subject).to receive(:collections).twice
          expect(subject).to receive(:user_create_users).with(emails: "user key")
          expect(subject).to receive(:continue_new_content_service).twice
          expect(Benchmark).not_to receive(:measure)

          expect(subject.send(:build_collections)).to eq ["collection hash 1", "collection hash 2"] 
        end
      end

      context "when continue_new_content_service evaluates to true" do
        before {
          measurement = MockMeasurement.new
          allow(subject).to receive(:continue_new_content_service).and_return true
          allow(Benchmark).to receive(:measure).and_return measurement
          allow(subject).to receive(:build_or_find_collection).with(collection_hash: "collection hash 1").and_return nil
          allow(subject).to receive(:build_or_find_collection).with(collection_hash: "collection hash 2").and_return OpenStruct.new(id: "id 2")
          allow(subject).to receive(:add_measurement).with measurement
        }
        it "continue_new_content_service evaluates to true" do
          expect(Benchmark).to receive(:measure)
          expect(subject.send(:build_collections)).to eq ["collection hash 1", "collection hash 2"]
        end

        skip "add a test for functions inside Benchmark.measure code block"
      end
    end
  end


  describe "#build_date" do
    context "when key parameter value of hash parameter is blank" do
      before {
        allow(subject).to receive(:build_date_now).with(no_default: false).and_return "build date now"
      }
      it "returns result of build_date_now" do
        expect(subject).to receive(:build_date_now).with(no_default: false)

        expect(subject.send(:build_date, hash: {"build_date_key" => ""}, key: "build_date_key")).to eq "build date now"
      end
    end

    context "when key parameter value of hash parameter is present" do

      date_options = [{:class_type => "an array", :parameter => ["2025-12-25", "12/26/2025"], :expected_result => DateTime.new(2025, 12, 25)},
                      {:class_type => "a DateTime", :parameter => DateTime.new(2025, 12, 26), :expected_result => DateTime.new(2025, 12, 26)},
                      {:class_type => "a Time object", :parameter => Time.new(2026, 1, 1, 8), :expected_result => Time.new(2026, 1, 1, 8)}]
      date_options.each do |date_option|
        context "when key parameter value of hash parameter is #{date_option[:class_type]}" do
          it "returns DateTime or Time value" do
            expect(subject).not_to receive(:build_date_now)
            expect(subject).not_to receive(:build_date2)

            expect(subject.send(:build_date, hash: {"build_date_key" => date_option[:parameter]}, key: "build_date_key")).to eq date_option[:expected_result]
          end
        end
      end

      context "when ArgumentError occurs" do
        before {
          allow(subject).to receive(:build_date2).with("not a date value", key: "build_date_key", no_default: false).and_return "build date 2"
          allow(DateTime).to receive(:parse).with("not a date value").and_raise(ArgumentError)
        }
        it "calls build_date2 function and returns result" do
          expect(subject).not_to receive(:build_date_now)
          expect(DateTime).to receive(:parse).with("not a date value")
          expect(subject).to receive(:build_date2).with("not a date value", key: "build_date_key", no_default: false)

          expect(subject.send(:build_date, hash: {"build_date_key" => "not a date value"}, key: "build_date_key")).to eq "build date 2"
        end
      end
    end
  end


  describe "#build_date2" do

    attempts = [{:string_format => "/\d\d?\/\d\d?\/\d\d\d\d/", :param_format => "%m/%d/%Y", :date_param => "10/31/2025", :expected_result => "Halloween"},
                {:string_format => "/\d\d?\-\d\d?\-\d\d\d\d/", :param_format => "%m-%d-%Y", :date_param => "4-20-2026", :expected_result => "First day of Spring"},
                {:string_format => "/d\d\d\d/", :param_format => "%Y", :date_param => "2025", :expected_result => "twenty twenty five"}]
    attempts.each do |attempt|
      context "when string matches format #{attempt[:string_format]}" do
        before {
          allow(DateTime).to receive(:strptime).with( attempt[:date_param], attempt[:param_format] ).and_return attempt[:expected_result]
        }
        it "returns string parsed to DateTime" do
          expect(DateTime).to receive(:strptime).with( attempt[:date_param], attempt[:param_format] )
          expect(subject).not_to receive(:build_date_now)
          expect(subject).not_to receive(:log_msg)

          expect(subject.send(:build_date2, attempt[:date_param], key: "build date 2 key", no_default: false)).to eq attempt[:expected_result]
        end
      end
    end

    context "when string fails to parse to DateTime" do
      before {
        allow(DateTime).to receive(:strptime).with( "20025", "%Y" ).and_raise(ArgumentError)
        allow(subject).to receive(:log_msg).with("Failed to parse data string '20025' for key 'build date 2 key'")
        allow(subject).to receive(:build_date_now).with( no_default: false).and_return "build the date"
      }
      it "logs message and returns result of build_date_now function" do
        expect(DateTime).to receive(:strptime).with( "20025", "%Y" )
        expect(subject).to receive(:log_msg).with("Failed to parse data string '20025' for key 'build date 2 key'")
        expect(subject).to receive(:build_date_now).with( no_default: false)

        expect(subject.send(:build_date2, "20025", key: "build date 2 key", no_default: false)).to eq "build the date"
      end
    end
  end


  describe "#build_date_now" do
    context "when no_default parameter is true" do
      it "returns nil" do
        expect(subject.send(:build_date_now, no_default: true)).to be_nil
      end
    end

    context "when no_default parameter is false" do
      before {
        allow(DateTime).to receive(:now).and_return "Labor Day"
      }
      it "returns DateTime.now" do
        expect(DateTime).to receive(:now)
        expect(subject.send(:build_date_now, no_default: false)).to eq "Labor Day"
      end
    end
  end


  describe "#build_date_coverage" do
    context "when date_coverage value of hash parameter is empty" do
      it "returns nil" do
        expect(subject.send(:build_date_coverage, hash: {:date_coverage => nil})).to be_nil
      end
    end

    context "when date_coverage value of hash parameter is present" do
      it "returns first item of date_coverage value array" do
        expect(subject.send(:build_date_coverage, hash: {:date_coverage => ["first day", "last day"]})).to eq "first day"
      end
    end
  end


  describe "#build_depositor" do

    context "when depositor value is present in the hash parameter" do
      before {
        allow(subject).to receive(:user_create_users).with(emails: "the user")
      }
      it "calls user_create_users and returns depositor value" do
        expect(subject).not_to receive(:user_key)

        expect(subject.send(:build_depositor, hash: {:depositor => "the user"})).to eq "the user"
      end
    end

    context "when depositor value is NOT present in the hash parameter" do
      before {
        allow(subject).to receive(:user_key).and_return "key"
      }
      it "return result of calling user_key" do
        expect(subject).not_to receive(:user_create_users)

        expect(subject.send(:build_depositor, hash: {})).to eq "key"
      end
    end
  end


  describe "#build_doi" do
    context "when doi value is present in hash parameter" do
      it "returns doi value" do
        expect(subject.send(:build_doi, hash: {:doi => "the doi value"})).to eq "the doi value"
      end
    end

    context "when doi value is NOT present in hash parameter" do
      it "returns nil" do
        expect(subject.send(:build_doi, hash: {})).to be_nil
      end
    end
  end


  describe "#build_file_set" do
    before {
      subject.instance_variable_set(:@verbose, true)
      allow(subject).to receive(:mode).and_return "append"
      allow(subject).to receive(:log_verbose_msg).with("append: building file set of 1 23MB", verbose: true)
      allow(subject).to receive(:user_key).and_return "user key"
      allow(DateTime).to receive(:now).and_return DateTime.new(2025, 12, 14)
    }
    context "when filename and file_ids parameters are present" do
      before {
        file_set = instance_double("FileSet")
        allow(subject).to receive(:build_file_set_new).with(id: "ID", depositor: "work depositor", path: "path", original_name: "filename",
                                                            build_mode: "append", current_user: "user key").and_return file_set
        allow(file_set).to receive(:title=).with(["filename"])
        allow(file_set).to receive(:label=).with("filename")
        allow(file_set).to receive(:date_uploaded=).with(DateTime.new(2025, 12, 14).new_offset( 0 ))
        allow(file_set).to receive(:visibility=).with("visibility")
        allow(file_set).to receive(:depositor=).with("work depositor")
        allow(file_set).to receive(:prior_identifier=).with("file ids")
        allow(file_set).to receive(:save!)
        allow(subject).to receive(:build_file_set_ingest).with(file_set: file_set, path: "path", checksum_algorithm: nil, checksum_value: nil,
                                                               build_mode: "append").and_return file_set
      }
      it "builds and returns file set using filename and file_ids parameters" do
        expect(File).not_to receive(:basename)

        expect(subject).to receive(:build_file_set_new).with(id: "ID", depositor: "work depositor", path: "path", original_name: "filename",
                                                            build_mode: "append", current_user: "user key")
        expect(subject).to receive(:build_file_set_ingest).with(file_set: anything, path: "path", checksum_algorithm: nil, checksum_value: nil,
                                                               build_mode: "append")
        expect(subject.send(:build_file_set, id: "ID", path: "path", work: OpenStruct.new(depositor: "work depositor", visibility: "visibility"),
                            filename: "filename", file_ids: "file ids", file_set_of: "set", file_set_count: "1", file_size: " 23MB")).to be_present
      end
    end

    context "when filename and file_ids parameters are blank" do
      before {
        file_set = instance_double("FileSet")
        allow(File).to receive(:basename).with("path").and_return "basename path"
        allow(subject).to receive(:build_file_set_new).with(id: "ID", depositor: "work depositor", path: "path", original_name: "basename path",
                                                            build_mode: "append", current_user: "user key").and_return file_set
        allow(file_set).to receive(:title=).with(["basename path"])
        allow(file_set).to receive(:label=).with("basename path")
        allow(file_set).to receive(:date_uploaded=).with(DateTime.new(2025, 12, 14).new_offset( 0 ))
        allow(file_set).to receive(:visibility=).with("visibility")
        allow(file_set).to receive(:depositor=).with("work depositor")
        allow(file_set).to receive(:save!)
        allow(subject).to receive(:build_file_set_ingest).with(file_set: file_set, path: "path", checksum_algorithm: nil, checksum_value: nil,
                                                               build_mode: "append").and_return file_set
      }
      it "builds and returns file set without using filename and file_ids parameters" do
        expect(File).to receive(:basename).with("path")
        expect(subject).to receive(:build_file_set_new).with(id: "ID", depositor: "work depositor", path: "path", original_name: "basename path",
                                                             build_mode: "append", current_user: "user key")
        expect(subject).to receive(:build_file_set_ingest).with( file_set: anything,
                                                                 path: "path",
                                                                 checksum_algorithm: nil,
                                                                 checksum_value: nil,
                                                                 build_mode: "append" )
        expect(subject.send(:build_file_set, id: "ID", path: "path", work: OpenStruct.new(depositor: "work depositor", visibility: "visibility"),
                            filename: nil, file_ids: nil, file_set_of: "set", file_set_count: "1", file_size: " 23MB")).to be_present
        end
    end

    after {
      expect(subject).to have_received(:mode).thrice
      expect(subject).to have_received(:log_verbose_msg).with("append: building file set of 1 23MB", verbose: true)
    }
  end


  describe "#build_file_set_from_hash" do
    file_set_hash = {:file_path => "file path", :original_name => "original name", :curation_notes_admin => "admin",
                     :curation_notes_user => "user", :checksum_algorithm => "algorithm", :checksum_value => "checksum value",
                     :edit_users => "edit users", :label => "label", :title => "title"}

    context "when build_mode parameter is MODE_APPEND and id parameter is present and file_set is found" do
      file_set = OpenStruct.new(title: ["First Title", "Second Title"])
      before {
        allow(subject).to receive(:find_file_set_using_prior_id).with(prior_id: "ID", parent: "parent").and_return file_set
        allow(subject).to receive(:log_msg).with("append: found file_set with prior id: ID title: First Title")
      }
      it "logs message and returns file_set" do
        expect(subject).to receive(:find_file_set_using_prior_id).with(prior_id: "ID", parent: "parent")
        expect(subject).to receive(:log_msg).with("append: found file_set with prior id: ID title: First Title")

        expect(subject).not_to receive(:find_file_set_using_id).with(id: "ID")
        expect(subject).not_to receive(:build_depositor)

        expect(subject.send(:build_file_set_from_hash, id: "ID", file_set_hash: file_set_hash, parent: "parent", file_set_of: "set",
                            file_set_count: "50", file_size: " 75KB", build_mode: "append")).to eq file_set
      end
    end

    context "when build_mode parameter is MODE_MIGRATE and id parameter is present and file_set is found" do
      file_set = OpenStruct.new(title: ["First Title", "Second Title"])
      before {
        allow(subject).to receive(:find_file_set_using_id).with(id: "ID").and_return file_set
        allow(subject).to receive(:log_msg).with("migrate: found file_set with id: ID title: First Title")
      }
      it "logs message and returns file_set" do
        expect(subject).to receive(:find_file_set_using_id).with(id: "ID")
        expect(subject).to receive(:log_msg).with("migrate: found file_set with id: ID title: First Title")

        expect(subject).not_to receive(:find_file_set_using_prior_id).with(prior_id: "ID", parent: "parent")
        expect(subject).not_to receive(:build_depositor)

        expect(subject.send(:build_file_set_from_hash, id: "ID", file_set_hash: file_set_hash, parent: "parent", file_set_of: "set",
                            file_set_count: "50", file_size: " 75KB", build_mode: "migrate")).to eq file_set
      end
    end

    possibilities = [{ :build_mode => "build", :id => "ID", :context_msg => "not MODE_APPEND or MODE_MIGRATE" },
                     { :build_mode => "append", :id => "", :context_msg => "MODE_APPEND and id parameter is blank" },
                     { :build_mode => "migrate", :id => "", :context_msg => "MODE_MIGRATE and id parameter is blank" },
                     { :build_mode => "append", :id => "ID", :context_msg => "MODE_APPEND and FileSet not found", :found => false },
                     { :build_mode => "migrate", :id => "ID", :context_msg => "MODE_MIGRATE and FileSet not found", :found => false }]
    possibilities.each do |possible|
      context "when build_mode parameter is #{possible[:context_msg]} " do
        file_set = MockBuildFileSet.new
        before {
          allow(subject).to receive(:find_file_set_using_prior_id).with(prior_id: possible[:id], parent: "parent").and_return nil
          allow(subject).to receive(:find_file_set_using_id).with(id: possible[:id]).and_return nil

          subject.instance_variable_set(:@verbose, true)
          allow(subject).to receive(:log_verbose_msg).with("#{possible[:build_mode]}: building file set of 50 75KB", verbose: true)
          allow(subject).to receive(:build_depositor).with(hash: file_set_hash).and_return "depositor"
          allow(subject).to receive(:user_key).and_return "user key"
          allow(subject).to receive(:build_file_set_new).with(id: possible[:id], depositor: "depositor", path: "file path", original_name: "original name",
                                                              build_mode: possible[:build_mode], current_user: "user key").and_return file_set
          allow(subject).to receive(:build_date).with(hash: file_set_hash, key: :date_created).and_return "date created"
          allow(subject).to receive(:build_date).with(hash: file_set_hash, key: :date_modified).and_return "date modified"
          allow(subject).to receive(:build_date).with(hash: file_set_hash, key: :date_uploaded).and_return "date uploaded"

          allow(subject).to receive(:build_prior_identifier).with(hash: file_set_hash, id: possible[:id]).and_return "prior identifier"
          allow(subject).to receive(:visibility_from_hash).with(hash: file_set_hash).and_return "visibility"
          allow(subject).to receive(:update_cc_attribute).with( curation_concern: file_set, attribute: :title, value: ["title"] )
          allow(subject).to receive(:update_cc_attribute).with( curation_concern: file_set, attribute: :curation_notes_admin, value: ["admin"] )
          allow(subject).to receive(:update_cc_attribute).with( curation_concern: file_set, attribute: :curation_notes_user, value: ["user"] )
          allow(subject).to receive(:update_cc_attribute).with( curation_concern: file_set, attribute: :prior_identifier, value: "prior identifier" )
          allow(subject).to receive(:update_cc_edit_users).with( curation_concern: file_set, edit_users: ["edit users"])
          allow(subject).to receive(:update_visibility).with(curation_concern: file_set, visibility: "visibility")

          allow(subject).to receive(:build_file_set_ingest).with( file_set: file_set, path: "file path", checksum_algorithm: "algorithm", checksum_value: "checksum value",
                                                                  build_mode: possible[:build_mode]).and_return "build file set ingest"
        }
        it "calls log_verbose_msg, builds and returns new FileSet" do
          expect(subject).to receive(:find_file_set_using_prior_id).with(prior_id: "ID", parent: "parent") if possible[:build_mode] == "append" and possible[:found] == false
          expect(subject).to receive(:find_file_set_using_id).with(id: "ID") if possible[:build_mode] == "migrate" and possible[:found] == false

          expect(subject).not_to receive(:log_msg)

          expect(subject).to receive(:log_verbose_msg).with("#{possible[:build_mode]}: building file set of 50 75KB", verbose: true)
          expect(subject).to receive(:build_file_set_new).with(id: possible[:id], depositor: "depositor", path: "file path", original_name: "original name",
                                                               build_mode: possible[:build_mode], current_user: "user key").and_return file_set
          expect(subject).to receive(:build_prior_identifier).with(hash: file_set_hash, id: possible[:id]).and_return "prior identifier"
          expect(subject).to receive(:visibility_from_hash).with(hash: file_set_hash).and_return "visibility"
          expect(subject).to receive(:update_cc_attribute).with( curation_concern: file_set, attribute: :title, value: ["title"] )
          expect(subject).to receive(:update_cc_attribute).with( curation_concern: file_set, attribute: :curation_notes_admin, value: ["admin"] )
          expect(subject).to receive(:update_cc_attribute).with( curation_concern: file_set, attribute: :curation_notes_user, value: ["user"] )
          expect(file_set).to receive(:label=).with "label"
          expect(file_set).to receive(:date_uploaded=).with "date uploaded"
          expect(file_set).to receive(:date_modified=).with "date modified"
          expect(file_set).to receive(:date_created=).with ["date created"]
          expect(subject).to receive(:update_cc_attribute).with( curation_concern: file_set, attribute: :prior_identifier, value: "prior identifier" )
          expect(subject).to receive(:update_cc_edit_users).with( curation_concern: file_set, edit_users: ["edit users"])
          expect(subject).to receive(:update_visibility).with(curation_concern: file_set, visibility: "visibility")
          expect(file_set).to receive(:save!)
          expect(subject).to receive(:build_file_set_ingest).with( file_set: file_set, path: "file path", checksum_algorithm: "algorithm", checksum_value: "checksum value",
                                                                   build_mode: possible[:build_mode])

          expect(subject.send(:build_file_set_from_hash, id: possible[:id], file_set_hash: file_set_hash, parent: "parent", file_set_of: "set",
                              file_set_count: "50", file_size: " 75KB", build_mode: possible[:build_mode])).to eq "build file set ingest"
        end
      end
    end
  end


  describe "#build_file_set_ingest" do
    before {
      allow(subject).to receive(:log_object).with("file set")
      allow(subject).to receive(:mode).and_return "build"
      allow(subject).to receive(:log_provenance_migrate).with(curation_concern: "file set", build_mode: "build")
      allow(subject).to receive(:ingest_id).and_return "ingest id"
      allow(subject).to receive(:ingester).and_return "ingester"
      allow(subject).to receive(:ingest_timestamp).and_return "ingest timestamp"
      allow(subject).to receive(:user).and_return "user"
      allow(Deepblue::IngestHelper).to receive(:characterize).with( "file set",
                                                                    nil,
                                                                    "path",
                                                                    delete_input_file: false,
                                                                    continue_job_chain: false,
                                                                    current_user: "user",
                                                                    ingest_id: "ingest id",
                                                                    ingester: "ingester",
                                                                    ingest_timestamp: "ingest timestamp" )
      allow(Deepblue::IngestHelper).to receive(:create_derivatives).with( "file set",
                                                                          nil,
                                                                          "path",
                                                                          delete_input_file: false,
                                                                          current_user: "user",
                                                                          ingest_id: "ingest id",
                                                                          ingester: "ingester",
                                                                          ingest_timestamp: "ingest timestamp" )
      allow(subject).to receive(:log_provenance_ingest).with(curation_concern: "file set")
      allow(subject).to receive(:log_msg).with("build: finished: path")
    }

    context "when checksum_algorithm and checksum_value parameters are present" do
      context "when file_set_checksum returns a value equal to the checksum_value parameter" do
        before {
          allow(subject).to receive(:file_set_checksum).with(file_set: "file set").and_return OpenStruct.new(algorithm: "algorithm", value: "checksum value")
          allow(subject).to receive(:log_msg).with "build: checksum succeeded: checksum value"
          allow(subject).to receive(:log_provenance_fixity_check).with(curation_concern: "file set", fixity_check_status: "success", fixity_check_note: "")
        }
        it "ingests file set, logs success message and returns file set" do
          expect(subject).to receive(:log_msg).with "build: checksum succeeded: checksum value"
          expect(subject).to receive(:log_provenance_fixity_check).with(curation_concern: "file set", fixity_check_status: "success", fixity_check_note: "")

          expect(subject).to receive(:log_msg).with("build: finished: path")
          expect(subject.send(:build_file_set_ingest, file_set: "file set", path: "path", checksum_algorithm: "algorithm",
                              checksum_value: "checksum value", build_mode: "build")).to eq "file set"
        end
      end

      context "when file_set_checksum returns a value NOT equal to the checksum_value parameter" do
        before {
          allow(subject).to receive(:file_set_checksum).with(file_set: "file set").and_return OpenStruct.new(algorithm: "algorithm",
                                                                                                             value: "totally different value")
          allow(subject).to receive(:log_msg).with "build: WARNING checksum failed: totally different value vs checksum value"
          allow(subject).to receive(:log_provenance_fixity_check).with(curation_concern: "file set", fixity_check_status: "failed",
                                                                       fixity_check_note: "totally different value vs checksum value")
        }
        it "ingests file set, logs failure message and returns file set" do
          expect(subject).to receive(:log_msg).with "build: WARNING checksum failed: totally different value vs checksum value"
          expect(subject).to receive(:log_provenance_fixity_check).with(curation_concern: "file set", fixity_check_status: "failed",
                                                                       fixity_check_note: "totally different value vs checksum value")

          expect(subject).to receive(:log_msg).with("build: finished: path")
          expect(subject.send(:build_file_set_ingest, file_set: "file set", path: "path", checksum_algorithm: "algorithm",
                              checksum_value: "checksum value", build_mode: "build")).to eq "file set"
        end
      end

      context "when file_set_checksum returns an algorithm NOT equal to the checksum_algorithm parameter" do
        before {
          allow(subject).to receive(:file_set_checksum).with(file_set: "file set").and_return OpenStruct.new(algorithm: "different algorithm altogether")
          allow(subject).to receive(:log_msg).with "build: incompatible checksum algorithms: different algorithm altogether vs algorithm"
          allow(subject).to receive(:log_provenance_fixity_check).with(curation_concern: "file set", fixity_check_status: "failed",
                                                                       fixity_check_note: "incompatible checksum algorithms: different algorithm altogether vs algorithm")
        }
        it "ingests file set, logs failure message and returns file set" do
          expect(subject).to receive(:log_msg).with "build: incompatible checksum algorithms: different algorithm altogether vs algorithm"
          expect(subject).to receive(:log_provenance_fixity_check).with(curation_concern: "file set", fixity_check_status: "failed",
                                                                       fixity_check_note: "incompatible checksum algorithms: different algorithm altogether vs algorithm")
          expect(subject).to receive(:log_msg).with("build: finished: path")

          expect(subject.send(:build_file_set_ingest, file_set: "file set", path: "path", checksum_algorithm: "algorithm", checksum_value: "checksum value",
                              build_mode: "build")).to eq "file set"
        end
      end

      context "when file_set_checksum returns a blank value" do
        before {
          allow(subject).to receive(:file_set_checksum).with(file_set: "file set").and_return nil
          allow(subject).to receive(:log_msg).with "build: file checksum is nil"
        }
        it "ingests file set, logs message for nil and returns file set" do
          expect(subject).to receive(:log_msg).with("build: finished: path")
          expect(subject).not_to receive(:log_provenance_fixity_check)

          expect(subject.send(:build_file_set_ingest, file_set: "file set", path: "path", checksum_algorithm: "algorithm", checksum_value: "checksum value",
                       build_mode: "build")).to eq "file set"
        end
      end

      after {
        expect(subject).to have_received(:file_set_checksum).with(file_set: "file set")
      }
    end

    context "when checksum_algorithm and checksum_value parameters are blank" do
      it "ingests and returns file_set" do
        expect(subject.send(:build_file_set_ingest, file_set: "file set", path: "path", checksum_algorithm: "", checksum_value: "", build_mode: "build")).to eq "file set"
      end
    end

    after {
      expect(subject).to have_received(:log_provenance_migrate).with(curation_concern: "file set", build_mode: "build")
      expect(Deepblue::IngestHelper).to have_received(:characterize).with( "file set",
                                                                            nil,
                                                                            "path",
                                                                            delete_input_file: false,
                                                                            continue_job_chain: false,
                                                                            current_user: "user",
                                                                            ingest_id: "ingest id",
                                                                            ingester: "ingester",
                                                                            ingest_timestamp: "ingest timestamp" )
      expect(Deepblue::IngestHelper).to have_received(:create_derivatives).with( "file set",
                                                                                 nil,
                                                                                 "path",
                                                                                 delete_input_file: false,
                                                                                 current_user: "user",
                                                                                 ingest_id: "ingest id",
                                                                                 ingester: "ingester",
                                                                                 ingest_timestamp: "ingest timestamp" )
      expect(subject).to have_received(:log_provenance_ingest).with(curation_concern: "file set")
    }
  end


  describe "#build_file_set_new" do
    file_set = MockBuildFileSet.new
    file = "file"
    before {
      allow(File).to receive(:open).with("file path").and_return file
      allow(subject).to receive(:upload_file_to_file_set).with(file_set, file)
    }
    context "when build_mode parameter is MODE_MIGRATE" do
      before {
        allow(subject).to receive(:log_msg).with "migrate: processing: file path"
        allow(FileSet).to receive(:new).with(id: 144).and_return file_set
      }
      it "opens file and uploads file to file set with existing id" do
        expect(subject).to receive(:log_msg).with "migrate: processing: file path"
        expect(file).to receive(:define_singleton_method).with(:original_name)
        expect(file).to receive(:define_singleton_method).with(:current_user)
        expect(FileSet).to receive(:new).with(id: 144).and_return file_set
        expect(file_set).to receive(:apply_depositor_metadata).with "depositor"

        expect(subject.send(:build_file_set_new, id: 144, depositor: "depositor", path: "file path", original_name: "original name",
                            build_mode: "migrate", current_user: "user")).to eq file_set
      end
    end

    context "when build_mode parameter is NOT MODE_MIGRATE" do
      before {
        allow(subject).to receive(:log_msg).with "append: processing: file path"
        allow(FileSet).to receive(:new).with(id: nil).and_return file_set
      }
      it "opens file and uploads file to file set" do
        expect(subject).to receive(:log_msg).with "append: processing: file path"
        expect(file).to receive(:define_singleton_method).with(:original_name)
        expect(file).to receive(:define_singleton_method).with(:current_user)
        expect(FileSet).to receive(:new).with(id: nil)
        expect(file_set).to receive(:apply_depositor_metadata).with "depositor"

        expect(subject.send(:build_file_set_new, id: 123, depositor: "depositor", path: "file path", original_name: "original name",
                            build_mode: "append", current_user: "user")).to eq file_set
      end
    end

    after {
      expect(File).to have_received(:open).with("file path")
      expect(subject).to have_received(:upload_file_to_file_set).with(file_set, file)
    }
  end


  describe "#build_fundedby" do
    context "when hash parameter has a fundedby value" do
      it "returns the fundedby value in an array" do
        expect(subject.send(:build_fundedby, hash: {:fundedby => "funded by"})).to eq ["funded by"]
      end
    end

    context "when hash parameter has NO fundedby value" do
      it "returns empty array" do
        expect(subject.send(:build_fundedby, hash: {:purchasedby => "purchased by"})).to be_empty
      end
    end
  end


  describe "#build_or_find_collection" do
    context "when continue_new_content_service evaluates to false" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return false
      }
      it "returns nil" do
        expect(subject.send(:build_or_find_collection, collection_hash: nil)).to be_nil
      end
    end

    context "when continue_new_content_service evaluates to true" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return true
      }
      context "when collection_hash parameter is blank" do
        it "returns nil" do
          expect(subject.send(:build_or_find_collection, collection_hash: "")).to be_nil
        end
      end

      context "when collection_hash parameter is present and id value is blank" do  # mode becomes build
        collection_hash = {:id => "", :mode => "append" }
        context "when build_collection returns nil" do
          before {
            allow(subject).to receive(:build_collection).with(id: "", collection_hash: collection_hash).and_return nil
          }
          it "returns nil" do
            expect(Collection).not_to receive(:find)
            expect(subject).to receive(:build_collection).with(id: "", collection_hash: collection_hash)
            expect(subject).not_to receive(:log_object)
            expect(subject).not_to receive(:add_works_to_collection)
            expect(subject.send(:build_or_find_collection, collection_hash: collection_hash)).to be_nil
          end
        end
      end

      context "when collection_hash parameter is present, id value is NOT blank, and mode value is MODE_APPEND" do
        context "when collection is NOT found" do
          before {
            allow(Collection).to receive(:find).with("99").and_return nil
          }
          collection_hash = {:id => 99, :mode => "append"}
          context "when build_collection returns nil" do
            before {
              allow(subject).to receive(:build_collection).with(id: "99", collection_hash: collection_hash).and_return nil
            }
            it "returns nil" do
              expect(subject).not_to receive(:log_object)
              expect(subject).not_to receive(:add_works_to_collection)
              expect(subject.send(:build_or_find_collection, collection_hash: collection_hash)).to be_nil
            end
          end

          context "when build_collection returns collection" do
            collection = MockBuildCollection.new
            before {
              allow(subject).to receive(:build_collection).with(id: "99", collection_hash: collection_hash).and_return collection
              allow(subject).to receive(:log_object).with collection
              allow(subject).to receive(:add_works_to_collection).with(collection_hash: collection_hash, collection: collection)
            }
            it "returns collection" do
              expect(subject).to receive(:log_object).with collection
              expect(subject).to receive(:add_works_to_collection).with(collection_hash: collection_hash, collection: collection)
              expect(collection).to receive(:save!)
              expect(subject.send(:build_or_find_collection, collection_hash: collection_hash)).to eq collection
            end
          end

          after {
            expect(Collection).to have_received(:find).with("99")
            expect(subject).to have_received(:build_collection).with(id: "99", collection_hash: collection_hash)
          }
        end

        context "when collection is found" do
          collection_hash = {:id => 99, :mode => "append"}
          collection = MockBuildCollection.new
          before {
            allow(Collection).to receive(:find).with("99").and_return collection
            allow(subject).to receive(:log_object).with collection
            allow(subject).to receive(:add_works_to_collection).with(collection_hash: collection_hash, collection: collection)
          }
          it "returns collection" do
            expect(Collection).to receive(:find).with("99")
            expect(subject).not_to receive(:build_collection).with(id: "99", collection_hash: collection_hash)
            expect(subject).to receive(:log_object).with collection
            expect(subject).to receive(:add_works_to_collection).with(collection_hash: collection_hash, collection: collection)
            expect(collection).to receive(:save!)
            expect(subject.send(:build_or_find_collection, collection_hash: {:id => 99, :mode => "append" })).to eq collection
          end
        end
      end

      context "when collection_hash parameter is present, id value is NOT blank, and mode value is MODE_MIGRATE" do
        collection_hash = {:id => 88, :mode => "migrate"}
        context "when build_collection returns nil" do
          before {
            allow(subject).to receive(:build_collection).with(id: "88", collection_hash: collection_hash).and_return nil
          }
          it "returns nil" do
            expect(Collection).not_to receive(:find)
            expect(subject).not_to receive(:log_object)
            expect(subject).not_to receive(:add_works_to_collection)
            expect(subject.send(:build_or_find_collection, collection_hash: collection_hash)).to be_nil
          end
        end

        context "when build_collection returns collection" do
          collection = MockBuildCollection.new
          before {
            allow(subject).to receive(:build_collection).with(id: "88", collection_hash: collection_hash).and_return collection
            allow(subject).to receive(:log_object).with collection
            allow(subject).to receive(:add_works_to_collection).with(collection_hash: collection_hash, collection: collection)
          }
          it "returns collection" do
            expect(Collection).not_to receive(:find)
            expect(subject).to receive(:log_object).with collection
            expect(subject).to receive(:add_works_to_collection).with(collection_hash: collection_hash, collection: collection)
            expect(collection).to receive(:save!)
            expect(subject.send(:build_or_find_collection, collection_hash: collection_hash)).to eq collection
          end
        end

        after {
          expect(subject).to have_received(:build_collection).with(id: "88", collection_hash: collection_hash)
        }
      end
    end

    after {
      expect(subject).to have_received(:continue_new_content_service)
    }
  end


  describe "#build_or_find_user" do
    context "when user_hash parameter is blank" do
      it "returns nil" do
        expect(subject.send(:build_or_find_user, user_hash: "")).to be_nil
      end
    end

    context "when user_hash parameter is present" do
      context "when user is found by email" do
        before {
          allow(User).to receive(:find_by_user_key).with("exampleatimaginarydotorg").and_return "user"
        }
        context "when verbose is true and user_update parameter is false" do
          before {
            allow(subject).to receive(:verbose).and_return true
            allow(subject).to receive(:log_verbose_msg).with("build_or_find_user: email: exampleatimaginarydotorg", verbose: true)
            allow(subject).to receive(:log_verbose_msg).with("found user: user", verbose: true)
            allow(subject).to receive(:log_object).with "user"
          }
          it "returns found user" do
            expect(subject).to receive(:log_verbose_msg).with("build_or_find_user: email: exampleatimaginarydotorg", verbose: true)
            expect(subject).to receive(:log_verbose_msg).with("found user: user", verbose: true)
            expect(subject).to receive(:log_object).with "user"
            expect(subject).not_to receive(:update_user)
            expect(subject).not_to receive(:build_user)
            expect(subject.send(:build_or_find_user, user_hash: {:email => "exampleatimaginarydotorg"}, user_update: false)).to eq "user"
          end
        end

        context "when verbose is false and user_update parameter is true" do
          user_hash = {:email => "exampleatimaginarydotorg"}
          before {
            allow(subject).to receive(:verbose).and_return false
            allow(subject).to receive(:log_verbose_msg).with("build_or_find_user: email: exampleatimaginarydotorg", verbose: false)  # have_received did not work in after block
            allow(subject).to receive(:log_verbose_msg).with("found user: user", verbose: false)
            allow(subject).to receive(:update_user).with(user: "user", user_hash: user_hash )
          }
          it "returns found user" do
            expect(subject).to receive(:log_verbose_msg).with("build_or_find_user: email: exampleatimaginarydotorg", verbose: false)
            expect(subject).not_to receive(:log_object)
            expect(subject).to receive(:log_verbose_msg).with("found user: user", verbose: false)
            expect(subject).to receive(:update_user).with(user: "user", user_hash: user_hash )
            expect(subject).not_to receive(:build_user)

            expect(subject.send(:build_or_find_user, user_hash: user_hash, user_update: true)).to eq "user"
          end
        end

        after {
          expect(User).to have_received(:find_by_user_key).with("exampleatimaginarydotorg")
        }
      end

      context "when user is NOT found by email" do
        user_hash = {:email => "exampleatimaginarydotorg"}

        before {
          allow(subject).to receive(:log_verbose_msg).with("build_or_find_user: email: exampleatimaginarydotorg", verbose: false)
          allow(User).to receive(:find_by_user_key).with("exampleatimaginarydotorg").and_return nil
        }
        context "when build_user returns user" do
          before {
            allow(subject).to receive(:build_user).with(user_hash: user_hash).and_return "built user"
            allow(subject).to receive(:log_object).with("built user")
          }
          it "builds and returns user" do
            expect(subject).to receive(:log_object).with("built user")
            expect(subject.send(:build_or_find_user, user_hash: user_hash)).to eq "built user"
          end
        end

        context "when build_user returns blank result" do
          before {
            allow(subject).to receive(:build_user).with(user_hash: user_hash).and_return nil
          }
          it "returns blank value" do
            expect(subject).not_to receive(:log_object)
            expect(subject.send(:build_or_find_user, user_hash: user_hash)).to be_blank
          end
        end

        after {
          expect(subject).to have_received(:log_verbose_msg).with("build_or_find_user: email: exampleatimaginarydotorg", verbose: false)
          expect(User).to have_received(:find_by_user_key).with("exampleatimaginarydotorg")
          expect(subject).to have_received(:build_user).with(user_hash: user_hash)
        }
      end
    end
  end


  describe "#build_or_find_work" do
    context "when continue_new_content_service returns false" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return false
      }
      it "returns nil" do
        expect(subject.send(:build_or_find_work, work_hash: "work hash", parent: "parent")).to be_nil
      end
    end

    context "when continue_new_content_service returns true" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return true
      }

      context "when work_hash parameter is blank" do
        it "returns nil" do
          expect(subject.send(:build_or_find_work, work_hash: "", parent: "parent")).to be_nil
        end
      end

      context "when work_hash parameter is present" do

        context "when id is blank" do
          work_hash = {:id => nil, :mode => "append"}
          before {
            allow(subject).to receive(:comment_work).with(work_hash: work_hash)
          }
          context "when work is built" do
            before {
              allow(subject).to receive(:log_object).with("built work")
              allow(subject).to receive(:build_work).with(id: "", work_hash: work_hash, parent: "parent").and_return "built work"
              allow(subject).to receive(:add_file_sets_to_work).with(work_hash: work_hash, work: "built work")
              allow(subject).to receive(:add_work_to_parent_ids).with(work_hash: work_hash, work: "built work")
              allow(subject).to receive(:doi_mint).with(curation_concern: "built work")
            }
            it "returns work" do
              expect(subject).to receive(:comment_work).with(work_hash: work_hash)
              expect(subject).not_to receive(:find_work_using_id).with(id: "")
              expect(subject).to receive(:log_object).with("built work")
              expect(subject).to receive(:build_work).with(id: "", work_hash: work_hash, parent: "parent")
              expect(subject).to receive(:add_file_sets_to_work).with(work_hash: work_hash, work: "built work")
              expect(subject).to receive(:add_work_to_parent_ids).with(work_hash: work_hash, work: "built work")
              expect(subject).to receive(:doi_mint).with(curation_concern: "built work")
              expect(subject.send(:build_or_find_work, work_hash: work_hash, parent: "parent")).to eq "built work"
            end
          end
        end

        context "when id is present and mode is MODE_APPEND" do
          work_hash = {:id => 78, :mode => "append"}
          before {
            allow(subject).to receive(:comment_work).with(work_hash: work_hash)
          }

          context "when work is found" do
            before {
              allow(subject).to receive(:find_work_using_id).with(id: "78").and_return "found work"
              allow(subject).to receive(:log_object).with("found work")
              allow(subject).to receive(:add_file_sets_to_work).with(work_hash: work_hash, work: "found work")
              allow(subject).to receive(:add_work_to_parent_ids).with(work_hash: work_hash, work: "found work")
              allow(subject).to receive(:doi_mint).with(curation_concern: "found work")
            }
            it "returns work" do
              expect(subject).to receive(:log_object).with("found work")
              expect(subject).to receive(:add_file_sets_to_work).with(work_hash: work_hash, work: "found work")
              expect(subject).to receive(:add_work_to_parent_ids).with(work_hash: work_hash, work: "found work")
              expect(subject).to receive(:doi_mint).with(curation_concern: "found work")
              expect(subject).not_to receive(:build_work)
              expect(subject.send(:build_or_find_work, work_hash: work_hash, parent: "parent")).to eq "found work"
            end
          end

          context "when work is NOT found or built" do
            before {
              allow(subject).to receive(:find_work_using_id).with(id: "78").and_return nil
              allow(subject).to receive(:build_work).with(id: "78", work_hash: work_hash, parent: "parent").and_return nil
            }
            it "returns nil" do
              expect(subject).to receive(:build_work).with(id: "78", work_hash: work_hash, parent: "parent")

              expect(subject).not_to receive(:log_object)
              expect(subject).not_to receive(:add_file_sets_to_work)
              expect(subject).not_to receive(:add_work_to_parent_ids)
              expect(subject).not_to receive(:doi_mint)

              expect(subject.send(:build_or_find_work, work_hash: work_hash, parent: "parent")).to be_nil
            end

            after {
              expect(subject).to have_received(:comment_work).with(work_hash: work_hash)
              expect(subject).to have_received(:find_work_using_id).with(id: "78")
            }
          end
        end
      end
    end

    after {
      expect(subject).to have_received(:continue_new_content_service)
    }
  end


  describe "#build_prior_identifier" do
    context "when source is SOURCE_DBDv1" do
      before {
        allow(subject).to receive(:source).and_return "DBDv1"
      }

      context "when mode is MODE_MIGRATE" do
        before {
          allow(subject).to receive(:mode).and_return "migrate"
        }
        it "returns empty array" do
          expect(subject.send(:build_prior_identifier, hash: nil, id: nil)).to be_empty
        end
      end

      context "when mode is NOT MODE_MIGRATE" do
        before {
          allow(subject).to receive(:mode).and_return "append"
        }
        it "returns array of id parameter" do
          expect(subject.send(:build_prior_identifier, hash: nil, id: 22)).to eq [22]
        end
      end
    end

    context "when source is NOT SOURCE_DBDv1" do
      before {
        allow(subject).to receive(:source).and_return "DBDv2"
      }

      context "when mode is NOT MODE_MIGRATE" do
        before {
          allow(subject).to receive(:mode).and_return "build"
        }
        it "returns prior_identifier hash parameter value and id parameter as an array" do
          expect(subject.send(:build_prior_identifier, hash: {:prior_identifier => "a priori"}, id: 23)).to eq ["a priori", 23]
        end
      end

      context "when mode is MODE_MIGRATE" do
        before {
          allow(subject).to receive(:mode).and_return "migrate"
        }
        it "returns prior_identifier hash parameter value as an array" do
          expect(subject.send(:build_prior_identifier, hash: {:prior_identifier => "a priori"}, id: 23)).to eq ["a priori"]
        end
      end
    end

    after {
      expect(subject).to have_received(:source)
      expect(subject).to have_received(:mode)
    }
  end


  describe "#build_referenced_by" do
    context "when source is SOURCE_DBDv1" do
      before {
        allow(subject).to receive(:source).and_return "DBDv1"
      }
      it "returns isReferencedBy value of hash parameter as an array" do
        expect(subject.send(:build_referenced_by, hash: {:isReferencedBy => "scholarly tome"})).to eq ["scholarly tome"]
      end
    end

    context "when source is NOT SOURCE_DBDv1" do
      before {
        allow(subject).to receive(:source).and_return "DBDv2"
      }
      it "returns referenced_by value of hash parameter" do
        expect(subject.send(:build_referenced_by, hash: {:referenced_by => "academic journal"})).to eq "academic journal"
      end
    end

    after {
      expect(subject).to have_received(:source)
    }
  end


  describe "#build_rights_license" do
    context "when source is SOURCE_DBDv1" do
      before {
        allow(subject).to receive(:source).and_return "DBDv1"
      }
      it "returns rights value of hash parameter" do
        expect(subject.send(:build_rights_license, hash: {:rights => ["all rights reserved", "so be it"]})).to eq "all rights reserved"
      end
    end

    context "when source is NOT SOURCE_DBDv1" do
      before {
        allow(subject).to receive(:source).and_return "DBDv2"
      }
      it "returns rights_license value of hash parameter" do
        expect(subject.send(:build_rights_license, hash: {:rights_license => "some rights reserved"})).to eq "some rights reserved"
      end
    end

    after {
      expect(subject).to have_received(:source)
    }
  end


  describe "#build_subject_discipline" do
    context "when source is SOURCE_DBDv1" do
      before {
        allow(subject).to receive(:source).and_return "DBDv1"
      }
      it "returns subject value of hash parameter as an array" do
        expect(subject.send(:build_subject_discipline, hash: {:subject => "subjectivity"})).to eq ["subjectivity"]
      end
    end

    context "when source is NOT SOURCE_DBDv1" do
      before {
        allow(subject).to receive(:source).and_return "DBDv2"
      }
      it "returns subject_discipline value of hash parameter as an array" do
        expect(subject.send(:build_subject_discipline, hash: {:subject_discipline => "objectivity"})).to eq ["objectivity"]
      end
    end

    after {
      expect(subject).to have_received(:source)
    }
  end


  describe "#build_time" do
    context "when value parameter is nil" do
      it "returns empty string" do
        expect(subject.send(:build_time, value: nil)).to be_blank
      end
    end

    new_year = Time.new(2026, 1, 1, 8, 0, 0)
    potential_times = [{:object => new_year, :object_as_time => new_year},
                       {:object => "2025-12-31T05:00:00+00:00", :object_as_time => Time.new(2025, 12, 31, 5, 0, 0 )}]
    potential_times.each do |potential_time|
      context "when value parameter is a #{potential_time[:object].class} object" do
        before {
          allow(Time).to receive(:parse).with("2025-12-31T05:00:00+00:00").and_return Time.new(2025, 12, 31, 5, 0, 0 )
        }
        it "returns value parameter as a Time object" do
          expect(subject.send(:build_time, value: potential_time[:object])).to eq potential_time[:object_as_time]
        end
      end
    end

    context "when value parameter cannot be parsed to a Time object" do
      it "returns empty string" do
        expect(subject.send(:build_time, value: "apple")).to be_blank
      end
    end
  end


  describe "#build_user" do
    new_user = MockCreatedUser.new
    before {
      allow(subject).to receive(:log_msg).with "User.new( newuseratexampledotcom )"
      allow(User).to receive(:new).with(email: "newuseratexampledotcom", password: 'password').and_return new_user
      allow(subject).to receive(:update_user).with(user: "newuser", user_hash: {:email => "newuseratexampledotcom"})
    }
    it "creates new user and logs message" do
      expect(subject).to receive(:log_msg).with "User.new( newuseratexampledotcom )"
      expect(User).to receive(:new).with(email: "newuseratexampledotcom", password: 'password')
      expect(subject).to receive(:update_user).with(user: new_user, user_hash: {:email => "newuseratexampledotcom"})
      subject.send(:build_user, user_hash: {:email => "newuseratexampledotcom"})
    end

    skip "add test for u.save( validate: false )"
  end


  describe "#build_users" do
    context "when users returns nil" do
      before {
        allow(subject).to receive(:users).and_return nil
      }
      it "returns nil" do
        expect(subject).not_to receive(:log_verbose_msg)
        expect(subject.send(:build_users)).to be_nil
      end
    end

    context "when users returns a value" do
      before {
        allow(subject).to receive(:users).and_return [{:user_emails => ""}, {:user_emails => ["email1", "email2"], :user_email1 => "user_hash_1"}]
        allow(subject).to receive(:verbose).and_return "verbose"
        #allow(subject).to receive(:log_verbose_msg).with("users_hash: {:user_emails=> [\"email1","email2\"], :user_email1 => \"user_hash_1\"}", verbose: "verbose")
        allow(subject).to receive(:log_verbose_msg).with("processing user: email1", verbose: "verbose")
        allow(subject).to receive(:log_verbose_msg).with("user_email_id: :user_email1", verbose: "verbose")
        allow(subject).to receive(:log_verbose_msg).with("user_hash: user_hash_1", verbose: "verbose")
        allow(subject).to receive(:build_or_find_user).with(user_hash: "user_hash_1").and_return "user1"
        allow(subject).to receive(:log_object).with "user1"
        allow(Benchmark).to receive(:measure).and_return "measurement"
      }
      it "calls Benchmark.measure and returns result" do
        expect(Benchmark).to receive(:measure).and_return "measurement"

        expect(subject.send(:build_users)).to eq "measurement"
      end

      skip "test log verbose msg for users_hash"
      skip "test inside Benchmark.measure"
    end

    after {
      expect(subject).to have_received(:users)
    }
  end


  describe "#build_work" do
    context "when continue_new_content_service evaluates to false" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return false
      }
      it "returns nil" do
        expect(subject.send(:build_work, id: nil, work_hash: nil, parent: nil)).to be_nil
      end
    end

    context "when continue_new_content_service evaluates to true" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return true
      }
      context "when find_existing_work returns a value" do
        before {
          allow(subject).to receive(:find_existing_work).with(id: "hola", parent: "madre").and_return "work"
        }
        it "returns value" do
          expect(subject.send(:build_work, id: "hola", work_hash: nil, parent: "madre")).to eq "work"
        end
      end

      context "when find_existing_work does NOT return a value" do
        work_hash = {:authoremail => "author email", :contributor => "contributor", :creator => "creator", :curation_notes_admin => "curation notes admin",
                     :curation_notes_user => "curation notes user", :description => "description", :edit_users => "edit users",
                     :fundedby_other => "fundedby other", :grantnumber => "grant number", :language => "language", :keyword => "keyword",
                     :methodology => "methodology", :resource_type => "resource type", :rights_license_other => "rights license other",
                     :title => "title"}
        new_work = MockBuildWork.new

        before {
          allow(subject).to receive(:find_existing_work).with(id: "bonjour", parent: "papa").and_return ""
          allow(subject).to receive(:build_date_coverage).with(hash: work_hash).and_return "date coverage"
          allow(subject).to receive(:build_date).with(hash: work_hash, key: :date_created).and_return "date created"
          allow(subject).to receive(:build_date).with(hash: work_hash, key: :date_modified).and_return "date modified"
          allow(subject).to receive(:build_date).with(hash: work_hash, key: :date_published).and_return "date published"
          allow(subject).to receive(:build_date).with(hash: work_hash, key: :date_uploaded).and_return "date uploaded"
          allow(subject).to receive(:default_description).with("description").and_return "work description"
          allow(subject).to receive(:build_doi).with(hash: work_hash).and_return "doi built"
          allow(subject).to receive(:build_fundedby).with(hash: work_hash).and_return "build funded by"
          allow(subject).to receive(:default_methodology).with("methodology").and_return "work methodology"
          allow(subject).to receive(:build_prior_identifier).with(hash: work_hash, id: "bonjour").and_return "build prior identifier"
          allow(subject).to receive(:build_referenced_by).with(hash: work_hash).and_return "build referenced by"
          allow(subject).to receive(:default_work_resource_type).with(resource_type: work_hash[:resource_type]).and_return ["resource type"]
          allow(subject).to receive(:build_rights_license).with(hash: work_hash).and_return "rights license"
          allow(subject).to receive(:build_subject_discipline).with(hash: work_hash).and_return "subject discipline"
          allow(subject).to receive(:user_create_users).with(emails: "author email")

          allow(subject).to receive(:build_depositor).with(hash: work_hash).and_return "build depositor"
          allow(subject).to receive(:update_cc_edit_users).with(curation_concern: new_work, edit_users: ["edit users"])
          allow(subject).to receive(:build_admin_set_work).with(hash: work_hash).and_return "build admin set work"
          allow(subject).to receive(:apply_visibility_and_workflow).with(work: new_work, work_hash: work_hash, admin_set: "build admin set work")
          allow(subject).to receive(:log_provenance_migrate).with(curation_concern: new_work, build_mode: "migrate")
          allow(subject).to receive(:log_provenance_ingest).with(curation_concern: new_work)
        }
        context "when mode is MODE_MIGRATE" do
          before {
            allow(subject).to receive(:mode).and_return "migrate"
            allow(DataSet).to receive(:new).with(authoremail: "author email",
                                                 contributor: ["contributor"],
                                                 creator: ["creator"],
                                                 curation_notes_admin: ["curation notes admin"],
                                                 curation_notes_user: ["curation notes user"],
                                                 date_coverage: "date coverage",
                                                 date_created: "date created",
                                                 date_modified: "date modified",
                                                 date_published: "date published",
                                                 date_uploaded: "date uploaded",
                                                 description: "work description",
                                                 doi: "doi built",
                                                 fundedby: "build funded by",
                                                 fundedby_other: "fundedby other",
                                                 grantnumber: "grant number",
                                                 id: "bonjour",
                                                 keyword: ["keyword"],
                                                 language: ["language"],
                                                 methodology: "work methodology",
                                                 prior_identifier: "build prior identifier",
                                                 referenced_by: "build referenced by",
                                                 resource_type: ["resource type"],
                                                 rights_license: "rights license",
                                                 rights_license_other: "rights license other",
                                                 subject_discipline: "subject discipline",
                                                 title: ["title"]).and_return new_work
          }
          it "returns new work with id set to id parameter" do
            expect(subject).to receive(:find_existing_work).with(id: "bonjour", parent: "papa")
            expect(DataSet).to receive(:new).with(authoremail: "author email",
                                                  contributor: ["contributor"],
                                                  creator: ["creator"],
                                                  curation_notes_admin: ["curation notes admin"],
                                                  curation_notes_user: ["curation notes user"],
                                                  date_coverage: "date coverage",
                                                  date_created: "date created",
                                                  date_modified: "date modified",
                                                  date_published: "date published",
                                                  date_uploaded: "date uploaded",
                                                  description: "work description",
                                                  doi: "doi built",
                                                  fundedby: "build funded by",
                                                  fundedby_other: "fundedby other",
                                                  grantnumber: "grant number",
                                                  id: "bonjour",
                                                  keyword: ["keyword"],
                                                  language: ["language"],
                                                  methodology: "work methodology",
                                                  prior_identifier: "build prior identifier",
                                                  referenced_by: "build referenced by",
                                                  resource_type: ["resource type"],
                                                  rights_license: "rights license",
                                                  rights_license_other: "rights license other",
                                                  subject_discipline: "subject discipline",
                                                  title: ["title"]).and_return new_work
            expect(subject).to receive(:log_provenance_migrate).with(curation_concern: new_work, build_mode: "migrate")
            expect(new_work).to receive(:apply_depositor_metadata).with("build depositor")
            expect(new_work).to receive(:owner=).with("build depositor")
            expect(new_work).to receive(:update).with(admin_set: "build admin set work")
            expect(new_work).to receive(:save!)
            expect(new_work).to receive(:reload)
            expect(subject.send(:build_work, id: "bonjour", work_hash: work_hash, parent: "papa")).to eq new_work
          end
        end

        context "when mode is NOT MODE_MIGRATE" do
          before {
            allow(subject).to receive(:mode).and_return "build"
            allow(DataSet).to receive(:new).with(authoremail: "author email",
                                                 contributor: ["contributor"],
                                                 creator: ["creator"],
                                                 curation_notes_admin: ["curation notes admin"],
                                                 curation_notes_user: ["curation notes user"],
                                                 date_coverage: "date coverage",
                                                 date_created: "date created",
                                                 date_modified: "date modified",
                                                 date_published: "date published",
                                                 date_uploaded: "date uploaded",
                                                 description: "work description",
                                                 doi: "doi built",
                                                 fundedby: "build funded by",
                                                 fundedby_other: "fundedby other",
                                                 grantnumber: "grant number",
                                                 id: nil,
                                                 keyword: ["keyword"],
                                                 language: ["language"],
                                                 methodology: "work methodology",
                                                 prior_identifier: "build prior identifier",
                                                 referenced_by: "build referenced by",
                                                 resource_type: ["resource type"],
                                                 rights_license: "rights license",
                                                 rights_license_other: "rights license other",
                                                 subject_discipline: "subject discipline",
                                                 title: ["title"]).and_return new_work
          }
          it "returns new work ignoring id parameter" do
            expect(DataSet).to receive(:new).with(authoremail: "author email",
                                                  contributor: ["contributor"],
                                                  creator: ["creator"],
                                                  curation_notes_admin: ["curation notes admin"],
                                                  curation_notes_user: ["curation notes user"],
                                                  date_coverage: "date coverage",
                                                  date_created: "date created",
                                                  date_modified: "date modified",
                                                  date_published: "date published",
                                                  date_uploaded: "date uploaded",
                                                  description: "work description",
                                                  doi: "doi built",
                                                  fundedby: "build funded by",
                                                  fundedby_other: "fundedby other",
                                                  grantnumber: "grant number",
                                                  id: nil,
                                                  keyword: ["keyword"],
                                                  language: ["language"],
                                                  methodology: "work methodology",
                                                  prior_identifier: "build prior identifier",
                                                  referenced_by: "build referenced by",
                                                  resource_type: ["resource type"],
                                                  rights_license: "rights license",
                                                  rights_license_other: "rights license other",
                                                  subject_discipline: "subject discipline",
                                                  title: ["title"])
            expect(subject).to receive(:log_provenance_migrate).with(curation_concern: new_work, build_mode: "build")
            expect(new_work).to receive(:apply_depositor_metadata).with("build depositor")
            expect(new_work).to receive(:owner=).with("build depositor")
            expect(new_work).to receive(:update).with(admin_set: "build admin set work")
            expect(new_work).to receive(:save!)
            expect(new_work).to receive(:reload)
            expect(subject.send(:build_work, id: "bonjour", work_hash: work_hash, parent: "papa")).to eq new_work
          end
        end

        after {
          expect(subject).to have_received(:continue_new_content_service)
          expect(subject).to have_received(:build_date_coverage).with(hash: work_hash)
          expect(subject).to have_received(:build_date).with(hash: work_hash, key: :date_created)
          expect(subject).to have_received(:build_date).with(hash: work_hash, key: :date_modified)
          expect(subject).to have_received(:build_date).with(hash: work_hash, key: :date_published)
          expect(subject).to have_received(:build_date).with(hash: work_hash, key: :date_uploaded)
          expect(subject).to have_received(:default_description).with("description")
          expect(subject).to have_received(:build_doi).with(hash: work_hash)
          expect(subject).to have_received(:build_fundedby).with(hash: work_hash)
          expect(subject).to have_received(:default_methodology).with("methodology")
          expect(subject).to have_received(:build_prior_identifier).with(hash: work_hash, id: "bonjour")
          expect(subject).to have_received(:build_referenced_by).with(hash: work_hash)
          expect(subject).to have_received(:default_work_resource_type).with(resource_type: work_hash[:resource_type])
          expect(subject).to have_received(:build_rights_license).with(hash: work_hash)
          expect(subject).to have_received(:build_subject_discipline).with(hash: work_hash)
          expect(subject).to have_received(:mode).twice
          expect(subject).to have_received(:user_create_users).with(emails: "author email")

          expect(subject).to have_received(:build_depositor).with(hash: work_hash)
          expect(subject).to have_received(:update_cc_edit_users).with(curation_concern: new_work, edit_users: ["edit users"])
          expect(subject).to have_received(:build_admin_set_work).with(hash: work_hash)
          expect(subject).to have_received(:apply_visibility_and_workflow).with(work: new_work, work_hash: work_hash, admin_set: "build admin set work")
          expect(subject).to have_received(:log_provenance_ingest).with(curation_concern: new_work)
        }
      end
    end
  end


  describe "find_existing_work" do
    attempts = [{:mode => "append", id: ""}, {:mode => "migrate", id: ""}, {:mode => "update", id: "606"} ]
    attempts.each do |attempt|
      context "when mode is #{attempt[:mode]} and id parameter is #{attempt[:id]}" do
        before {
          allow(subject).to receive(:mode).and_return attempt[:mode]
        }
        it "returns nil" do
          expect(subject).to receive(:mode)
          expect(subject.send(:find_existing_work, id: attempt[:id])).to be_nil
        end
      end
    end

    context "when mode is MODE_APPEND and id parameter is present" do
      before {
        allow(subject).to receive(:mode).and_return "append"
      }
      context "when work is found" do
        work = OpenStruct.new(title: ["work 88"])
        before {
          allow(subject).to receive(:find_work_using_prior_id).with( prior_id: 88, parent: "parent" ).and_return work
          allow(subject).to receive(:log_msg).with "append: found work with prior id: 88 title: work 88"
        }
        it "returns work" do
          expect(subject).to receive(:mode).twice
          expect(subject).to receive(:log_msg).with "append: found work with prior id: 88 title: work 88"

          expect(subject.send(:find_existing_work, id: 88, parent: "parent")).to eq work
        end
      end

      context "when work is NOT found" do
        before {
          allow(subject).to receive(:find_work_using_prior_id).with( prior_id: 88, parent: "parent" ).and_return nil
        }
        it "returns nil" do
          expect(subject).to receive(:mode)
          expect(subject).not_to receive(:log_msg)

          expect(subject.send(:find_existing_work, id: 88, parent: "parent")).to be_nil
        end
      end

      after {
        expect(subject).to have_received(:find_work_using_prior_id).with( prior_id: 88, parent: "parent" )
      }
    end

    context "when mode is MODE_MIGRATE and id parameter is present" do
      before {
        allow(subject).to receive(:mode).and_return "migrate"
      }
      context "when work is found" do
        work = OpenStruct.new(title: ["work 4"])
        before {
          allow(subject).to receive(:find_work_using_id).with( id: 4 ).and_return work
          allow(subject).to receive(:log_msg).with "migrate: found work with id: 4 title: work 4"
        }
        it "returns work" do
          expect(subject).to receive(:mode).thrice
          expect(subject).to receive(:log_msg).with "migrate: found work with id: 4 title: work 4"

          expect(subject.send(:find_existing_work, id: 4, parent: "parent")).to eq work
        end
      end

      context "when work is NOT found" do
        before {
          allow(subject).to receive(:find_work_using_id).with( id: 4 ).and_return nil
        }
        it "returns nil" do
          expect(subject).to receive(:mode).twice
          expect(subject).not_to receive(:log_msg)

          expect(subject.send(:find_existing_work, id: 4)).to be_nil
        end
      end

      after {
        expect(subject).to have_received(:find_work_using_id)
      }
    end
  end


  describe "#default_work_resource_type" do
    works = [{:resource_type => nil, :expected_result => ["Dataset"]},
             {:resource_type => "resource type", :expected_result => ["resource type"]}]

    works.each do |work|
      context "when resource_type is equal to #{work[:resource_type]}" do
        it "returns #{work[:expected_result]}" do
          expect(subject.send(:default_work_resource_type, resource_type: work[:resource_type])).to eq work[:expected_result]
        end
      end
    end
  end


  describe '#build_works' do
    context "when works returns nil" do
      before {
        allow(subject).to receive(:works).and_return nil
      }
      it "returns nil" do
        expect(subject).to receive(:works).once

        expect(subject).not_to receive(:continue_new_content_service)
        expect(subject.send(:build_works)).to be_nil
      end
    end

    context "when works returns result(s)" do
      before {
        allow(subject).to receive(:works).and_return ["work_hash_1", "work_hash_2"]
        allow(subject).to receive(:user_key).and_return "user_key"
        allow(subject).to receive(:user_create_users).with(emails: "user_key")
      }

      context "when continue_new_content_service evaluates to false" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return false
        }

        it "returns without further processing" do
          expect(subject).not_to receive(:build_or_find_work)
          subject.send(:build_works)
        end
      end

      context "when continue_new_content_service evaluates to true" do
        measurement = MockMeasurement.new
        work2 = OpenStruct.new(id: 2)
        before {
          allow(subject).to receive(:continue_new_content_service).and_return true
          allow(Benchmark).to receive(:measure).and_return measurement
          allow(subject).to receive(:build_or_find_work).with(work_hash: "work_hash_1", parent: nil).and_return nil
          allow(subject).to receive(:build_or_find_work).with(work_hash: "work_hash_2", parent: nil).and_return work2
          allow(subject).to receive(:log_object).with work2
          allow(subject).to receive(:add_measurement).with measurement
        }

        it "calls Benchmark.measure" do
          expect(Benchmark).to receive(:measure)
          subject.send(:build_works)
        end

        skip "add tests for functions inside Benchmark.measure"
      end

      after {
        expect(subject).to have_received(:works).twice
        expect(subject).to have_received(:continue_new_content_service).twice

        expect(subject).to have_received(:user_create_users).with(emails: "user_key")
      }
    end
  end


  describe "#collections" do
    context "when @collections returns a value" do
      before {
        subject.instance_variable_set(:@collections, ["collection"])
      }
      it "returns the value of @collections" do
        expect(subject.send(:collections)).to eq ["collection"]
      end
    end

    context "when @collections returns nil" do
      before {
        subject.instance_variable_set(:@collections, nil)
        subject.instance_variable_set(:@cfg_hash, {:user => "user"})
        allow(subject).to receive(:collections_from_hash).with(hash: "user").and_return("collections from hash")
      }
      it "sets @collections to collections_from_hash and returns the result" do
        expect(subject.send(:collections)).to eq "collections from hash"
        expect(subject.instance_variable_get(:@collections)).to eq "collections from hash"
      end
    end
  end


  describe "#collections_from_hash" do
    it "returns collections value from hash parameter as an array" do
      expect(subject.send(:collections_from_hash, hash: {:collections => "collected thus"})).to eq ["collected thus"]
    end
  end


  describe "#cfg_hash_value" do
    before {
      subject.instance_variable_set(:@cfg_hash, {:config => {:child => "hiya"}})
    }

    context "when @cfg_hash has the base_key parameter as one of its keys" do
      context "when @cfg_hash[base_key] has the key parameter as one of its keys" do
        it "returns @cfg_hash[base_key][key] value" do
          expect(subject.send(:cfg_hash_value, base_key: :config, key: :child, default_value: "")).to eq "hiya"
        end
      end

      context "when @cfg_hash[base_key] does NOT have the key parameter as one of its keys" do
        it "returns the default_value parameter" do
          expect(subject.send(:cfg_hash_value, base_key: :config, key: :minor, default_value: "yo")).to eq "yo"
        end
      end
    end

    context "when @cfg_hash does NOT have the base_key parameter as a key" do
      it "returns the default_value parameter" do
        expect(subject.send(:cfg_hash_value, base_key: :log, key: nil, default_value: "hey")).to eq "hey"
      end
    end
  end


  describe "#diff_attr" do
    context "when calling diff_attr? with the attr_name parameter returns false" do
      before {
        allow(subject).to receive(:diff_attr?).with("attr_name").and_return false
      }
      it "returns diffs parameter" do
        expect(subject).not_to receive(:value_from_attr)
        expect(subject.send(:diff_attr, "diffs", "cc_or_fs", "cc_or_fs_hash", attr_name: "attr_name")).to eq "diffs"
      end
    end

    context "when calling diff_attr? with the attr_name parameter returns true" do
      before {
        allow(subject).to receive(:diff_attr?).with("attr_name").and_return true
        allow(subject).to receive(:value_from_attr).with("cc_or_fs_hash", attr_name: "attr_name", attr_name_hash: nil, multi: true).and_return "value from attr"
      }

      context "when diff_attr_if_blank? returns false" do
        before {
          allow(subject).to receive(:attr_current_time).with("attr_current", "value from attr").and_return ["attr current", "current value"]
          allow(subject).to receive(:diff_attr_if_blank?).with("attr_name", value: "current value").and_return false
        }
        it "returns diffs" do
          expect(subject).to receive(:diff_attr_if_blank?).with("attr_name", value: "current value")

          expect(subject.send(:diff_attr, "diffs", {"attr_name" => "attr_current"}, "cc_or_fs_hash", attr_name: "attr_name")).to eq "diffs"
        end
      end

      context "when diff_attr_if_blank? returns true" do
        before {
          allow(subject).to receive(:diff_attr_if_blank?).with("attr_name", value: "same value").and_return true
        }

        context "when time values have NO difference" do
          before {
            allow(subject).to receive(:attr_current_time).with("attr_current", "value from attr").and_return ["same value", "same value"]
          }
          it "returns diffs" do
            expect(subject).not_to receive(:attr_prefix)
            expect(subject.send(:diff_attr, "diffs", {"attr_name" => "attr_current"}, "cc_or_fs_hash", attr_name: "attr_name")).to eq "diffs"
          end
        end

        context "when time values do have a difference" do
          before {
            allow(subject).to receive(:attr_current_time).with("attr_current", "value from attr").and_return ["different value", "same value"]
            allow(subject).to receive(:attr_prefix).with({"attr_name" => "attr_current"}).and_return " prefix"
          }
          it "returns diffs with message appended" do
            expect(subject).to receive(:attr_prefix).with({"attr_name" => "attr_current"})

            expect(subject.send(:diff_attr, "diffs", {"attr_name" => "attr_current"}, "cc_or_fs_hash", attr_name: "attr_name"))
              .to eq "diffs prefix: attr_name 'different value' vs. 'same value'"
          end
        end

        after {
          expect(subject).to have_received(:diff_attr_if_blank?).with("attr_name", value: "same value")
        }
      end

      context "when diff_attr_if_blank? raises an error" do
        before {
          allow(subject).to receive(:attr_current_time).with("attr_current", "value from attr").and_return ["attr current", "current value"]
          allow(subject).to receive(:diff_attr_if_blank?).with("attr_name", value: "current value").and_raise(Exception, "blank attr exception")
          allow(subject).to receive(:attr_prefix).with({"attr_name" => "attr_current"}).and_return " prefix"
        }
        it "returns diffs with error message appended" do
          expect(subject).to receive(:diff_attr_if_blank?).with("attr_name", value: "current value")
          expect(subject).to receive(:attr_prefix).with({"attr_name" => "attr_current"}).and_return " prefix"

          result = subject.send(:diff_attr, "diffs", {"attr_name" => "attr_current"}, "cc_or_fs_hash", attr_name: "attr_name")
          expect(result.start_with?("diffs prefix: attr_name -- Exception: Exception: blank attr exception at ")).to eq true
        end
      end

      after {
        expect(subject).to have_received(:value_from_attr).with("cc_or_fs_hash", attr_name: "attr_name", attr_name_hash: nil, multi: true)
        expect(subject).to have_received(:attr_current_time).with("attr_current", "value from attr")
      }
    end

    after {
      expect(subject).to have_received(:diff_attr?).with("attr_name")
    }
  end


  describe "#value_from_attr" do
    hash_it_out = [{:attr_name_hash => "", :desc => "blank", :multi => true, :result => ["pineapple"], :return_value => "attr_name"},
                   {:attr_name_hash => "", :desc => "blank", :multi => false, :result => "pineapple", :return_value => "attr_name"},
                   {:attr_name_hash => :attr_name_hash, :desc => "present", :multi => true, :result => ["papaya"], :return_value => "attr_name_hash"},
                   {:attr_name_hash => :attr_name_hash, :desc => "present", :multi => false, :result => "papaya", :return_value => "attr_name_hash"}]
    hash_it_out.each do |hash|
      context "when attr_name_hash parameter is #{hash[:desc]} and multi parameter is #{hash[:multi]}" do
        it "returns #{hash[:return_value]} parameter value #{hash[:multi] ? 'in an array' : ''}" do
          expect(subject.send(:value_from_attr, {:attr_name => "pineapple", :attr_name_hash => "papaya"}, attr_name: :attr_name,
                              attr_name_hash: hash[:attr_name_hash], multi: hash[:multi])).to eq hash[:result]
        end
      end
    end
  end


  describe "#attr_current_time" do
    context "when attr_current parameter is a Time object" do
      attr_current = Time.new(2026, 1, 1, 0, 0, 0.123456)
      context "when calling build_time on value parameter returns a Time object" do
        before {
          allow(subject).to receive(:build_time).with(value: "value").and_return Time.new(2025, 12, 13, 23, 59, 59.123456)
        }

        it "sets the attr_current parameter's microseconds to zero and sets the result of build_time's microseconds to zero" do
          expect(subject.send(:attr_current_time, attr_current, "value"))
            .to eq [Time.new(2026, 1, 1), Time.new(2025, 12, 13, 23, 59, 59)]
        end
      end

      context "when calling build_time on the value parameter does NOT return a Time object" do
        before {
          allow(subject).to receive(:build_time).with(value: "value").and_return "built value"
        }
        it "sets the attr_current parameter's microseconds to zero and returns it and the built value parameter" do
          expect(subject.send(:attr_current_time, attr_current, "value")).to eq [Time.new(2026, 1, 1), "built value"]
        end
      end

      after {
        expect(subject).to have_received(:build_time).with(value: "value")
      }
    end

    context "when attr_current parameter is NOT a Time object" do
      it "returns parameters unchanged" do
        expect(subject).not_to receive(:build_time)

        expect(subject.send(:attr_current_time, "attr current", "value")).to eq ["attr current", "value"]
      end
    end
  end


  describe "#diff_attr?" do
    context "when diff_attrs_skip does not include the attribute name" do
      before {
        allow(subject).to receive(:diff_attrs_skip).and_return ["other_name"]
      }
      it "returns true" do
        expect(subject.send(:diff_attr?, "attr_name")).to eq true
      end
    end

    context "when diff_attrs_skip includes the attribute name" do
      before {
        allow(subject).to receive(:diff_attrs_skip).and_return ["attr_name", "other_name"]
      }
      it "returns false" do
        expect(subject.send(:diff_attr?, "attr_name")).to eq false
      end
    end

    after {
      expect(subject).to have_received(:diff_attrs_skip)
    }
  end


  describe "#diff_attr_if_blank?" do
    diff_attrs = [{:attribute => "attr_name", :valued => "", :expected_result => false},
                  {:attribute => "other_name", :valued => "something", :expected_result => true},
                  {:attribute => "attr_name", :valued => "a thing", :expected_result => true},
                  {:attribute => "other_name", :valued => nil, :expected_result => true}]
    diff_attrs.each do |diff_attr|
      context "when diff_attrs_skip_if_blank #{diff_attr[:attribute] == "attr_name" ? "includes" : "does NOT include"} the attr_name parameter and the value parameter is #{diff_attr[:valued].blank? ? "" : "NOT"} blank" do
        before {
          allow(subject).to receive(:diff_attrs_skip_if_blank).and_return ["attr_name"]
        }
        it "returns #{diff_attr[:expected_result]}" do
          if ( diff_attr[:valued].blank? )
            expect(subject).to receive(:diff_attrs_skip_if_blank)
          else
            expect(subject).not_to receive(:diff_attrs_skip_if_blank)
          end

          expect(subject.send(:diff_attr_if_blank?, diff_attr[:attribute], value: diff_attr[:valued])).to eq diff_attr[:expected_result]
        end
      end
    end
  end


  describe "#diff_attr_value" do
    context "when diff_attr? attr_name parameter returns false" do
      before {
        allow(subject).to receive(:diff_attr?).with("attr_name").and_return false
      }
      it "returns diffs parameter" do
        expect(subject).not_to receive(:diff_attr_if_blank?)

        expect(subject.send(:diff_attr_value, "diffs", "cc_or_fs", attr_name: "attr_name")).to eq "diffs"
      end
    end

    context "when diff_attr? attr_name parameter returns true" do
      before {
        allow(subject).to receive(:diff_attr?).with("attr_name").and_return true
      }

      context "when diff_attr_if_blank? returns false" do
        before {
          allow(subject).to receive(:diff_attr_if_blank?).with("attr_name", value: nil).and_return false
        }
        it "returns diffs parameter" do
          expect(subject).to receive(:diff_attr_if_blank?).with("attr_name", value: nil)
          expect(subject).not_to receive(:attr_prefix)

          expect(subject.send(:diff_attr_value, "diffs", "cc_or_fs", attr_name: "attr_name")).to eq "diffs"
        end
      end

      context "when diff_attr_if_blank? returns true" do
        before {
          allow(subject).to receive(:diff_attr_if_blank?).with("attr_name", value: "coco").and_return true
        }

        context "when attr_current is equal to value parameter" do
          it "returns diffs parameter" do
            expect(subject).not_to receive(:attr_prefix)
            expect(subject).to receive(:diff_attr_if_blank?).with("attr_name", value: "coco")

            expect(subject.send(:diff_attr_value, "diffs", {"attr_name" => "coco"}, attr_name: "attr_name", value: "coco")).to eq "diffs"
          end
        end

        context "when attr_current is NOT equal to value parameter" do
          before {
            allow(subject).to receive(:attr_prefix).with({"attr_name" => "kookaburra"}).and_return "prefix"
          }
          it "returns diffs parameter with more text appended" do
            expect(subject).to receive(:attr_prefix).with({"attr_name" => "kookaburra"})

            expect(subject.send(:diff_attr_value, ["diffs"], {"attr_name" => "kookaburra"}, attr_name: "attr_name", value: "coco")).to eq ["diffs", "prefix: attr_name 'kookaburra' vs. 'coco'"]
          end
        end
      end
    end

    context "when diff_attr? attr_name parameter raises an Exception" do
      before {
        allow(subject).to receive(:diff_attr?).with("attr_name").and_raise(Exception, "error message")
        allow(subject).to receive(:attr_prefix).with("cc_or_fs").and_return " prefix"
      }
      it "returns diffs parameter with error message" do
        expect(subject).to receive(:attr_prefix).with("cc_or_fs")

        result = subject.send(:diff_attr_value, "diffs", "cc_or_fs", attr_name: "attr_name")
        expect result.start_with?("diffs prefix: attr_name -- Exception: Exception: error message at ") == true
      end
    end

    after {
      expect(subject).to have_received(:diff_attr?).with("attr_name")
    }
  end


  describe "#diff_collection" do
    collection_hash = {:description => "description", :resource_type => "resource_type"}
    diffs = []
    before {
      allow(subject).to receive(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :creator )
      allow(subject).to receive(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :creator_ordered, multi: false )
      allow(subject).to receive(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :curation_notes_admin )
      allow(subject).to receive(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :curation_notes_admin_ordered, multi: false )
      allow(subject).to receive(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :curation_notes_user )
      allow(subject).to receive(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :curation_notes_user_ordered, multi: false )

      allow(subject).to receive(:build_date).with( hash: collection_hash, key: :date_created ).and_return "created date"
      allow(subject).to receive(:build_date).with( hash: collection_hash, key: :date_uploaded ).and_return "uploaded date"
      allow(subject).to receive(:build_date).with( hash: collection_hash, key: :date_modified ).and_return "modified date"

      allow(subject).to receive(:diff_attr_value).with( diffs, 'collection', attr_name: :date_created, value: "created date" )
      allow(subject).to receive(:diff_attr_value).with( diffs, 'collection', attr_name: :date_uploaded, value: "uploaded date" )
      allow(subject).to receive(:diff_attr_value).with( diffs, 'collection', attr_name: :date_modified, value: "modified date" )

      allow(subject).to receive(:build_depositor).with( hash: collection_hash ).and_return "depositor"
      allow(subject).to receive(:diff_attr_value).with( diffs, 'collection', attr_name: :depositor, value: "depositor" )
      allow(subject).to receive(:default_description).with(collection_hash[:description]).and_return "description"
      allow(subject).to receive(:diff_attr_value).with( diffs, 'collection', attr_name: :description, value: "description" )

      allow(subject).to receive(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :description_ordered, multi: false )
      allow(subject).to receive(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :doi, multi: false )
      allow(subject).to receive(:diff_edit_users).with( diffs, 'collection', collection_hash )
      allow(subject).to receive(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :keyword )
      allow(subject).to receive(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :keyword_ordered, multi: false )
      allow(subject).to receive(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :language )
      allow(subject).to receive(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :language_ordered, multi: false )
      allow(subject).to receive(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :prior_identifier )

      allow(subject).to receive(:build_referenced_by).with( hash: collection_hash ).and_return "build referenced by"
      allow(subject).to receive(:diff_attr_value).with( diffs, 'collection', attr_name: :referenced_by, value: "build referenced by")
      allow(subject).to receive(:default_collection_resource_type).with(resource_type: collection_hash[:resource_type] ).and_return "default resource type"
      allow(subject).to receive(:diff_attr_value).with( diffs, 'collection', attr_name: :resource_type, value: "default resource type" )

      allow(subject).to receive(:build_subject_discipline).with( hash: collection_hash ).and_return "subject discipline"
      allow(subject).to receive(:diff_attr_value).with( diffs, 'collection', attr_name: :subject_discipline, value: "subject discipline" )
      allow(subject).to receive(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :title )
      allow(subject).to receive(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :title_ordered, multi: false )
    }

    context "when diff_collections_recurse returns false" do
      before {
        allow(subject).to receive(:diff_collections_recurse).and_return false
      }
      it "returns diffs" do
        expect(subject).not_to receive(:diff_collection_works)
        expect(subject.send(:diff_collection, diffs: diffs, collection: 'collection', collection_hash: collection_hash)).to eq diffs
      end
    end

    context "when diff_collections_recurse returns true" do
      before {
        allow(subject).to receive(:diff_collections_recurse).and_return true
        allow(subject).to receive(:diff_collection_works).with( diffs: diffs, collection: 'collection', collection_hash: collection_hash )
                                                         .and_return "diff collection works"
      }
      it "calls diff_collection_works and returns result" do
        expect(subject).to receive(:diff_collection_works).with( diffs: diffs, collection: 'collection', collection_hash: collection_hash )

        expect(subject.send(:diff_collection, diffs: diffs, collection: 'collection', collection_hash: collection_hash)).to eq "diff collection works"
      end
    end

    after {
      expect(subject).to have_received(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :creator )
      expect(subject).to have_received(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :creator_ordered, multi: false )
      expect(subject).to have_received(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :curation_notes_admin )
      expect(subject).to have_received(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :curation_notes_admin_ordered, multi: false )
      expect(subject).to have_received(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :curation_notes_user )
      expect(subject).to have_received(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :curation_notes_user_ordered, multi: false )

      expect(subject).to have_received(:diff_attr_value).with( diffs, 'collection', attr_name: :date_created, value: "created date" )
      expect(subject).to have_received(:diff_attr_value).with( diffs, 'collection', attr_name: :date_uploaded, value: "uploaded date" )
      expect(subject).to have_received(:diff_attr_value).with( diffs, 'collection', attr_name: :date_modified, value: "modified date" )

      expect(subject).to have_received(:diff_attr_value).with( diffs, 'collection', attr_name: :depositor, value: "depositor" )
      expect(subject).to have_received(:diff_attr_value).with( diffs, 'collection', attr_name: :description, value: "description" )

      expect(subject).to have_received(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :description_ordered, multi: false )
      expect(subject).to have_received(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :doi, multi: false )
      expect(subject).to have_received(:diff_edit_users).with( diffs, 'collection', collection_hash )
      expect(subject).to have_received(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :keyword )
      expect(subject).to have_received(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :keyword_ordered, multi: false )
      expect(subject).to have_received(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :language )
      expect(subject).to have_received(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :language_ordered, multi: false )
      expect(subject).to have_received(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :prior_identifier )
      expect(subject).to have_received(:diff_attr_value).with( diffs, 'collection', attr_name: :referenced_by, value: "build referenced by")
      expect(subject).to have_received(:diff_attr_value).with( diffs, 'collection', attr_name: :resource_type, value: "default resource type" )
      expect(subject).to have_received(:diff_attr_value).with( diffs, 'collection', attr_name: :subject_discipline, value: "subject discipline" )
      expect(subject).to have_received(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :title )
      expect(subject).to have_received(:diff_attr).with( diffs, 'collection', collection_hash, attr_name: :title_ordered, multi: false )
      expect(subject).to have_received(:diff_collections_recurse)
    }
  end


  describe "#diff_edit_users" do
    context "when diff_attr :edit_users is false" do
      before {
        allow(subject).to receive(:diff_attr?).with(:edit_users).and_return false
      }
      it "returns diffs parameter" do
        expect(subject.send(:diff_edit_users, "diffs", "cc_or_fs", "cc_or_fs_hash")).to eq "diffs"
      end
    end

    context "when diff_attr :edit_users is true" do
      before {
        allow(subject).to receive(:diff_attr?).with(:edit_users).and_return true
      }

      context "when diff_attr_if_blank? returns false" do
        before {
          allow(subject).to receive(:diff_attr_if_blank?).with(:edit_users, value: ["cc or fs"]).and_return false
        }
        it "returns diffs parameter" do
          expect(subject).to receive(:diff_attr_if_blank?).with(:edit_users, value: ["cc or fs"])
          expect(subject.send(:diff_edit_users, "diffs", OpenStruct.new(edit_users: "current value"), {:edit_users => "cc or fs"})).to eq "diffs"
        end
      end

      context "when diff_attr_if_blank? returns true" do
        context "when xor variable is NOT empty" do
          before {
            allow(subject).to receive(:diff_attr_if_blank?).with(:edit_users, value: [9]).and_return true
            allow(subject).to receive(:attr_prefix).with(OpenStruct.new(edit_users: [6])).and_return " prefix"
          }
          it "returns diffs parameter with appended text" do
            expect(subject).to receive(:diff_attr_if_blank?).with(:edit_users, value: [9])
            expect(subject).to receive(:attr_prefix).with(OpenStruct.new(edit_users: [6]))
            expect(subject.send(:diff_edit_users, "diffs", OpenStruct.new(edit_users: [6]), {:edit_users => 9})).to eq "diffs prefix: edit_users '[6]' vs. '[9]'"
          end
        end

        context "when xor variable is empty" do
          before {
            allow(subject).to receive(:diff_attr_if_blank?).with(:edit_users, value: []).and_return true
          }
          it "returns diffs parameter" do
            expect(subject).to receive(:diff_attr_if_blank?).with(:edit_users, value: [])
            expect(subject).not_to receive(:attr_prefix)

            expect(subject.send(:diff_edit_users, "diffs", OpenStruct.new(edit_users: []), {:edit_users => nil})).to eq "diffs"
          end
        end
      end
    end

    context "when diff_attr :edit_users causes Exception" do
      before {
        allow(subject).to receive(:diff_attr?).with(:edit_users).and_raise(Exception, "error message")
        allow(subject).to receive(:attr_prefix).with("cc_or_fs").and_return " prefix"
      }
      it "returns diffs parameter" do
        expect(subject).to receive(:attr_prefix).with("cc_or_fs")

        result = subject.send(:diff_edit_users, "diffs", "cc_or_fs", "cc_or_fs_hash")
        expect result.start_with?("diffs prefix: edit_users -- Exception: Exception: error message at ") == true
      end
    end

    after {
      expect(subject).to have_received(:diff_attr?).with(:edit_users)
    }
  end


  describe "#diff_collection_works" do
    context "when continue_content_service is false" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return false
      }

      context "when collection parameter has member_objects" do
        it "returns diffs parameter" do
          expect(subject.send(:diff_collection_works, diffs: "diffs", collection: OpenStruct.new(member_objects: ["objects"]), collection_hash: nil))
            .to eq "diffs"
        end
      end

      context "when works_from_hash returns work_ids" do
        before {
          allow(subject).to receive(:works_from_hash).with(hash: "collection_hash").and_return [["work id"]]
        }
        it "returns diffs parameter" do
          expect(subject).to receive(:works_from_hash).with(hash: "collection_hash")
          expect(subject.send(:diff_collection_works, diffs: "diffs", collection: OpenStruct.new(member_objects: []), collection_hash: "collection_hash"))
            .to eq "diffs"
        end
      end

      after {
        expect(subject).to have_received(:continue_new_content_service)
      }
    end

    context "when continue_content_service is true" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return true
      }

      context "when collection parameter has member_objects" do
        member1 = OpenStruct.new(id: 1)
        member2 = OpenStruct.new(id: 2)
        member4 = OpenStruct.new(id: 4)
        collection = OpenStruct.new(member_objects: [member1, member2, member4])

        before {
          allow(Deepblue::TaskHelper).to receive(:work?).with(member1).and_return true
          allow(Deepblue::TaskHelper).to receive(:work?).with(member4).and_return true
          allow(subject).to receive(:works_from_hash).with(hash: "collection_hash").and_return [[1], []]
          allow(subject).to receive(:work_hash_from_id).with( parent_hash: "collection_hash", work_id: "1" ).and_return "work_hash1"
          allow(subject).to receive(:diff_work).with( diffs: "diffs", work_hash: "work_hash1", work: member1 )
          allow(subject).to receive(:attr_prefix).with(collection).and_return " prefix"
        }

        it "returns diffs parameter with added messages for missing or extra works" do
          expect(subject).to receive(:continue_new_content_service)
          expect(Deepblue::TaskHelper).to receive(:work?).with(member1)
          expect(Deepblue::TaskHelper).to receive(:work?).with(member2)
          expect(Deepblue::TaskHelper).to receive(:work?).with(member4)

          expect(subject).to receive(:works_from_hash).with(hash: "collection_hash").and_return [[1, 3], []]
          expect(subject).to receive(:work_hash_from_id).with( parent_hash: "collection_hash", work_id: "1" ).and_return "work_hash1"
          expect(subject).to receive(:diff_work).with( diffs: "diffs", work_hash: "work_hash1", work: member1 )
          expect(subject).to receive(:attr_prefix).with(collection).twice

          expect(subject.send(:diff_collection_works, diffs: "diffs", collection: collection, collection_hash: "collection_hash"))
            .to eq "diffs prefix: is missing work 3 prefix: has extra work 4"
        end
      end
    end

    context "when works_from_hash returns blank" do
      before {
        allow(subject).to receive(:works_from_hash).with(hash: "collection_hash").and_return []
      }
      it "returns diffs parameter" do
        expect(subject).to receive(:works_from_hash).with(hash: "collection_hash")
        expect(subject).not_to receive(:continue_new_content_service)

        expect(subject.send(:diff_collection_works, diffs: "diffs", collection: OpenStruct.new(member_objects: []), collection_hash: "collection_hash")).to eq "diffs"
      end
    end
  end


  describe "#diff_collections" do
    context "when collections function evaluates to false" do
      before {
        allow(subject).to receive(:collections).and_return false
      }
      it "returns nil" do
        expect(subject).to receive(:collections).once
        expect(subject.send(:diff_collections)).to be_nil
      end
    end

    context "when collections function returns results" do
      before {
        allow(subject).to receive(:collections).and_return ["collection hash 1", "collection hash 2"]
      }

      context "when continue_new_content_service evaluates to false" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return false
        }
        it "returns result of collections function" do
          expect(subject.send(:diff_collections)).to eq ["collection hash 1", "collection hash 2"]
        end
      end

      context "when continue_new_content_service evaluates to true" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return true
          measurement = MockMeasurement.new
          allow(Benchmark).to receive(:measure).and_return measurement
          allow(subject).to receive(:find_collection).with(collection_hash: "collection hash 1").and_return ["collection 1", "id1"]
          allow(subject).to receive(:find_collection).with(collection_hash: "collection hash 2").and_return [nil, "id2"]
          allow(subject).to receive(:diff_collection).with(collection_hash: "collection hash 1", collection: "collection 1").and_return ["diff1", "diff2"]
          allow(subject).to receive(:attr_prefix).with("collection 1").and_return "prefix"
          allow(subject).to receive(:add_measurement).with measurement
        }

        it "puts messages when collections are different" do
          expect(subject).to receive(:collections).twice
          subject.send(:diff_collections)
        end

        skip "Add tests for inside Benchmark.measure block"
      end

      after {
        expect(subject).to have_received(:continue_new_content_service).twice
      }
    end
  end


  describe "#diff_file_set" do
    context "when continue_new_content_service evaluates to false" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return nil
      }
      it "returns diffs parameter" do
        expect(subject).not_to receive(:diff_attr)
        expect(subject.send(:diff_file_set, diffs: "diffs", file_set: "file set", file_set_hash: "hash")).to eq "diffs"
      end
    end

    context "when continue_new_content_service evaluates to true" do
      hash = {:original_name => "the original"}
      file_set = OpenStruct.new(original_name_value: "original name", visibility: "public")

      before {
        allow(subject).to receive(:continue_new_content_service).and_return true
        allow(subject).to receive(:diff_attr).with( "diffs", file_set, hash, attr_name: :curation_notes_admin )
        allow(subject).to receive(:diff_attr).with( "diffs", file_set, hash, attr_name: :curation_notes_admin_ordered, multi: false )
        allow(subject).to receive(:diff_attr).with( "diffs", file_set, hash, attr_name: :curation_notes_user )
        allow(subject).to receive(:diff_attr).with( "diffs", file_set, hash, attr_name: :curation_notes_user_ordered, multi: false )

        allow(subject).to receive(:build_date).with( hash: hash, key: :date_created ).and_return "date created"
        allow(subject).to receive(:diff_attr_value).with( "diffs", file_set, attr_name: :date_created, value: "date created" )

        allow(subject).to receive(:build_date).with( hash: hash, key: :date_modified ).and_return "date modified"
        allow(subject).to receive(:diff_attr_value).with( "diffs", file_set, attr_name: :date_modified, value: "date modified" )

        allow(subject).to receive(:build_date).with( hash: hash, key: :date_uploaded ).and_return "date uploaded"
        allow(subject).to receive(:diff_attr_value).with( "diffs", file_set, attr_name: :date_uploaded, value: "date uploaded" )

        allow(subject).to receive(:build_depositor).with(hash: hash).and_return "depositor"
        allow(subject).to receive(:diff_attr_value).with( "diffs", file_set, attr_name: :depositor, value: "depositor" )
        allow(subject).to receive(:diff_edit_users).with( "diffs", file_set, hash )

        allow(subject).to receive(:diff_attr).with( "diffs", file_set, hash, attr_name: :label, multi: false )

        allow(subject).to receive(:diff_value_value).with( "diffs", file_set, attr_name: :original_name, current_value: file_set.original_name_value, value: "the original" )
        allow(subject).to receive(:diff_attr).with( "diffs", file_set, hash, attr_name: :prior_identifier )
        allow(subject).to receive(:diff_attr).with( "diffs", file_set, hash, attr_name: :title )

        allow(subject).to receive(:visibility_from_hash).with( hash: hash ).and_return "visibility from hash"
        allow(subject).to receive(:diff_value_value).with( "diffs", file_set, attr_name: :visibility, current_value: file_set.visibility, value: "visibility from hash" )
      }
      it "calls functions with and returns diffs" do
        expect(subject).to receive(:diff_attr).with( "diffs", file_set, hash, attr_name: :curation_notes_admin )
        expect(subject).to receive(:diff_attr).with( "diffs", file_set, hash, attr_name: :curation_notes_admin_ordered, multi: false )
        expect(subject).to receive(:diff_attr).with( "diffs", file_set, hash, attr_name: :curation_notes_user )
        expect(subject).to receive(:diff_attr).with( "diffs", file_set, hash, attr_name: :curation_notes_user_ordered, multi: false )

        expect(subject).to receive(:diff_attr_value).with( "diffs", file_set, attr_name: :date_created, value: "date created" )
        expect(subject).to receive(:diff_attr_value).with( "diffs", file_set, attr_name: :date_modified, value: "date modified" )
        expect(subject).to receive(:diff_attr_value).with( "diffs", file_set, attr_name: :date_uploaded, value: "date uploaded" )
        expect(subject).to receive(:diff_attr_value).with( "diffs", file_set, attr_name: :depositor, value: "depositor" )
        expect(subject).to receive(:diff_edit_users).with( "diffs", file_set, hash )

        expect(subject).to receive(:diff_attr).with( "diffs", file_set, hash, attr_name: :label, multi: false )

        expect(subject).to receive(:diff_value_value).with( "diffs", file_set, attr_name: :original_name, current_value: file_set.original_name_value, value: "the original" )
        expect(subject).to receive(:diff_attr).with( "diffs", file_set, hash, attr_name: :prior_identifier )
        expect(subject).to receive(:diff_attr).with( "diffs", file_set, hash, attr_name: :title )

        expect(subject).to receive(:visibility_from_hash).with( hash: hash ).and_return "visibility from hash"
        expect(subject).to receive(:diff_value_value).with( "diffs", file_set, attr_name: :visibility, current_value: file_set.visibility, value: "visibility from hash" )

        expect(subject.send(:diff_file_set, diffs: "diffs", file_set: file_set, file_set_hash: hash)).to eq "diffs"
      end
    end

    after {
      expect(subject).to have_received(:continue_new_content_service)
    }
  end


  describe "#diff_file_sets" do
    context "when file_set_ids are blank in work_hash parameter" do
      it "returns diffs" do
        expect(subject).not_to receive(:diff_file_sets_from_file_set_ids)

        expect(subject.send(:diff_file_sets, diffs: "diffs", work_hash: {:file_set_ids => ""}, work: "work")).to eq "diffs"
      end
    end

    context "when file_set_ids are present in work_hash parameter" do
      before {
        allow(subject).to receive(:diff_file_sets_from_file_set_ids).with(diffs: "diffs", work_hash: {:file_set_ids => "file set ids"}, work: "work")
                                                                    .and_return "diff file sets"
      }
      it "calls diff_file_sets_from_file_set_ids and returns the result" do
        expect(subject).to receive(:diff_file_sets_from_file_set_ids).with(diffs: "diffs", work_hash: {:file_set_ids => "file set ids"}, work: "work")
        expect(subject.send(:diff_file_sets, diffs: "diffs", work_hash: {:file_set_ids => "file set ids"}, work: "work")).to eq "diff file sets"
      end
    end
  end


  describe "#diff_file_sets_from_file_set_ids" do
    context "when continue_new_content_service evaluates to false" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return nil
      }
      it "returns diffs parameter passed in" do
        expect(subject.send(:diff_file_sets_from_file_set_ids, diffs: "differences", work_hash: "work hash", work: OpenStruct.new(file_sets: ["file set 1"]))).to eq "differences"
      end
    end

    context "when continue_new_content_service evaluates to true" do
      file_set_1 = OpenStruct.new(id: 1)
      file_set_3 = OpenStruct.new(id: 3)
      work = OpenStruct.new(file_sets: [file_set_1, file_set_3])

      before {
        allow(subject).to receive(:continue_new_content_service).and_return true
        allow(subject).to receive(:diff_file_set).with(diffs: "differences", file_set: file_set_1, file_set_hash: "file set hash 1" )
        allow(subject).to receive(:attr_prefix).with(work).and_return " prefix"
      }
      it "returns diffs including file difference messages" do
        work_hash = {:file_set_ids => [1, 2], :f_1 => "file set hash 1"}

        expect(subject).to receive(:continue_new_content_service)
        expect(subject).to receive(:diff_file_set).with(diffs: "differences", file_set: file_set_1, file_set_hash: "file set hash 1" )
        expect(subject).to receive(:attr_prefix).with(work)

        expect(subject.send(:diff_file_sets_from_file_set_ids, diffs: "differences", work_hash: work_hash, work: work ))
          .to eq "differences prefix: is missing file 2 prefix: has extra file 3"
      end
    end
  end


  describe "#diff_user" do
    context "when continue_new_content_service evaluates to false" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return nil
      }
      it "returns diffs" do
        expect(User).not_to receive(:attribute_names)

        expect(subject.send(:diff_user, diffs: nil, user_hash: "user hash", user: "user", user_email: "user email")).to be_empty
      end
    end

    context "when continue_new_content_service evaluates to true" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return true
        allow(User).to receive(:attribute_names).and_return ["name1", "name2"]
        allow(subject).to receive(:diff_user_attr).with("diffs", "user", "user hash", "user email", attr_name: "name1")
        allow(subject).to receive(:diff_user_attr).with("diffs", "user", "user hash", "user email", attr_name: "name2")
      }
      it "calls diff_user_attr for each User attribute name and returns diffs" do
        expect(User).to receive(:attribute_names)
        expect(subject).to receive(:diff_user_attr).with("diffs", "user", "user hash", "user email", attr_name: "name1")
        expect(subject).to receive(:diff_user_attr).with("diffs", "user", "user hash", "user email", attr_name: "name2")

        expect(subject.send(:diff_user, diffs: "diffs", user_hash: "user hash", user: "user", user_email: "user email")).to eq "diffs"
      end
    end

    after {
      expect(subject).to have_received(:continue_new_content_service)
    }
  end


  describe "#diff_users" do
    context "when users function evaluates to false" do
      before {
        allow(subject).to receive(:users).and_return nil
      }
      it "returns nil" do
        expect(Benchmark).not_to receive(:measure)
        expect(subject.send(:diff_users)).to be_nil
      end
    end

    context "when users function returns value(s)" do
      before {
        allow(Benchmark).to receive(:measure).and_return "measured"
        user_c = {:user_emails => ["charlotte"], :user_charlotte => "web"}
        user_d = {:user_emails => ["deirdre"], :user_deirdre => "org"}
        user_e = {:user_emails => ["eleanor"], :user_deirdre => "gov"}

        allow(subject).to receive(:users).and_return [ {:user_emails => [""]}, user_c, user_d, user_e]
        allow(subject).to receive(:find_user).with(user_hash: user_c).and_return "user charlotte"
        allow(subject).to receive(:find_user).with(user_hash: user_d).and_return nil
        allow(subject).to receive(:find_user).with(user_hash: user_e).and_return "user eleanor"
        allow(subject).to receive(:diff_user).with(user_hash: user_c, user: "user charlotte", user_email: "charlotte").and_return ["diff1", "diff2"]
        allow(subject).to receive(:diff_user).with(user_hash: user_e, user: "user eleanor", user_email: "eleanor").and_return nil
      }

      it "returns result of Benchmark.measure" do
        expect(subject.send(:diff_users)).to eq "measured"
      end

      skip "add tests for puts statements"
    end

    after {
      expect(subject).to have_received(:users)
    }
  end


  describe "#diff_user_attr" do
    context "when calling diff_user_attr? on attr_name parameter as a symbol returns false" do
      before {
        allow(subject).to receive(:diff_user_attr?).with(:attr_name).and_return false
      }
      it "returns diffs parameter" do
        expect(subject).not_to receive(:value_from_attr)
        expect(subject.send(:diff_user_attr, "diffs", "user", "user hash", "user email", attr_name: :attr_name)).to eq "diffs"
      end
    end

    context "when calling diff_user_attr? on attr_name parameter as a symbol returns true" do
      before {
        allow(subject).to receive(:diff_user_attr?).with(:attr_name).and_return true
      }

      context "when attr_name_hash parameter is blank" do
        before {
          allow(subject).to receive(:value_from_attr).with({:attr_name => "valuation"}, attr_name: :attr_name, attr_name_hash: nil, multi: false).and_return "valuation"
          allow(subject).to receive(:diff_user_attr_if_blank?).with(value: "valuation").and_return true
        }
        it "appends parameters to and returns diffs parameter" do
          expect(subject).to receive(:value_from_attr).with({:attr_name => "valuation"}, attr_name: :attr_name, attr_name_hash: nil, multi: false)
          expect(subject).to receive(:diff_user_attr_if_blank?).with(value: "valuation")
          expect(subject.send(:diff_user_attr, "diffs ", {:attr_name => "attr current"}, {:attr_name => "valuation"}, "user email",
                              attr_name: "attr_name")).to eq "diffs user email: attr_name 'attr current' vs. 'valuation'"
        end
      end

      context "when attr_name_hash parameter is present" do
        before {
          allow(subject).to receive(:value_from_attr).with({:attr_name => "valuation", :hashname => "hashed"},
                                                           attr_name: :attr_name, attr_name_hash: :hashname, multi: false).and_return "hashed"
          allow(subject).to receive(:diff_user_attr_if_blank?).with(value: "hashed").and_return true
        }
        it "appends parameters to and returns diffs parameter" do
          expect(subject).to receive(:value_from_attr).with({:attr_name => "valuation", :hashname => "hashed"},
                                                           attr_name: :attr_name, attr_name_hash: :hashname, multi: false)
          expect(subject).to receive(:diff_user_attr_if_blank?).with(value: "hashed")
          expect(subject.send(:diff_user_attr, "diffs ", {:attr_name => "attr current"}, {:attr_name => "valuation", :hashname => "hashed"}, "user email",
                              attr_name: "attr_name", attr_name_hash: :hashname)).to eq "diffs user email: attr_name 'attr current' vs. 'hashed'"
        end
      end

      context "when multi parameter is true" do
        before {
          allow(subject).to receive(:value_from_attr).with({:attr_name => "valuation"}, attr_name: :attr_name, attr_name_hash: nil, multi: true).and_return ["valuation"]
          allow(subject).to receive(:diff_user_attr_if_blank?).with(value: ["valuation"]).and_return true
        }
        it "appends parameters to and returns diffs parameter" do
          expect(subject).to receive(:value_from_attr).with({:attr_name => "valuation"}, attr_name: :attr_name, attr_name_hash: nil, multi: true)
          expect(subject).to receive(:diff_user_attr_if_blank?).with(value: ["valuation"])
          expect(subject.send(:diff_user_attr, "diffs ", {:attr_name => "attr current"}, {:attr_name => "valuation"}, "user email",
                              attr_name: "attr_name", multi: true)).to eq "diffs user email: attr_name 'attr current' vs. '[\"valuation\"]'"
        end
      end

      context "when diff_user_attr_if_blank? returns false" do
        before {
          allow(subject).to receive(:value_from_attr).with({:attr_name => "valuation"}, attr_name: :attr_name, attr_name_hash: nil, multi: false).and_return "valuation"
          allow(subject).to receive(:diff_user_attr_if_blank?).with(value: "valuation").and_return false
        }
        it "returns diffs parameter" do
          expect(subject).to receive(:value_from_attr).with({:attr_name => "valuation"}, attr_name: :attr_name, attr_name_hash: nil, multi: false)
          expect(subject).to receive(:diff_user_attr_if_blank?).with(value: "valuation")
          expect(subject.send(:diff_user_attr, "diffs", {:attr_name => "attr current"}, {:attr_name => "valuation"}, "user email",
                              attr_name: "attr_name")).to eq "diffs"
        end
      end

      context "when user[:attr_name] parameter value is equal to the result of value_from attr" do
        before {
          allow(subject).to receive(:value_from_attr).with({:attr_name => "attr current"}, attr_name: :attr_name, attr_name_hash: nil, multi: false).and_return "attr current"
          allow(subject).to receive(:diff_user_attr_if_blank?).with(value: "attr current").and_return true
        }
        it "returns diffs parameter" do
          expect(subject).to receive(:value_from_attr).with({:attr_name => "attr current"}, attr_name: :attr_name, attr_name_hash: nil, multi: false)
          expect(subject).to receive(:diff_user_attr_if_blank?).with(value: "attr current")
          expect(subject.send(:diff_user_attr, "diffs", {:attr_name => "attr current"}, {:attr_name => "attr current"}, "user email",
                              attr_name: "attr_name")).to eq "diffs"
        end
      end

      context "when Exception occurs" do
        before {
          allow(subject).to receive(:value_from_attr).with({:attr_name => "valuation"}, attr_name: :attr_name, attr_name_hash: nil, multi: false).and_return "valuation"
          allow(subject).to receive(:diff_user_attr_if_blank?).with(value: "valuation").and_raise(Exception, "Error Message")
        }
        it "appends error message to diffs and returns value" do
          expect(subject).to receive(:value_from_attr).with({:attr_name => "valuation"}, attr_name: :attr_name, attr_name_hash: nil, multi: false)
          expect(subject).to receive(:diff_user_attr_if_blank?).with(value: "valuation")

          result = subject.send(:diff_user_attr, "diffs ", {:attr_name => "attr current"}, {:attr_name => "valuation"}, "user email", attr_name: "attr_name")
          expect(result[0..69]).to eq "diffs user email: attr_name -- Exception: Exception: Error Message at "
        end
      end
    end

    after {
      expect(subject).to have_received(:diff_user_attr?).with(:attr_name)
    }
  end


  describe "#diff_user_attr?" do
    context "when diff_user_attrs_skip includes the attr_name parameter" do
      before {
        allow(subject).to receive(:diff_user_attrs_skip).and_return ["attribute name"]
      }
      it "returns false" do
        expect(subject.send(:diff_user_attr?, "attribute name")).to eq false
      end
    end

    context "when diff_user_attrs_skip does NOT include attr_name parameter" do
      before {
        allow(subject).to receive(:diff_user_attrs_skip).and_return ["attribute title"]
      }
      it "returns true" do
        expect(subject.send(:diff_user_attr?, "attribute name")).to eq true
      end
    end

    after {
      expect(subject).to have_received(:diff_user_attrs_skip)
    }
  end


  describe "#diff_user_attr_if_blank?" do
    context "when value parameter is blank" do
      it "returns false" do
        expect(subject.send(:diff_user_attr_if_blank?, value: "")).to eq false
      end
    end
    context "when value parameter is present" do
      it "returns true" do
        expect(subject.send(:diff_user_attr_if_blank?, value: "not blank")).to eq true
      end
    end
  end


  describe "#diff_value_value" do
    context "when calling diff_attr? attr_name evaluates to false" do
      before {
        allow(subject).to receive(:diff_attr?).with("attr name").and_return nil
      }
      it "returns diffs parameter" do
        expect(subject).not_to receive(:diff_attr_if_blank?)

        expect(subject.send(:diff_value_value, "diffs", "cc_or_fs", attr_name: "attr name", current_value: nil)).to eq "diffs"
      end
    end

    context "when calling diff_attr? attr_name evaluates to true" do
      before {
        allow(subject).to receive(:diff_attr?).with("attr name").and_return "success"
      }
      context "when diff_attr_if_blank? evaluates to false" do
        before {
          allow(subject).to receive(:diff_attr_if_blank?).with("attr name", value: "value").and_return nil
        }
        it "returns diffs parameter" do
          expect(subject).not_to receive(:attr_prefix)

          expect(subject.send(:diff_value_value, "diffs", "cc_or_fs", attr_name: "attr name", current_value: "valuation", value: "value")).to eq "diffs"
        end
      end

      context "when current_value parameter equals value parameter" do
        before {
          allow(subject).to receive(:diff_attr_if_blank?).with("attr name", value: "value").and_return "success"
        }
        it "returns diffs parameter" do
          expect(subject).not_to receive(:attr_prefix)

          expect(subject.send(:diff_value_value, "diffs", "cc_or_fs", attr_name: "attr name", current_value: "value", value: "value")).to eq "diffs"
        end
      end

      context "when current_value parameter does NOT equal the value parameter" do
        before {
          allow(subject).to receive(:diff_attr_if_blank?).with("attr name", value: "value").and_return "success"
          allow(subject).to receive(:attr_prefix).with("cc_or_fs").and_return "attr prefix cc_or_fs"
        }
        it "appends to and returns diffs parameter" do
          expect(subject).to receive(:attr_prefix).with("cc_or_fs")
          expect(subject.send(:diff_value_value, "diffs", "cc_or_fs", attr_name: "attr name", current_value: "current", value: "value")).to eq "diffsattr prefix cc_or_fs: attr name 'current' vs. 'value'"
        end
      end

      context "when Exception raised" do
        before {
          allow(subject).to receive(:diff_attr_if_blank?).with("attr name", value: "value").and_raise(Exception, "error message")
          allow(subject).to receive(:attr_prefix).with("cc_or_fs").and_return "attr prefix cc_or_fs"
        }
        it "appends to and returns diffs parameter with Exception information" do
          expect(subject).to receive(:attr_prefix).with("cc_or_fs")
          result = subject.send(:diff_value_value, "diffs", "cc_or_fs", attr_name: "attr name", current_value: "current", value: "value")
          expect(result[0..78]).to eq "diffsattr prefix cc_or_fs: attr name -- Exception: Exception: error message at "
        end
      end

      after {
        expect(subject).to have_received(:diff_attr_if_blank?).with("attr name", value: "value")
      }
    end

    after {
      expect(subject).to have_received(:diff_attr?).with("attr name")
    }
  end


  describe "#diff_work" do
    context "when continue_new_content_service is false and diffs is nil" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return false
      }
      it "returns empty array" do
        expect(subject).not_to receive(:diff_attr)
        expect(subject).not_to receive(:diff_attr_value)
        expect(subject.send(:diff_work, diffs: nil, work_hash: "work hash", work: "work")).to be_empty
      end
    end

    context "when continue_new_content_service is true" do
      work_hash = {:description => "aptly described", :methodology => "methodical", :resource_type => "resourceful"}
      work = OpenStruct.new(visibility: "visual")
      before {
        allow(subject).to receive(:continue_new_content_service).and_return true
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :authoremail, multi: false )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :contributor )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :creator )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :creator_ordered, multi: false )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :curation_notes_admin )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :curation_notes_admin_ordered, multi: false )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :curation_notes_user )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :curation_notes_user_ordered, multi: false )

        allow(subject).to receive(:build_date_coverage).with( hash: work_hash ).and_return "build date coverage"
        allow(subject).to receive(:build_date).with( hash: work_hash, key: :date_created ).and_return "date created"
        allow(subject).to receive(:build_date).with( hash: work_hash, key: :date_modified ).and_return "date modified"
        allow(subject).to receive(:build_date).with( hash: work_hash, key: :date_published ).and_return "date published"
        allow(subject).to receive(:build_date).with( hash: work_hash, key: :date_uploaded ).and_return "date uploaded"

        allow(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :date_coverage, value: "build date coverage")
        allow(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :date_created, value: "date created")
        allow(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :date_modified, value: "date modified")
        allow(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :date_published, value: "date published")
        allow(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :date_uploaded, value: "date uploaded")

        allow(subject).to receive(:build_depositor).with( hash: work_hash ).and_return "build depositor"
        allow(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :depositor, value: "build depositor" )
        allow(subject).to receive(:default_description).with(work_hash[:description]).and_return "build description"
        allow(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :description, value: "build description" )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :description_ordered, multi: false )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :doi, multi: false )
        allow(subject).to receive(:diff_edit_users).with( "diffs", work, work_hash )

        allow(subject).to receive(:build_fundedby).with( hash: work_hash ).and_return "build funded by"
        allow(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :fundedby, value: "build funded by" )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :fundedby_other )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :grantnumber, multi: false )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :keyword )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :keyword_ordered, multi: false )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :language )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :language_ordered, multi: false )

        allow(subject).to receive(:default_methodology).with(work_hash[:methodology]).and_return "default methodology"
        allow(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :methodology, value: "default methodology" )
        allow(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :owner, value: "build depositor" )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :prior_identifier )
        allow(subject).to receive(:build_referenced_by).with( hash: work_hash ).and_return "build ref by"
        allow(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :referenced_by, value: "build ref by" )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :referenced_by_ordered, multi: false )

        allow(subject).to receive(:default_work_resource_type).with(resource_type: work_hash[:resource_type]).and_return "default resource type"
        allow(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :resource_type, value: "default resource type" )
        allow(subject).to receive(:build_rights_license).with(hash: work_hash ).and_return "rights license"
        allow(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :rights_license, value: "rights license" )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :rights_license_other, multi: false )

        allow(subject).to receive(:build_subject_discipline).with( hash: work_hash ).and_return "subject discipline"
        allow(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :subject_discipline, value: "subject discipline" )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :title )
        allow(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :title_ordered, multi: false )
        allow(subject).to receive(:visibility_from_hash).with( hash: work_hash ).and_return "visible"
        allow(subject).to receive(:diff_value_value).with( "diffs", work, attr_name: :visibility, current_value: work.visibility, value: "visible" )
        allow(subject).to receive(:diff_file_sets).with( diffs: "diffs", work_hash: work_hash, work: work ).and_return "last diffs"
      }
      it "returns result of diff_file_sets" do
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :authoremail, multi: false )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :contributor )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :creator )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :creator_ordered, multi: false )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :curation_notes_admin )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :curation_notes_admin_ordered, multi: false )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :curation_notes_user )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :curation_notes_user_ordered, multi: false )

        expect(subject).to receive(:build_date_coverage).with( hash: work_hash )
        expect(subject).to receive(:build_date).with( hash: work_hash, key: :date_created )
        expect(subject).to receive(:build_date).with( hash: work_hash, key: :date_modified )
        expect(subject).to receive(:build_date).with( hash: work_hash, key: :date_published )
        expect(subject).to receive(:build_date).with( hash: work_hash, key: :date_uploaded )

        expect(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :date_coverage, value: "build date coverage")
        expect(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :date_created, value: "date created")
        expect(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :date_modified, value: "date modified")
        expect(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :date_published, value: "date published")
        expect(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :date_uploaded, value: "date uploaded")

        expect(subject).to receive(:build_depositor).with( hash: work_hash )
        expect(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :depositor, value: "build depositor" )
        expect(subject).to receive(:default_description).with(work_hash[:description])
        expect(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :description, value: "build description" )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :description_ordered, multi: false )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :doi, multi: false )
        expect(subject).to receive(:diff_edit_users).with( "diffs", work, work_hash )

        expect(subject).to receive(:build_fundedby).with( hash: work_hash )
        expect(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :fundedby, value: "build funded by" )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :fundedby_other )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :grantnumber, multi: false )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :keyword )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :keyword_ordered, multi: false )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :language )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :language_ordered, multi: false )

        expect(subject).to receive(:default_methodology).with(work_hash[:methodology])
        expect(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :methodology, value: "default methodology" )
        expect(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :owner, value: "build depositor" )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :prior_identifier )
        expect(subject).to receive(:build_referenced_by).with( hash: work_hash )
        expect(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :referenced_by, value: "build ref by" )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :referenced_by_ordered, multi: false )

        expect(subject).to receive(:default_work_resource_type).with(resource_type: work_hash[:resource_type])
        expect(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :resource_type, value: "default resource type" )
        expect(subject).to receive(:build_rights_license).with(hash: work_hash ).and_return "rights license"
        expect(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :rights_license, value: "rights license" )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :rights_license_other, multi: false )

        expect(subject).to receive(:build_subject_discipline).with( hash: work_hash )
        expect(subject).to receive(:diff_attr_value).with( "diffs", work, attr_name: :subject_discipline, value: "subject discipline" )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :title )
        expect(subject).to receive(:diff_attr).with( "diffs", work, work_hash, attr_name: :title_ordered, multi: false )
        expect(subject).to receive(:visibility_from_hash).with( hash: work_hash )
        expect(subject).to receive(:diff_value_value).with( "diffs", work, attr_name: :visibility, current_value: work.visibility, value: "visible" )
        expect(subject).to receive(:diff_file_sets).with( diffs: "diffs", work_hash: work_hash, work: work )

        expect(subject.send(:diff_work, diffs: "diffs", work_hash: work_hash, work: work)).to eq "last diffs"
      end
    end

    after {
      expect(subject).to have_received(:continue_new_content_service)
    }
  end


  describe "#diff_works" do
    context "when works evaluates to false" do
      before {
        allow(subject).to receive(:works).and_return nil
      }
      it "returns nil" do
        expect(subject).to receive(:works).once
        expect(subject).not_to receive(:continue_new_content_service)

        expect(subject.send(:diff_works)).to be_nil
      end
    end

    context "when works returns results" do
      measurement = MockMeasurement.new
      before {
        allow(subject).to receive(:verbose).and_return true
        allow(subject).to receive(:works).and_return [nil, "work hash 1", "work hash 2", "work hash 3", "work hash 4"]
        allow(Benchmark).to receive(:measure).and_return measurement

        allow(subject).to receive(:find_work).with(work_hash: "work hash 1", error_if_not_found: false).and_return [nil, nil]
        allow(subject).to receive(:find_work).with(work_hash: "work hash 2", error_if_not_found: false).and_return [nil, "work id 2"]
        allow(subject).to receive(:find_work).with(work_hash: "work hash 3", error_if_not_found: false).and_return ["work 3", "work id 3"]
        allow(subject).to receive(:find_work).with(work_hash: "work hash 4", error_if_not_found: false).and_return ["work 4", "work id 4"]
        allow(subject).to receive(:puts).with "== work work id 2 is missing =="

        allow(subject).to receive(:attr_prefix).with("work 3").and_return "attr prefix work 3"
        allow(subject).to receive(:attr_prefix).with("work 4").and_return "attr prefix work 4"

        allow(subject).to receive(:diff_work).with(work_hash: "work hash 3", work: "work 3").and_return ["diff1", "diff2"]
        allow(subject).to receive(:diff_work).with(work_hash: "work hash 4", work: "work 4").and_return []

        allow(subject).to receive(:add_measurement).with(measurement)
      }

      context "when continue_new_content_service returns false" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return false
        }
        it "does not call Benchmark.measure" do
          expect(subject).to receive(:continue_new_content_service)
          expect(Benchmark).not_to receive(:measure)

          subject.send(:diff_works)
        end
      end

      context "when continue_new_content_service returns true" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return true
        }
        it "calls Benchmark.measure" do
          expect(subject).to receive(:continue_new_content_service)
          expect(Benchmark).to receive(:measure)
          subject.send(:diff_works)
        end
      end

      skip "add a test for measurement.instance_variable_set( :@label, work_id )"

      after {
        expect(subject).to have_received(:works).twice
      }
    end
  end


  describe "#doi_mint" do
    doi_mint = MockDoiMint.new("mint_now")
    before {
      allow(subject).to receive(:user).and_return "user"
    }

    context "when parameter does not respond to doi_mint" do
      it "returns nil" do
        expect(subject.send(:doi_mint, curation_concern: OpenStruct.new(doi: true, mint: true))).to be_nil
      end
    end

    context "when doi field on parameter does not equal DOI_MINT_NOW" do
      it "returns nil" do
        expect(doi_mint).not_to receive(:doi_mint)

        expect(subject.send(:doi_mint, curation_concern: OpenStruct.new(doi: "mint_then", doi_mint: true))).to be_nil
      end
    end

    context "when doi field on parameter equals DOI_MINT_NOW" do
      it "calls functions on curation_concern parameter" do
        expect(doi_mint).to receive(:doi=).with(nil)
        expect(doi_mint).to receive(:save!)
        expect(doi_mint).to receive(:reload)
        expect(doi_mint).to receive(:doi_mint).with( current_user: "user", event_note: 'NewContentService', job_delay: 60 )

        subject.send(:doi_mint, curation_concern: doi_mint)
      end
    end

    context "when calling doi_mint on curation_concern parameter raises an Exception" do
      before {
        allow(doi_mint).to receive(:doi_mint).with( current_user: "user", event_note: 'NewContentService', job_delay: 60 ).and_raise(Exception)
        allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
        allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      }
      it "logs error" do
        expect(Rails.logger).to receive(:error)
        expect(Deepblue::LoggingHelper).to receive(:bold_debug)
        subject.send(:doi_mint, curation_concern: doi_mint)
      end
    end
  end


  describe "#file_from_file_set" do
    file1 = OpenStruct.new(original_name: "")
    file2 = OpenStruct.new(original_name: "Original Name")

    context "when file_set parameter includes multiple files" do
      it "returns last file in files with an original name" do
        expect(subject.send(:file_from_file_set, file_set: OpenStruct.new(files: [file1, file2]))).to eq file2
      end
    end

    context "when file_set parameter includes a single file" do
      it "returns the only file in files" do
        expect(subject.send(:file_from_file_set, file_set: OpenStruct.new(files: [file1]))).to eq file1
      end
    end

    context "when file_set parameter does not include files" do
      it "returns nil" do
        expect(subject.send(:file_from_file_set, file_set: OpenStruct.new(files: nil))).to be_nil
      end
    end

    context "when file_set parameter files are empty" do
      it "returns nil" do
        expect(subject.send(:file_from_file_set, file_set: OpenStruct.new(files: []))).to be_nil
      end
    end
  end


  describe "#file_set_checksum" do
    context "when file_from_file_set returns file" do
      before {
        allow(subject).to receive(:file_from_file_set).with(file_set: "file set").and_return OpenStruct.new(checksum: "checksum")
      }
      it "returns file checksum field" do
        expect(subject.send(:file_set_checksum, file_set: "file set")).to eq "checksum"
      end
    end

    context "when file_from_file_set does NOT return file" do
      before {
        allow(subject).to receive(:file_from_file_set).with(file_set: "file set").and_return nil
      }
      it "returns nil" do
        expect(subject.send(:file_set_checksum, file_set: "file set")).to be_nil
      end
    end

    after {
      expect(subject).to have_received(:file_from_file_set).with(file_set: "file set")
    }
  end


  describe "#find_collection" do
    context "when continue_new_content_service evaluates to false" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return nil
      }
      it "returns nil, nil" do
        expect(Collection).not_to receive(:find)

        expect(subject.send(:find_collection, collection_hash: "collection hash")).to eq [nil, nil]
      end
    end

    context "when continue_new_content_service evaluates to true" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return true
        allow(Collection).to receive(:find).with("11257").and_return "collection"
      }
      context "when parameter is blank" do
        it "returns nil, nil" do
          expect(Collection).not_to receive(:find)

          expect(subject.send(:find_collection, collection_hash: "")).to eq [nil, nil]  # technically not empty or nil
        end
      end

      context "when parameter is NOT blank" do
        it "returns collection, id" do
          expect(Collection).to receive(:find).with("11257")
          expect(subject.send(:find_collection, collection_hash: {:id => 11257, :mode => "modular"})).to eq ["collection", "11257"]
        end
      end
    end

    after {
      expect(subject).to have_received(:continue_new_content_service)
    }
  end


  describe "#find_collection_using_id" do
    context "when id parameter is blank" do
      it "returns nil" do
        expect(Collection).not_to receive(:find).with("collection id")

        expect(subject.send(:find_collection_using_id, id: "")).to be_nil
      end
    end

    context "when id parameter is present" do

      context "when Collection with id can be found" do
        before {
          allow(Collection).to receive(:find).with("collection id").and_return "curation concern"
        }
        it "returns Collection with id equal to id parameter" do
          expect(subject.send(:find_collection_using_id, id: "collection id")).to eq "curation concern"
        end
      end

      context "when Collection with id canNOT be found" do
        before {
          allow(Collection).to receive(:find).with("collection id").and_raise(ActiveFedora::ObjectNotFoundError)
        }
        it "raises ActiveFedora::ObjectNotFoundError and returns nil" do
          expect(subject.send(:find_collection_using_id, id: "collection id")).to be_nil
        end
      end

      after {
        expect(Collection).to have_received(:find).with("collection id")
      }
    end
  end


  describe "#find_collection_using_prior_id" do
    context "when prior_id parameter is blank" do
      it "returns nil" do
        expect(Collection).not_to receive(:all)

        expect(subject.send(:find_collection_using_prior_id, prior_id: "")).to be_nil
      end
    end

    context "when prior_id parameter is present" do
      cc1 = OpenStruct.new(prior_identifier: "A priori")
      cc2 = OpenStruct.new(prior_identifier: ["prior ID", "priory"])

      context "when a collection has an id equal to prior_id" do
        before {
          allow(Collection).to receive(:all).and_return [cc1, cc2]
        }
        it "returns collection" do
          expect(subject.send(:find_collection_using_prior_id, prior_id: "prior ID")).to eq cc2
        end
      end

      context "when NO collection has an id equal to prior_id" do
        before {
          allow(Collection).to receive(:all).and_return [cc1]
        }
        it "returns nil" do
          expect(subject.send(:find_collection_using_prior_id, prior_id: "prior ID")).to be_nil
        end
      end

      after {
        expect(Collection).to have_received(:all)
      }
    end
  end


  describe "#find_collections_and_update" do
    context "when collections is blank" do
      before {
        allow(subject).to receive(:collections).and_return nil
      }
      it "returns nil" do
        expect(subject).to receive(:collections).once
        expect(Benchmark).not_to receive(:measure)

        expect(subject.send(:find_collections_and_update)).to be_nil
      end
    end

    context "when collections is present" do
      measurement = MockMeasurement.new
      before {
        allow(subject).to receive(:collections).and_return ["collection hash 1", "collection hash 2"]
        allow(subject).to receive(:user_key).and_return "user key"
        allow(subject).to receive(:user_create_users).with(emails: "user key")
      }

      context "when continue_new_content_service returns false" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return false
        }
        it "does not call Benchmark.measure, set instance variable, or add measurement" do
          expect(Benchmark).not_to receive(:measure)

          subject.send(:find_collections_and_update)
        end
      end

      context "when continue_new_content_service returns true" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return true

          allow(Benchmark).to receive(:measure).and_return measurement
          allow(subject).to receive(:find_collection).with(collection_hash: "collection hash 1").and_return ["collection", "collection ID 1"]
          allow(subject).to receive(:find_collection).with(collection_hash: "collection hash 2").and_return ["", "collection ID 2"]
          allow(subject).to receive(:add_measurement).with measurement
        }

        context "when object in collections is present" do
          it "sets instance variable and adds measurement" do
            expect(Benchmark).to receive(:measure)

            subject.send(:find_collections_and_update)
          end
        end

        after {
          expect(subject).to have_received(:collections).twice
          expect(subject).to have_received(:user_create_users).with(emails: "user key")
          expect(subject).to have_received(:continue_new_content_service).twice
        }
      end

      skip "add tests for Benchmark.measure block"
    end
  end


  describe "#find_file_set_using_id" do
    context "when id parameter is blank" do
      it "returns nil" do
        expect(subject.send(:find_file_set_using_id, id: nil)).to be_nil
      end
    end

    context "when id parameter is present" do

      context "when FileSet can be found" do
        before {
          allow(FileSet).to receive(:find).with("fileset ID").and_return "FileSet found"
        }
        it "returns FileSet" do
          expect(subject.send(:find_file_set_using_id, id: "fileset ID")).to eq "FileSet found"
        end
      end

      context "when FileSet canNOT be found" do
        before {
          allow(FileSet).to receive(:find).with("fileset ID").and_return nil
        }
        it "rescues ActiveFedora::ObjectNotFoundError and returns nil" do
          expect(subject.send(:find_file_set_using_id, id: "fileset ID")).to be_nil
        end
      end
    end
  end


  describe "#find_file_set_using_prior_id" do
    blanks = [{:describe => "prior_id parameter is", :prior_id => nil, parent => "parent" },
              {:describe => "parent parameter is", :prior_id => "prior ID", parent => "" },
              {:describe => "both parameters are", :prior_id => nil, parent => nil }]
    blanks.each do | blank |
      context "when #{blank[:describe]} blank" do
        it "returns nil" do
          expect(subject.send(:find_file_set_using_prior_id, prior_id: blank[:prior_id], parent: blank[:parent])).to be_nil
        end
      end
    end

    context "when prior_id parameter and parent parameter are present" do
      context "when parent File_Set id is equal to prior_id parameter" do
        it "returns parent File_Set" do
          fs1 = OpenStruct.new(prior_identifier: "random ID")
          fs2 = OpenStruct.new(prior_identifier: "prior ID")
          file_sets = [fs1, fs2]

          expect(FileSet).not_to receive(:all)

          expect(subject.send(:find_file_set_using_prior_id, prior_id: "prior ID", parent: OpenStruct.new(file_sets: file_sets))).to eq fs2
        end
      end

      context "when FileSet.all includes parent with id equal to parent parameter id" do
        file_s1 = OpenStruct.new(parent: nil)
        file_s2 = OpenStruct.new(parent: "unknown", parent_id: "unknown ID")
        file_s3 = OpenStruct.new(parent: "parent", parent_id: "parent ID")
        before {
          allow(FileSet).to receive(:all).and_return [file_s1, file_s2, file_s3]
        }
        it "returns FileSet with parent" do
          expect(FileSet).to receive(:all)

          expect(subject.send(:find_file_set_using_prior_id, prior_id: "prior ID", parent: OpenStruct.new(file_sets: [], id: "parent ID"))).to eq file_s3
        end
      end

      context "when FileSet.all includes prior_identifier with id equal to prior_id parameter" do
        f_set1 = OpenStruct.new(parent: nil, prior_identifier: "foreign ID")
        f_set2 = OpenStruct.new(parent: nil, prior_identifier: "prior ID")
        before {
          allow(FileSet).to receive(:all).and_return [f_set1, f_set2]
        }
        it "returns FileSet with prior_identifier" do
          expect(FileSet).to receive(:all)

          expect(subject.send(:find_file_set_using_prior_id, prior_id: "prior ID", parent: OpenStruct.new(file_sets: [], id: "parent ID"))).to eq f_set2
        end
      end

      context "when FileSet with neither parent.id nor prior_id can be found" do
        f_set1 = OpenStruct.new(parent: nil, prior_identifier: "incorrect ID")
        f_set2 = OpenStruct.new(parent: nil, prior_identifier: "unrelated ID")
        before {
          allow(FileSet).to receive(:all).and_return [f_set1, f_set2]
        }
        it "returns nil" do
          expect(FileSet).to receive(:all)

          expect(subject.send(:find_file_set_using_prior_id, prior_id: "prior ID", parent: OpenStruct.new(file_sets: [], id: "parent ID"))).to eq nil
        end
      end
    end
  end


  describe "#find_user" do
    context "when user_hash parameter is blank" do
      it "returns nil" do
        expect(User).not_to receive(:find_by_user_key).with("exampleemaildotorg")

        expect(subject.send(:find_user, user_hash: [])).to be_nil
      end
    end

    context "when user_hash parameter is present" do
      before {
        allow(User).to receive(:find_by_user_key).with("exampleemaildotorg").and_return "user"
      }
      it "calls User.find_by_user_key function and returns result" do
        expect(User).to receive(:find_by_user_key).with("exampleemaildotorg")

        expect(subject.send(:find_user, user_hash: {:email => "exampleemaildotorg"})).to eq "user"
      end
    end
  end


  describe "#find_work" do
    context "when work is found" do
      before {
        allow(Deepblue::TaskHelper).to receive(:work_find).with(id: "121").and_return "work"
      }
      it "returns work and work id" do
        expect(Deepblue::TaskHelper).to receive(:work_find).with(id: "121")
        expect(subject.send(:find_work, work_hash: {:id => 121})).to eq ["work", "121"]
      end
    end

    context "when work is NOT found" do
      before {
        allow(Deepblue::TaskHelper).to receive(:work_find).with(id: "121").and_return nil
      }
      context "when error_if_not_found parameter is true" do
        it "ActiveFedora::ObjectNotFoundError is raised" do
          subject.send(:find_work, work_hash: {:id => 121})
          rescue ActiveFedora::ObjectNotFoundError
            # raises Exception
        end
      end

      context "when error_if_not_found parameter is false" do
        it "ActiveFedora::ObjectNotFoundError is NOT raised" do
          expect(subject.send(:find_work, work_hash: {:id => 121}, error_if_not_found: false)).to eq [nil, "121"]
        end
      end
    end
  end


  describe "#find_works_and_add_files" do
    context "when works evaluates to negative" do
      before {
        allow(subject).to receive(:works).and_return nil
      }
      it "returns nil" do
        expect(subject).to receive(:works).once
        expect(Benchmark).not_to receive(:measure)
        expect(subject.send(:find_works_and_add_files)).to be_nil
      end
    end

    context "when works returns results" do
      work = MockBuildWork.new
      before {
        allow(subject).to receive(:works).and_return ["work hash"]
        allow(subject).to receive(:find_work).with(work_hash: "work hash").and_return [work, "work id"]
      }

      context "when continue_new_content_service is false" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return false
        }
        it "returns result of works function" do
          expect(subject).not_to receive(:find_work)

          expect(subject.send(:find_works_and_add_files)).to eq ["work hash"]
        end
      end

      context "when continue_new_content_service is true" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return true
          allow(Benchmark).to receive(:measure).with("work id").and_return "measurement"
          allow(subject).to receive(:add_file_sets_to_work).with( work_hash: "work hash", work: work )
          allow(subject).to receive(:build_depositor).with(hash: "work hash").and_return "depositor"
          allow(subject).to receive(:build_admin_set_work).with(hash: "work hash").and_return "admin set"
          allow(subject).to receive(:apply_visibility_and_workflow).with(work: work, work_hash: "work hash", admin_set: "admin set")
          allow(subject).to receive(:log_object).with work
          allow(subject).to receive(:add_measurement).with "measurement"
        }
        it "calls Benchmark.measure and adds measurement" do
          expect(subject).to receive(:find_work).with(work_hash: "work hash")

          expect(Benchmark).to receive(:measure).with("work id")
          expect(subject).to receive(:add_measurement).with "measurement"

          subject.send(:find_works_and_add_files)
        end

        skip "add a test for inside Benchmark.measure do/end"

        after {
          expect(subject).to have_received(:works).twice
          expect(subject).to have_received(:continue_new_content_service).once
        }
      end
    end
  end


  describe "#find_work_using_id" do
    context "when id parameter is blank" do
      it "returns nil" do
        expect(Deepblue::TaskHelper).not_to receive(:work_find)

        expect(subject.send(:find_work_using_id, id: "")).to be_nil
      end
    end

    context "when id parameter is present" do
      context "when TaskHelper.work_find can find id" do
        before {
          allow(Deepblue::TaskHelper).to receive(:work_find).with(id: "99").and_return "work 99"
        }
        it "returns result" do
          expect(Deepblue::TaskHelper).to receive(:work_find).with(id: "99")
          expect(subject.send(:find_work_using_id, id: 99)).to eq "work 99"
        end
      end

      context "when TaskHelper.work_find canNOT find id" do
        before {
          allow(Deepblue::TaskHelper).to receive(:work_find).with(id: "98").and_raise(ActiveFedora::ObjectNotFoundError)
        }
        it "raises ActiveFedora::ObjectNotFoundError and returns nil" do
          expect(Deepblue::TaskHelper).to receive(:work_find).with(id: "98")
          expect(subject.send(:find_work_using_id, id: 98)).to be_nil
        end
      end
    end
  end


  describe "#find_work_using_prior_id" do
    context "when prior_id parameter is blank" do
      it "returns nil" do
        expect(Deepblue::TaskHelper).not_to receive(:all_works)
        expect(subject.send(:find_work_using_prior_id, prior_id: nil, parent: "parent")).to be_nil
      end
    end

    context "when prior_id parameter is present" do
      context "when parent parameter is present" do
        member_object2 = OpenStruct.new(prior_identifier: ["another ID", "prior ID"])
        member_objects = ["member_object1", member_object2]
        before {
          allow(Deepblue::TaskHelper).to receive(:work?).with("member_object1").and_return false
          allow(Deepblue::TaskHelper).to receive(:work?).with(member_object2).and_return true
        }
        it "returns work from parent parameter with prior id" do
          expect(Deepblue::TaskHelper).to receive(:work?).with("member_object1")
          expect(Deepblue::TaskHelper).to receive(:work?).with(member_object2)
          expect(Deepblue::TaskHelper).not_to receive(:all_works)

          expect(subject.send(:find_work_using_prior_id, prior_id: "prior ID", parent: OpenStruct.new(member_objects: member_objects))).to eq member_object2
        end
      end

      context "when parent parameter with prior id not found" do
        context "when a work can be found with prior id parameter" do
          curation_concern1 = OpenStruct.new(prior_identifier: ["similar ID"])
          curation_concern2 = OpenStruct.new(prior_identifier: ["another ID", "prior ID"])
          curation_concerns = [curation_concern1, curation_concern2]
          before {
            allow(Deepblue::TaskHelper).to receive(:all_works).and_return curation_concerns
          }
          it "returns work from TaskHelper.all_works with prior id" do
            expect(subject.send(:find_work_using_prior_id, prior_id: "prior ID", parent: nil)).to eq curation_concern2
          end
        end

        context "when prior id canNot be found in all works" do
          before {
            allow(Deepblue::TaskHelper).to receive(:all_works).and_return [ OpenStruct.new(prior_identifier: ["unorthodox ID"]) ]
          }
          it "returns nil" do
            expect(subject.send(:find_work_using_prior_id, prior_id: "prior ID", parent: nil)).to be_nil
          end
        end

        after {
          expect(Deepblue::TaskHelper).to have_received(:all_works)
        }
      end
    end
  end


  describe "#ingest_id" do
    context "when @ingest_id has a value" do
      before {
        subject.instance_variable_set :@ingest_id, "123"
      }
      it "returns @ingest_id" do
        expect(subject.send(:ingest_id)).to eq "123"
      end
    end

    context "when @ingest_id has NO value" do
      before {
        subject.instance_variable_set :@ingest_id, nil
        subject.instance_variable_set :@cfg_hash, {:user => {:ingester => "ingested"}}
      }
      it "sets @ingest_id to @cfg_hash[:user][:ingester] and returns value" do
        expect(subject.send(:ingest_id)).to eq "ingested"
        expect(subject.instance_variable_get :@ingest_id).to eq "ingested"
      end
    end
  end


  describe "#ingester" do
    before {
      subject.instance_variable_set :@cfg_hash, {:user => {:ingester => "ingested"}}
    }
    it "returns @cfg_hash[:user][:ingester]" do
      expect(subject.send(:ingester)).to eq "ingested"
    end
  end


  describe "#initialize_with_msg" do
    logger = MockLogger.new

    subject { Deepblue::NewContentService.new(path_to_yaml_file: "yaml path", cfg_hash: "cfg hash", base_path: "base path", options: {"hello" => "world"}) }  #calls the method

    before {
      allow(Deepblue::ProvenanceHelper).to receive(:echo_to_rails_logger=).with false
      allow(DateTime).to receive(:now).and_return "ingest timestamp"
      allow(Pathname).to receive(:new).with( '.' ).and_return OpenStruct.new(realdirpath: ["real dir path ", ""])
      allow(subject).to receive(:logger).and_return logger
      allow(Process).to receive(:ppid).and_return "process_ppid"
    }

    context "when options keys does NOT include error and verbose is false" do
      options = Hash.new("hello" => "world")
      before {
        allow(Deepblue::TaskHelper).to receive(:task_options_parse).with(options).and_return options
        allow(Deepblue::TaskHelper).to receive(:task_options_value).with(options, key: 'verbose', default_value: true ).and_return false
        allow(logger).to receive(:info).with("")
      }
      it "sets instance variables and calls logger.info" do
        expect(Deepblue::TaskHelper).to receive(:task_options_parse).with(options)
        expect(Deepblue::TaskHelper).to receive(:task_options_value).with(options, key: 'verbose', default_value: true )
        expect(Pathname).to receive(:new).with( '.' )
        expect(logger).not_to receive(:info)

        subject.send(:initialize_with_msg, options: options, path_to_yaml_file: "yaml path", cfg_hash: "cfg hash", base_path: "base path", msg: "")

        expect(subject.instance_variable_get(:@options)).to eq options
        expect(subject.instance_variable_get(:@verbose)).to eq false
        expect(subject.instance_variable_get(:@config)).to be_empty
        expect(subject.instance_variable_get(:@mode)).to be_nil
        expect(subject.instance_variable_get(:@ingester)).to be_nil
      end
    end

    context "when options keys includes error, verbose is true and the mode, ingester, msg and config parameters have values" do
      options = {'hello' => 'world', 'error' => 'optional'}
      before {
        allow(Deepblue::TaskHelper).to receive(:task_options_parse).with(options).and_return options
        allow(Deepblue::TaskHelper).to receive(:task_options_value).with(options, key: 'verbose', default_value: true ).and_return true
        allow(logger).to receive(:info).with("NEW CONTENT SERVICE AT YOUR ... SERVICE")
      }
      it "sets instance variables and calls logger.info" do
        expect(subject).to receive(:puts).with "WARNING: options error optional"
        expect(subject).to receive(:puts).with "options={\"hello\"=>\"world\", \"error\"=>\"optional\"}"
        expect(subject).to receive(:puts).with "@options={\"hello\"=>\"world\", \"error\"=>\"optional\"}"
        expect(subject).to receive(:puts).with "@verbose=true"

        expect(Deepblue::TaskHelper).to receive(:task_options_parse).with(options)
        expect(Deepblue::TaskHelper).to receive(:task_options_value).with(options, key: 'verbose', default_value: true )
        expect(Pathname).to receive(:new).with( '.' )
        expect(logger).to receive(:info).with("NEW CONTENT SERVICE AT YOUR ... SERVICE")

        subject.send(:initialize_with_msg, options: options, path_to_yaml_file: "yaml path", cfg_hash: "cfg hash", base_path: "base path",
                     mode: "La Mode", ingester: "ingester", "bee" => "honey")

        expect(subject.instance_variable_get(:@options)).to eq options
        expect(subject.instance_variable_get(:@verbose)).to eq true
        expect(subject.instance_variable_get(:@config)).to eq "bee" => "honey"
        expect(subject.instance_variable_get(:@mode)).to eq "La Mode"
        expect(subject.instance_variable_get(:@ingester)).to eq "ingester"
      end
    end

    after {
      expect(DeepBlueDocs::Application.config.provenance_log_echo_to_rails_logger).to eq false
      expect(Process).to have_received(:ppid)

      expect(subject.instance_variable_get(:@path_to_yaml_file)).to eq "yaml path"
      expect(subject.instance_variable_get(:@cfg_hash)).to eq "cfg hash"
      expect(subject.instance_variable_get(:@base_path)).to eq "base path"

      expect(subject.instance_variable_get(:@diff_attrs_skip)).to eq [:creator_ordered,
                                                                      :curation_notes_admin_ordered, :curation_notes_user_ordered,
                                                                      :date_created, :date_modified,
                                                                      :description_ordered,
                                                                      :keyword_ordered, :language_ordered,
                                                                      :referenced_by_ordered, :title_ordered,
                                                                      :visibility]
      expect(subject.instance_variable_get(:@diff_attrs_skip_if_blank)).to eq [:creator_ordered,
                                                                               :curation_notes_admin, :curation_notes_admin_ordered,
                                                                               :curation_notes_user, :curation_notes_user_ordered,
                                                                               :checksum_algorithm, :checksum_value,
                                                                               :date_published,
                                                                               :description_ordered,
                                                                               :doi,
                                                                               :fundedby_other,
                                                                               :keyword_ordered, :language_ordered,
                                                                               :prior_identifier,
                                                                               :referenced_by_ordered, :title_ordered]
      expect(subject.instance_variable_get(:@diff_user_attrs_skip)).to eq [:created_at,
                                                                           :current_sign_in_at, :current_sign_in_ip,
                                                                           :email, :encrypted_password,
                                                                           :id,
                                                                           :updated_at,
                                                                           "current_sign_in_at", "current_sign_in_ip",
                                                                           "reset_password_token", "reset_password_sent_at" ]  # contains similar symbols and strings
      expect(subject.instance_variable_get(:@update_add_files)).to eq true
      expect(subject.instance_variable_get(:@update_attrs_skip)).to eq [:creator_ordered,
                                                                        :curation_notes_admin_ordered, :curation_notes_user_ordered,
                                                                        :date_created, :date_modified, :date_uploaded,
                                                                        :edit_users,
                                                                        :keyword_ordered, :language_ordered,
                                                                        :original_name,
                                                                        :referenced_by_ordered, :title_ordered,
                                                                        :visibility ]
      expect(subject.instance_variable_get(:@update_attrs_skip_if_blank)).to eq [:creator_ordered, :curation_notes_admin, :curation_notes_admin_ordered,
                                                                                 :curation_notes_user, :curation_notes_user_ordered,
                                                                                 :checksum_algorithm, :checksum_value,
                                                                                 :description_ordered, :doi,
                                                                                 :fundedby_other, :keyword_ordered, :language_ordered,
                                                                                 :prior_identifier,
                                                                                 :referenced_by_ordered, :title_ordered ]
      expect(subject.instance_variable_get(:@update_build_mode)).to eq 'migrate'
      expect(subject.instance_variable_get(:@update_delete_files)).to eq true
      expect(subject.instance_variable_get(:@update_user_attrs_skip)).to eq [:created_at,
                                                                             :current_sign_in_at, :current_sign_in_ip,
                                                                             :email, :encrypted_password,
                                                                             :id,
                                                                             :updated_at,
                                                                             "current_sign_in_at", "current_sign_in_ip",
                                                                             "reset_password_token", "reset_password_sent_at" ]
      expect(subject.instance_variable_get(:@ingest_id)).to eq "yaml path"
      expect(subject.instance_variable_get(:@ingest_timestamp)).to eq "ingest timestamp"
      expect(subject.instance_variable_get(:@user_create)).to eq true
      expect(subject.instance_variable_get(:@stop_new_content_service)).to eq false
      expect(subject.instance_variable_get(:@stop_new_content_service_file)).to eq 'real dir path stop_umrdr_new_content'
      expect(subject.instance_variable_get(:@stop_new_content_service_ppid_file)).to eq 'real dir path process_ppid_stop_umrdr_new_content'
    }
  end


  describe "#log_msg" do
    context "when msg parameter is blank" do
      it "returns nil" do
        expect(subject).not_to receive(:logger)
        expect(subject.send(:log_msg, "")).to be_nil
      end
    end

    context "when msg parameter is present" do
      logger = MockLogger.new
      before {
        allow(subject).to receive(:timestamp_now).and_return "timestamp now"
        allow(subject).to receive(:logger).and_return logger
      }
      it "calls logger.info" do
        expect(logger).to receive(:info).with "timestamp now message"

        subject.send(:log_msg, "message")
      end
    end
  end


  describe "#log_verbose_msg" do
    context "when verbose parameter is false" do
      it "returns nil" do
        expect(subject).not_to receive(:log_msg).with("message")

        expect(subject.send(:log_verbose_msg, "message", verbose: false)).to be_nil
      end
    end

    context "when verbose parameter is true" do
      before {
        allow(subject).to receive(:log_msg).with("message")
      }
      it "calls log_msg with msg parameter" do
        expect(subject).to receive(:log_msg).with("message")

        subject.send(:log_verbose_msg, "message", verbose: true)
      end
    end
  end


  describe "#log_object" do
    before {
      allow(subject).to receive(:mode).and_return "append"
    }
    possible_objs = [{:obj => OpenStruct.new(prior_identifier: "hey", id: "prior ID", title: ["Title1", "Title2"]),
                      :msg => "append: OpenStruct id: prior ID title: Title1" },
                     {:obj => OpenStruct.new(email: "e-mail"), :msg => "append: OpenStruct id: e-mail" },
                     {:obj => OpenStruct.new(id: "this ID"), :msg => "append: OpenStruct id: this ID" },
                     {:obj => OpenStruct.new(none: "no"), :msg => "append: OpenStruct id: no_id" },
                     {:obj => OpenStruct.new(none: "no", title: ["A Title", "B Title"]), :msg => "append: OpenStruct id: no_id title: A Title" }]
    possible_objs.each do |possible_obj|
      context "when log_object is called with parameter #{possible_obj[:obj]}" do
        before {
          allow(subject).to receive(:log_msg).with possible_obj[:msg]
        }
        it "calls log_msg with #{possible_obj[:msg]}" do
          expect(subject).to receive(:log_msg).with possible_obj[:msg]
          subject.send(:log_object, possible_obj[:obj])
        end
      end
    end
  end


  describe "#log_provenance_add_child" do
    context "when parent parameter does NOT respond to provenance_child_add" do
      it "returns nil" do
        expect(subject).not_to receive(:ingest_id)
        expect(subject.send(:log_provenance_add_child, parent: nil, child: nil)).to be_nil
      end
    end

    context "when parent parameter responds to provenance_child_add" do
      before {
        allow(subject).to receive(:user).and_return "user"
        allow(subject).to receive(:ingest_id).and_return "ingest id"
        allow(subject).to receive(:ingester).and_return "ingester"
        allow(subject).to receive(:ingest_timestamp).and_return "ingest timestamp"
      }
      it "the parent parameter calls provenance_child_add" do
        parent = MockParent.new
        expect(parent).to receive(:provenance_child_add).with(current_user: "user", child_id: "child id", ingest_id: "ingest id", ingester: "ingester",
                                                              ingest_timestamp: "ingest timestamp")
        subject.send(:log_provenance_add_child, parent: parent, child: OpenStruct.new(id: "child id"))
      end
    end
  end


  describe "#log_provenance_fixity_check" do
    context "when the curation_concern parameter does NOT respond to provenance_fixity_check" do
      it "returns nil" do
        expect(subject).not_to receive(:user)

        expect(subject.send(:log_provenance_fixity_check, curation_concern: nil, fixity_check_status: nil, fixity_check_note: nil)).to be_nil
      end
    end

    context "when the curation_concern parameter responds to provenance_fixity_check" do
      before {
        allow(subject).to receive(:user).and_return "user"
      }
      it "the curation_concern parameter calls provenance_fixity_check" do
        creation = MockConcernCreation.new
        expect(creation).to receive(:provenance_fixity_check).with(current_user: "user", fixity_check_status: "status", fixity_check_note: "note")
        subject.send(:log_provenance_fixity_check, curation_concern: creation, fixity_check_status: "status", fixity_check_note: "note")
      end
    end
  end


  describe "#log_provenance_ingest" do
    context "when the curation_concern parameter does NOT respond to provenance_ingest" do
      it "returns nil" do
        expect(subject).not_to receive(:ingest_id)

        expect(subject.send(:log_provenance_ingest, curation_concern: nil)).to be_nil
      end
    end

    context "when the curation_concern parameter responds to provenance_ingest" do
      before {
        allow(subject).to receive(:user).and_return "user"
        allow(subject).to receive(:ingest_id).and_return "ingest id"
        allow(subject).to receive(:ingester).and_return "ingester"
        allow(subject).to receive(:ingest_timestamp).and_return "ingest timestamp"
      }
      it "the curation_concern parameter calls provenance_ingest" do
        cc = MockConcernCreation.new
        expect(cc).to receive(:provenance_ingest).with(current_user: "user", calling_class: "Deepblue::NewContentService", ingest_id: "ingest id",
                                                            ingester: "ingester", ingest_timestamp: "ingest timestamp")
        subject.send(:log_provenance_ingest, curation_concern: cc)
      end
    end
  end


  describe "#log_provenance_migrate" do
    concern = MockConcernCreation.new

    context "when the build_mode parameter is NOT equal to MODE_MIGRATE" do
      it "returns nil" do
        expect(subject).not_to receive(:user)
        expect(subject.send(:log_provenance_migrate, curation_concern: concern, build_mode: "append")).to be_nil
      end
    end

    context "when the build_mode parameter is MODE_MIGRATE" do
      context "when the curation_concern parameter does NOT respond to provenance_migrate" do
        it "returns nil" do
          expect(subject).not_to receive(:user)
          expect(subject.send(:log_provenance_migrate, curation_concern: nil, build_mode: "migrate")).to be_nil
        end
      end

      context "when the curation_concern parameter responds to provenance_migrate" do
        before {
          allow(subject).to receive(:user).and_return "user"
        }
        it "the curation_concern parameter calls provenance_migrate" do
          expect(concern).to receive(:provenance_migrate).with(current_user: "user", migrate_direction: "import")
          subject.send(:log_provenance_migrate, curation_concern: concern, build_mode: "migrate")
        end
      end
    end
  end


  describe "#log_provenance_workflow" do
    context "when the curation_concern parameter does NOT respond to provenance_workflow" do
      it "returns nil" do
        expect(subject).not_to receive(:user)

        expect(subject.send(:log_provenance_workflow, curation_concern: nil, workflow: OpenStruct.new(name: 'workflow'), workflow_state: "published")).to be_nil
      end
    end

    context "when the curation_concern parameter responds to provenance_workflow" do
      before {
        allow(subject).to receive(:user).and_return "user"
      }
      it "the curation_concern parameter calls provenance_workflow" do
        concern = MockConcernCreation.new
        expect(concern).to receive(:provenance_workflow).with(current_user: "user", workflow_name: "workflow", workflow_state: "published", workflow_state_prior: "")
        subject.send(:log_provenance_workflow, curation_concern: concern, workflow: OpenStruct.new(name: 'workflow'), workflow_state: "published")
      end
    end
  end


  describe "#logger" do
    context "when @logger has a value" do
      before {
        subject.instance_variable_set :@logger, "logs for life"
      }
      it "returns @logger" do
        expect(subject).not_to receive(:logger_initialize)

        expect(subject.send(:logger)).to eq "logs for life"
      end
    end

    context "when @logger has NO value" do
      before {
        subject.instance_variable_set :@logger, nil
        allow(subject).to receive(:logger_initialize).and_return "log me up"
      }
      it "calls logger_initialize and sets @logger to result" do
        expect(subject.send(:logger)).to eq "log me up"

        expect(subject.instance_variable_get(:@logger)).to eq "log me up"
      end
    end
  end


  describe "#logger_initialize" do
    before {
      allow(subject).to receive(:logger).and_return OpenStruct.new(info: "info")
      allow(Deepblue::TaskHelper).to receive(:logger_new).with(no_args)
    }
    it "calls TaskHelper.logger_new" do
      expect(Deepblue::TaskHelper).to receive(:logger_new).with(no_args)

      subject.send(:logger_initialize)
    end
  end


  describe "#logger_level" do
    before {
      allow(subject).to receive(:cfg_hash_value).with( key: :logger_level, default_value: 'info').and_return "informative logger level"
    }

    it "calls cfg_hash_value and returns result" do
      expect(subject).to receive(:cfg_hash_value).with( key: :logger_level, default_value: 'info')

      expect(subject.send(:logger_level)).to eq "informative logger level"
    end
  end


  describe "#measurements" do
    context "when @measurements has a value" do
      before {
        subject.instance_variable_set(:@measurements, ["measuring"])
      }
      it "returns @measurements" do
        expect(subject.send(:measurements)).to eq ["measuring"]
      end
    end

    context "when @measurements has NO value" do
      before {
        subject.instance_variable_set(:@measurements, nil)
      }
      it "sets @measurements to empty array and returns it" do
        expect(subject.send(:measurements)).to be_empty

        expect(subject.instance_variable_get(:@measurements)).to be_empty
      end
    end
  end


  describe "#mode" do
    context "when @mode has a value" do
      before {
        subject.instance_variable_set(:@mode, "in a good mode")
      }
      it "returns @mode" do
        expect(subject).not_to receive(:cfg_hash_value)

        expect(subject.send(:mode)).to eq "in a good mode"
      end
    end

    context "when @mode has NO value" do
      before {
        allow(subject).to receive(:cfg_hash_value).with( base_key: :user, key: :mode, default_value: 'append' ).and_return "BEST mode"
      }
      it "calls cfg_hash_value and sets @mode to the result" do
        expect(subject).to receive(:cfg_hash_value).with( base_key: :user, key: :mode, default_value: 'append' )

        expect(subject.send(:mode)).to eq "BEST mode"
        expect(subject.instance_variable_get(:@mode)).to eq "BEST mode"
      end
    end
  end


  describe "report" do
    context "when measurements parameter is blank" do
      it "returns nil" do
        expect(subject).not_to receive(:log_msg)

        expect(subject.send(:report, first_label: "first!!1", first_id: "identification", measurements: "")).to be_nil
      end
    end

    context "when measurements parameter is present" do
      measuring = [MockMeasurement.new("label1", 123), MockMeasurement.new("label2", 456),
                   MockMeasurement.new("label3", 789)]
      before {
        allow(subject).to receive(:log_msg).with "first!!1             user     system      total        real"
        allow(Deepblue::TaskHelper).to receive(:seconds_to_readable).with(123).and_return "123 seconds"
        allow(Deepblue::TaskHelper).to receive(:seconds_to_readable).with(456).and_return "456 seconds"
        allow(Deepblue::TaskHelper).to receive(:seconds_to_readable).with(789).and_return "789 seconds"
        allow(Deepblue::TaskHelper).to receive(:seconds_to_readable).with(91).and_return "91 seconds"

        allow(subject).to receive(:log_msg).with "label1 %10.6u %10.6y %10.6t %10.6r is 123 seconds"
        allow(subject).to receive(:log_msg).with "label2 %10.6u %10.6y %10.6t %10.6r is 456 seconds"
        allow(subject).to receive(:log_msg).with "label3 %10.6u %10.6y %10.6t %10.6r is 789 seconds"
        allow(subject).to receive(:log_msg).with "total          %10.6u %10.6y %10.6t %10.6r is 91 seconds"
      }

      context "when total parameter is present and measurements parameter size is greater than one" do
        it "calls log_msg with measurements and total parameters" do
          expect(subject).to receive(:log_msg).with "first!!1             user     system      total        real"
          expect(subject).to receive(:log_msg).with "label1 %10.6u %10.6y %10.6t %10.6r is 123 seconds"
          expect(subject).to receive(:log_msg).with "label2 %10.6u %10.6y %10.6t %10.6r is 456 seconds"
          expect(subject).to receive(:log_msg).with "label3 %10.6u %10.6y %10.6t %10.6r is 789 seconds"
          expect(subject).to receive(:log_msg).with "total          %10.6u %10.6y %10.6t %10.6r is 91 seconds"

          subject.send(:report, first_label: "first!!1", first_id: "identification", measurements: measuring, total: MockMeasurement.new("total", 91))
        end
      end

      context "when total parameter is blank" do
        it "calls log_msg with measurements parameter items" do
          expect(subject).to receive(:log_msg).with "first!!1             user     system      total        real"
          expect(subject).to receive(:log_msg).with "label1 %10.6u %10.6y %10.6t %10.6r is 123 seconds"
          expect(subject).to receive(:log_msg).with "label2 %10.6u %10.6y %10.6t %10.6r is 456 seconds"
          expect(subject).to receive(:log_msg).with "label3 %10.6u %10.6y %10.6t %10.6r is 789 seconds"

          subject.send(:report, first_label: "first!!1", first_id: "identification", measurements: measuring, total: nil)
        end
      end

      context "when measurements parameter size is one" do
        it "calls log_msg with measurements parameter item" do
          expect(subject).to receive(:log_msg).with "first!!1             user     system      total        real"
          expect(subject).to receive(:log_msg).with "label1 %10.6u %10.6y %10.6t %10.6r is 123 seconds"
          expect(subject).not_to receive(:log_msg).with "total          %10.6u %10.6y %10.6t %10.6r is 91 seconds"

          meagre = [MockMeasurement.new("label1", 123)]
          subject.send(:report, first_label: "first!!1", first_id: "identification", measurements: meagre, total: MockMeasurement.new("total", 91))
        end
      end
    end
  end


  describe "#report_measurements" do
    context "when measurements is blank" do
      before {
        allow(subject).to receive(:measurements).and_return ""
      }
      it "returns nil" do
        expect(subject).to receive(:measurements)
        expect(subject).not_to receive(:log_msg)

        expect(subject.send(:report_measurements, first_label: "first!!1")).to be_nil
      end
    end

    context "when measurements is present" do
      measured = [MockMeasurement.new("label1"), MockMeasurement.new("label2"), MockMeasurement.new("label3")]
      before {
        allow(subject).to receive(:measurements).and_return measured
        allow(subject).to receive(:puts)
        allow(subject).to receive(:log_msg).with "Report run time:"
        allow(subject).to receive(:report).with(first_label: "first!!1", first_id: "label1", measurements: measured, total: "label1label2label3")
      }
      it "calls report function" do
        expect(subject).to receive(:measurements)
        expect(subject).to receive(:puts)
        expect(subject).to receive(:log_msg).with "Report run time:"
        expect(subject).to receive(:report).with(first_label: "first!!1", first_id: "label1", measurements: measured, total: "label1label2label3")

        subject.send(:report_measurements, first_label: "first!!1")
      end
    end
  end


  describe "#source" do
    context "when @source has a value" do
      before {
        subject.instance_variable_set(:@source, "sorceror")
      }
      it "returns @source" do
        expect(subject).not_to receive(:valid_restricted_vocab)

        expect(subject.send(:source)).to eq "sorceror"
      end
    end

    context "when @source is nil" do
      before {
        subject.instance_variable_set(:@cfg_hash, :user => {:source => "source of user"})
        allow(subject).to receive(:valid_restricted_vocab).with( "source of user", var: :source, vocab: %w[DBDv1 DBDv2] ).and_return "user resources"
      }
      it "sets @source to the value of valid_restricted_vocab and returns it" do
        expect(subject).to receive(:valid_restricted_vocab).with( "source of user", var: :source, vocab: %w[DBDv1 DBDv2] )
        expect(subject.send(:source)).to eq "user resources"

        expect(subject.instance_variable_get(:@source)).to eq "user resources"
      end
    end
  end


  describe "#timestamp_now" do
    before {
      allow(Time).to receive(:now).and_return DateTime.new(2010, 10, 10, 10, 10, 10)
    }
    it "returns the current time as a string in SQL database format" do
      expect(subject.send(:timestamp_now)).to eq "2010-10-10 10:10:10"
    end
  end


  describe "#update_attr" do
    context "when update_attr? with the attr_name parameter returns false" do
      before {
        allow(subject).to receive(:update_attr?).with("attr_name").and_return false
      }
      it "returns the updates parameter" do
        expect(subject).not_to receive(:value_from_attr)
        expect(subject.send(:update_attr, "updates", "cc_or_fs", "cc_or_fs_hash", attr_name: "attr_name")).to eq "updates"
      end
    end

    context "when update_attr? with the attr_name parameter returns true" do
      before {
        allow(subject).to receive(:update_attr?).with("attr_name").and_return true
      }

      context "when update_attr_if_blank? returns false" do
        before {
          allow(subject).to receive(:value_from_attr).with("cc_or_fs_hash", attr_name: "attr_name", attr_name_hash: nil, multi: true).and_return "the value"
          allow(subject).to receive(:update_attr_if_blank?).with( value: "the value").and_return false
        }
        it "returns the updates parameter" do
          expect(subject).not_to receive(:attr_prefix)

          expect(subject.send(:update_attr, "updates", {"attr_name" => "attr_current"}, "cc_or_fs_hash", attr_name: "attr_name")).to eq "updates"
        end
      end

      context "when update_attr_if_blank? returns true" do
        context "when cc_or_fs[attr_name] is equal to the result of value_from_attr" do
          before {
            allow(subject).to receive(:update_attr_if_blank?).with( value: "attr_current").and_return true
            allow(subject).to receive(:value_from_attr).with("cc_or_fs_hash", attr_name: "attr_name", attr_name_hash: nil, multi: true).and_return "attr_current"
          }
          it "returns the updates parameter" do
            expect(subject).to receive(:update_attr_if_blank?).with( value: "attr_current")
            expect(subject).not_to receive(:attr_prefix)

            expect(subject.send(:update_attr, "updates", {"attr_name" => "attr_current"}, "cc_or_fs_hash", attr_name: "attr_name")).to eq "updates"
          end
        end

        context "when cc_or_fs[attr_name] is NOT equal to the result of value_from_attr" do
          before {
            allow(subject).to receive(:update_attr_if_blank?).with( value: "another value").and_return true
            allow(subject).to receive(:value_from_attr).with("cc_or_fs_hash", attr_name: "attr_name", attr_name_hash: nil, multi: true)
                                                       .and_return "another value"
            allow(subject).to receive(:attr_prefix).with({"attr_name" => "another value"}).and_return " prefix"
          }
          it "returns the updates parameter with a message appended" do
            expect(subject).to receive(:update_attr_if_blank?).with( value: "another value")
            expect(subject).to receive(:attr_prefix).with({"attr_name" => "another value"})

            expect(subject.send(:update_attr, "updates", {"attr_name" => "attr_current"}, "cc_or_fs_hash", attr_name: "attr_name"))
              .to eq "updates prefix: attr_name 'attr_current' updated to 'another value'"
          end
        end
      end

      context "when update_attr_if_blank? raises an Exception" do
        before {
          allow(subject).to receive(:value_from_attr).with("cc_or_fs_hash", attr_name: "attr_name", attr_name_hash: nil, multi: true).and_return "attr_current"
          allow(subject).to receive(:update_attr_if_blank?).with( value: "attr_current").and_raise(Exception, "an error")
          allow(subject).to receive(:attr_prefix).with({"attr_name" => "attr_current"}).and_return " prefix"
        }

        it "returns updates parameter with error message appended" do
          expect(subject).to receive(:update_attr_if_blank?).with( value: "attr_current")
          expect(subject).to receive(:attr_prefix).with({"attr_name" => "attr_current"})

          result = subject.send(:update_attr, "updates", {"attr_name" => "attr_current"}, "cc_or_fs_hash", attr_name: "attr_name")
          expect(result.start_with?("updates prefix: attr_name -- Exception: Exception: an error at ")).to eq true
        end
      end

      after {
        expect(subject).to have_received(:value_from_attr).with("cc_or_fs_hash", attr_name: "attr_name", attr_name_hash: nil, multi: true)
      }
    end

    after {
      expect(subject).to have_received(:update_attr?).with "attr_name"
    }
  end


  describe "#update_attr?" do
    context "when update_attrs_skip includes parameter" do
      before {
        allow(subject).to receive(:update_attrs_skip).and_return ["diamond", "emerald", "corundum"]
      }
      it "returns false" do
        expect(subject.send(:update_attr?, "corundum")).to eq false
      end
    end

    context "when update_attrs_skip does NOT include parameter" do
      before {
        allow(subject).to receive(:update_attrs_skip).and_return ["ruby", "sapphire"]
      }
      it "returns true" do
        expect(subject.send(:update_attr?, "corundum")).to eq true
      end
    end
  end


  describe "#update_attr_if_blank?" do
    context "when value parameter is blank" do
      it "returns false" do
        expect(subject.send(:update_attr_if_blank?, value: "")).to eq false
      end
    end

    context "when value parameter is present" do
      it "returns true" do
        expect(subject.send(:update_attr_if_blank?, value: "almond")).to eq true
      end
    end
  end


  describe "#update_attr_doi" do
    calls = [{:doi => "mint_then", :allow_minting => true},
             {:doi => "mint_now", :allow_minting => false}]
    calls.each do |call|
      context "when cc_or_fs_hash[:doi] parameter value is NOT equal to 'mint_now' and allow_minting parameter is true" do
        before {
          allow(subject).to receive(:update_attr).with("updates", "cc_or_fs", {:doi => call[:doi]}, attr_name: :doi, multi: false).and_return "update attr"
        }
        it "returns result of update_attr function" do
          expect(subject).to receive(:update_attr)
          expect(subject.send(:update_attr_doi, "updates", "cc_or_fs", {:doi => call[:doi]}, allow_minting: call[:allow_minting])).to eq "update attr"
        end
      end
    end

    context "when cc_or_fs_hash[:doi] is equal to 'mint_now' and allow_minting parameter is true" do

      context "when function update_attr_doi executes successfully" do
        before {
          allow(subject).to receive(:doi_mint).with(curation_concern: "cc_or_fs")
        }
        it "calls doi_mint function and returns updates parameter" do
          expect(subject).not_to receive(:update_attr)
          expect(subject).not_to receive(:attr_prefix)

          expect(subject.send(:update_attr_doi, "updates", "cc_or_fs", {:doi => "mint_now"}, allow_minting: true)).to eq "updates"
        end
      end

      context "when doi_mint function raises an Exception" do
        before {
          allow(subject).to receive(:doi_mint).with(curation_concern: "cc_or_fs").and_raise(Exception, "doi exception")
          allow(subject).to receive(:attr_prefix).with("cc_or_fs").and_return " prefix"
        }
        it "returns updates parameter with error message appended" do
          expect(subject).to receive(:attr_prefix).with("cc_or_fs")
          expect(subject).not_to receive(:update_attr)

          result = subject.send(:update_attr_doi, "updates", "cc_or_fs", {:doi => "mint_now"}, allow_minting: true)
          expect(result.start_with? "updates prefix: attr_doi -- Exception: Exception: doi exception at ").to eq true
        end
      end

      after {
        expect(subject).to have_received(:doi_mint).with(curation_concern: "cc_or_fs")
      }
    end
  end


  describe "#update_attr_value" do
    context "when calling the update_attr? function with the attr_name parameter returns false" do
      before {
        allow(subject).to receive(:update_attr?).with("attr_name").and_return false
      }
      it "returns the updates parameter" do
        expect(subject).not_to receive(:update_attr_if_blank?)

        expect(subject.send(:update_attr_value, "updates", "cc_of_fs", attr_name: "attr_name")).to eq "updates"
      end
    end

    context "when calling the update_attr? function with the attr_name parameter returns true" do
      before {
        allow(subject).to receive(:update_attr?).with("attr_name").and_return true
      }

      context "when calling the update_attr_if_blank? function with the value parameter returns false" do
        before {
          allow(subject).to receive(:update_attr_if_blank?).with(value: nil).and_return false
        }
        it "returns the updates parameter" do
          expect(subject.send(:update_attr_value, "updates", "cc_of_fs", attr_name: "attr_name")).to eq "updates"
        end
      end

      context "when calling the update_attr_if_blank? function with the value parameter returns true" do
        before {
          allow(subject).to receive(:update_attr_if_blank?).with(value: "value").and_return true
        }
        context "when cc_or_fs[attr_name] is equal to value parameter" do
          it "returns the updates parameter" do
            expect(subject.send(:update_attr_value, "updates", {"attr_name" => "value"}, attr_name: "attr_name", value: "value")).to eq "updates"
          end
        end

        context "when cc_or_fs[attr_name] is NOT equal to value parameter" do
          before {
            allow(subject).to receive(:attr_prefix).with({"attr_name" => "value"}).and_return " prefix"
          }
          it "returns the updates parameter with message appended" do
            expect(subject).to receive(:attr_prefix).with({"attr_name" => "value"})
            expect(subject.send(:update_attr_value, "updates", {"attr_name" => "attr_current"}, attr_name: "attr_name", value: "value"))
              .to eq "updates prefix: attr_name 'attr_current' updated to 'value'"
          end
        end
      end

      context "when the update_attr_if_blank? function raises an Exception" do
        before {
          allow(subject).to receive(:update_attr_if_blank?).with(value: "value").and_raise(Exception, "exception raised")
          allow(subject).to receive(:attr_prefix).with({"attr_name" => "attr_current"}).and_return " prefix"
        }
        it "returns the updates parameter with error message appended" do
          expect(subject).to receive(:attr_prefix).with({"attr_name" => "attr_current"})
          result = subject.send(:update_attr_value, "updates", {"attr_name" => "attr_current"}, attr_name: "attr_name", value: "value")
          expect(result.start_with?("updates prefix: attr_name -- Exception: Exception: exception raised at ")).to eq true
        end
      end

      after {
        expect(subject).to have_received(:update_attr_if_blank?)
      }
    end

    after {
      expect(subject).to have_received(:update_attr?).with("attr_name")
    }
  end


  describe "#update_cc_attribute" do
    it "adds attribute and value parameters to curation_concern parameter hash" do
      curator = {}
      expect(subject.send(:update_cc_attribute, curation_concern: curator, attribute: "fantastic", value: "phoenix")).to eq "phoenix"
      expect(curator["fantastic"]).to eq "phoenix"
    end
  end


  describe "#update_cc_edit_users" do
    context "when edit_users parameter is blank" do
      it "returns nil" do
        expect(subject).not_to receive(:user_create_users)

        expect(subject.send(:update_cc_edit_users, curation_concern: "concern", edit_users: "")).to be_nil
      end
    end

    context "when edit_users parameter is present" do
      before {
        allow(subject).to receive(:user_create_users).with(emails: "nu users")
      }
      it "calls user_create_users" do
        expect(subject).to receive(:user_create_users).with(emails: "nu users")

        concern = OpenStruct.new(edit_users: "")
        expect(subject.send(:update_cc_edit_users, curation_concern: concern, edit_users: "nu users")).to eq "nu users"
        expect(concern.edit_users).to eq "nu users"
      end
    end
  end


  describe "#update_collection" do
    collection_hash = {:description => "good description", :resource_type => "typical resource"}

    before {
      allow(subject).to receive(:update_attr).with( [], "collection", collection_hash, attr_name: :creator )
      allow(subject).to receive(:update_attr).with( [], "collection", collection_hash, attr_name: :creator_ordered, multi: false )
      allow(subject).to receive(:update_attr).with( [], "collection", collection_hash, attr_name: :curation_notes_admin )
      allow(subject).to receive(:update_attr).with( [], "collection", collection_hash, attr_name: :curation_notes_admin_ordered, multi: false )
      allow(subject).to receive(:update_attr).with( [], "collection", collection_hash, attr_name: :curation_notes_user )
      allow(subject).to receive(:update_attr).with( [], "collection", collection_hash, attr_name: :curation_notes_user_ordered, multi: false )

      allow(subject).to receive(:build_date).with( hash: collection_hash, key: :date_created ).and_return "date created"
      allow(subject).to receive(:build_date).with( hash: collection_hash, key: :date_modified ).and_return "date modified"
      allow(subject).to receive(:build_date).with( hash: collection_hash, key: :date_uploaded ).and_return "date uploaded"

      allow(subject).to receive(:update_attr_value).with( [], "collection", attr_name: :date_created, value: "date created")
      allow(subject).to receive(:update_attr_value).with( [], "collection", attr_name: :date_modified, value: "date modified" )
      allow(subject).to receive(:update_attr_value).with( [], "collection", attr_name: :date_uploaded, value: "date uploaded")

      allow(subject).to receive(:build_depositor).with( hash: collection_hash ).and_return "depositor"
      allow(subject).to receive(:update_attr_value).with( [], "collection", attr_name: :depositor, value: "depositor" )
      allow(subject).to receive(:default_description).with(collection_hash[:description]).and_return "description"
      allow(subject).to receive(:update_attr_value).with( [], "collection", attr_name: :description, value: "description" )
      allow(subject).to receive(:update_attr).with( [], "collection", collection_hash, attr_name: :description_ordered, multi: false )

      allow(subject).to receive(:update_edit_users).with( [], "collection", collection_hash )
      allow(subject).to receive(:update_attr).with( [], "collection", collection_hash, attr_name: :keyword )
      allow(subject).to receive(:update_attr).with( [], "collection", collection_hash, attr_name: :keyword_ordered, multi: false )
      allow(subject).to receive(:update_attr).with( [], "collection", collection_hash, attr_name: :language )
      allow(subject).to receive(:update_attr).with( [], "collection", collection_hash, attr_name: :language_ordered, multi: false )
      allow(subject).to receive(:update_attr).with( [], "collection", collection_hash, attr_name: :prior_identifier )

      allow(subject).to receive(:build_referenced_by).with( hash: collection_hash ).and_return "build ref by"
      allow(subject).to receive(:update_attr_value).with( [], "collection", attr_name: :referenced_by, value: "build ref by" )

      allow(subject).to receive(:default_collection_resource_type).with(resource_type: collection_hash[:resource_type]).and_return "resource type"
      allow(subject).to receive(:update_attr_value).with( [], "collection", attr_name: :resource_type, value: "resource type" )

      allow(subject).to receive(:build_subject_discipline).with( hash: collection_hash ).and_return "subject discipline"
      allow(subject).to receive(:update_attr_value).with( [], "collection", attr_name: :subject_discipline, value: "subject discipline")
      allow(subject).to receive(:update_attr).with( [], "collection", collection_hash, attr_name: :title )
      allow(subject).to receive(:update_attr).with( [], "collection", collection_hash, attr_name: :title_ordered, multi: false )
      # NOTE:  updates are always empty at this point
    }

    context "when update_collections_recurse evaluates to false" do
      before {
        allow(subject).to receive(:update_collections_recurse).and_return false
      }
      it "returns updates parameter as an array" do
        expect(subject).not_to receive(:update_collection_works)

        expect(subject.send(:update_collection, updates: ["updates"], collection: "collection", collection_hash: collection_hash)).to eq ["updates"]
      end
    end

    context "when update_collections_recurse evaluates to true" do
      before {
        allow(subject).to receive(:update_collections_recurse).and_return true
        allow(subject).to receive(:update_collection_works).with( updates: [], collection: "collection", collection_hash: collection_hash ).and_return "works"
      }
      it "calls update_collection_works and returns updates parameter concatenated with result" do
        expect(subject).to receive(:update_collection_works).with( updates: [], collection: "collection", collection_hash: collection_hash )
        expect(subject.send(:update_collection, updates: "updates ", collection: "collection", collection_hash: collection_hash)).to eq "updates works"
      end
    end

    after {
      expect(subject).to have_received(:update_attr).with( [], "collection", collection_hash, attr_name: :creator )
      expect(subject).to have_received(:update_attr).with( [], "collection", collection_hash, attr_name: :creator_ordered, multi: false )
      expect(subject).to have_received(:update_attr).with( [], "collection", collection_hash, attr_name: :curation_notes_admin )
      expect(subject).to have_received(:update_attr).with( [], "collection", collection_hash, attr_name: :curation_notes_admin_ordered, multi: false )
      expect(subject).to have_received(:update_attr).with( [], "collection", collection_hash, attr_name: :curation_notes_user )
      expect(subject).to have_received(:update_attr).with( [], "collection", collection_hash, attr_name: :curation_notes_user_ordered, multi: false )

      expect(subject).to have_received(:update_attr_value).with( [], "collection", attr_name: :date_created, value: "date created")
      expect(subject).to have_received(:update_attr_value).with( [], "collection", attr_name: :date_modified, value: "date modified" )
      expect(subject).to have_received(:update_attr_value).with( [], "collection", attr_name: :date_uploaded, value: "date uploaded")

      expect(subject).to have_received(:update_attr_value).with( [], "collection", attr_name: :depositor, value: "depositor" )
      expect(subject).to have_received(:update_attr_value).with( [], "collection", attr_name: :description, value: "description" )
      expect(subject).to have_received(:update_attr).with( [], "collection", collection_hash, attr_name: :description_ordered, multi: false )

      expect(subject).to have_received(:update_edit_users).with( [], "collection", collection_hash )
      expect(subject).to have_received(:update_attr).with( [], "collection", collection_hash, attr_name: :keyword )
      expect(subject).to have_received(:update_attr).with( [], "collection", collection_hash, attr_name: :keyword_ordered, multi: false )
      expect(subject).to have_received(:update_attr).with( [], "collection", collection_hash, attr_name: :language )
      expect(subject).to have_received(:update_attr).with( [], "collection", collection_hash, attr_name: :language_ordered, multi: false )
      expect(subject).to have_received(:update_attr).with( [], "collection", collection_hash, attr_name: :prior_identifier )

      expect(subject).to have_received(:update_attr_value).with( [], "collection", attr_name: :referenced_by, value: "build ref by" )
      expect(subject).to have_received(:update_attr_value).with( [], "collection", attr_name: :resource_type, value: "resource type" )

      expect(subject).to have_received(:update_attr_value).with( [], "collection", attr_name: :subject_discipline, value: "subject discipline")
      expect(subject).to have_received(:update_attr).with( [], "collection", collection_hash, attr_name: :title )
      expect(subject).to have_received(:update_attr).with( [], "collection", collection_hash, attr_name: :title_ordered, multi: false )
      expect(subject).to have_received(:update_collections_recurse)
    }
  end


  describe "#update_collection_works" do
    context "when collection.member_objects parameter is empty and works_from_hash returns empty result" do
      before {
        allow(subject).to receive(:works_from_hash).with(hash: nil).and_return []
      }
      it "returns updates parameter" do
        expect(subject.send(:update_collection_works, updates: "updates", collection: OpenStruct.new(member_objects: []), collection_hash: nil))
          .to eq "updates"
      end
    end

    context "when collection.member_objects parameter has values and continue_new_content_service evaluates to false" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return nil
      }
      it "returns updates parameter" do
        expect(subject).to receive(:continue_new_content_service)
        expect(subject).not_to receive(:works_from_hash)

        expect(subject.send(:update_collection_works, updates: "updates", collection: OpenStruct.new(member_objects: [1, 2]), collection_hash: nil))
          .to eq "updates"
      end
    end

    context "when continue_new_content_service evaluates to true" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return true
      }

      context "when collection.member_objects parameter has values" do
        member_obj1 = OpenStruct.new(id: 1)
        member_obj3 = OpenStruct.new(id: 3)
        collection = OpenStruct.new(member_objects: [member_obj1, member_obj3])

        before {
          allow(Deepblue::TaskHelper).to receive(:work?).with(member_obj1).and_return true
          allow(Deepblue::TaskHelper).to receive(:work?).with(member_obj3).and_return true
        }

        context "when works_from_hash returns blank" do
          before {
            allow(subject).to receive(:works_from_hash).with( hash: "collection hash").and_return ""
          }
          it "returns updates parameter" do
            expect(subject).to receive(:continue_new_content_service).twice
            expect(subject.send(:update_collection_works, updates: "updates", collection_hash: "collection hash",
                                collection: collection)).to eq "updates"
          end
        end

        context "when works_from_hash returns values" do
          before {
            allow(subject).to receive(:works_from_hash).with( hash: "collection hash" ).and_return [[1,2]]
            allow(subject).to receive(:work_hash_from_id).with( parent_hash: "collection hash", work_id: "1" ).and_return "work hash"
            allow(subject).to receive(:update_work).with( updates: "updates", work_hash: "work hash", work: member_obj1 )
            allow(subject).to receive(:attr_prefix).with( collection ).and_return " prefix"
          }
          it "returns updates parameter" do
            expect(subject).to receive(:continue_new_content_service).exactly(5).times
            expect(subject).to receive(:work_hash_from_id).with( parent_hash: "collection hash", work_id: "1" )
            expect(subject).to receive(:attr_prefix).with( collection ).twice

            expect(subject.send(:update_collection_works, updates: "updates", collection_hash: "collection hash",
                                collection: collection)).to eq "updates prefix: is missing work 2 prefix: has extra work 3"
          end
        end

        after {
          expect(subject).to have_received(:works_from_hash)
          expect(Deepblue::TaskHelper).to have_received(:work?).twice
        }
      end
    end
  end


  describe "#update_collections" do
    context "when collections function returns nil" do
      before {
        allow(subject).to receive(:collections).and_return nil
      }
      it "returns nil" do
        expect(subject).not_to receive(:continue_new_content_service)

        expect(subject.send(:update_collections)).to be_nil
      end
    end

    context "when collections function returns empty array" do
      before {
        allow(subject).to receive(:collections).and_return []
      }
      it "returns empty array" do
        expect(subject).not_to receive(:continue_new_content_service)

        expect(subject.send(:update_collections)).to be_empty
      end
    end

    context "when collections function returns results" do
      before {
        allow(subject).to receive(:collections).and_return [nil, "collection hash 1", "collection hash 2"]
      }

      context "when continue_new_content_service function returns false" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return false
        }
        it "returns result of collections function" do
          expect(subject).to receive(:collections)
          expect(subject).to receive(:continue_new_content_service)
          expect(subject.send(:update_collections)).to eq [nil, "collection hash 1", "collection hash 2"]
        end
      end

      context "when continue_new_content_service function returns true" do
        measurement = MockMeasurement.new
        before {
          allow(subject).to receive(:continue_new_content_service).and_return true
          allow(Benchmark).to receive(:measure).and_return measurement
          allow(subject).to receive(:find_collection).with(collection_hash: "collection hash 1").and_return ["collection 1", "collection id 1"]
          allow(subject).to receive(:find_collection).with(collection_hash: "collection hash 2").and_return [nil, "collection id 2"]
          allow(subject).to receive(:update_collection).with(collection_hash: "collection hash 1", collection: "collection 1").and_return ["update1", "update1.1"]
          allow(subject).to receive(:attr_prefix).with("collection 1").and_return "prefix collection"
          allow(subject).to receive(:add_measurement).with(measurement)
        }
        it "finds and updates collections and returns result of collections function" do
          expect(subject).to receive(:collections)
          expect(subject).to receive(:continue_new_content_service).twice
          expect(Benchmark).to receive(:measure)
          expect(subject.send(:update_collections)).to eq [nil, "collection hash 1", "collection hash 2"]
        end

        skip "add tests for inside Benchmark.measure do end"
      end
    end
  end


  describe "#update_edit_users" do
    context "when calling diff_attr? with :edit_users returns false" do
      before {
        allow(subject).to receive(:diff_attr?).with(:edit_users).and_return false
      }
      it "returns the updates parameter" do
        expect(subject).not_to receive(:diff_attr_if_blank?)
        expect(subject.send(:update_edit_users, "updates", "cc_of_fs", "cc_of_fs_hash")).to eq "updates"
      end
    end

    context "when calling diff_attr? with :edit_users returns true" do
      before {
        allow(subject).to receive(:diff_attr?).with(:edit_users).and_return true
      }

      context "when diff_attr_if_blank? returns false" do
        before {
          allow(subject).to receive(:diff_attr_if_blank?).with(:edit_users, value: ["them"]).and_return false
        }
        it "returns the updates parameter" do
          expect(subject).to receive(:diff_attr_if_blank?)
          expect(subject.send(:update_edit_users, "updates", OpenStruct.new(edit_users: "edit users"), {:edit_users => "them"})).to eq "updates"
        end
      end

      context "when diff_attr_if_blank? returns true" do
        context "when xor variable is NOT empty" do
          before {
            allow(subject).to receive(:diff_attr_if_blank?).with(:edit_users, value: [9]).and_return true
            allow(subject).to receive(:attr_prefix).with(OpenStruct.new(edit_users: [9])).and_return " prefix"
          }
          it "returns diffs parameter with appended text" do
            expect(subject).to receive(:diff_attr_if_blank?).with(:edit_users, value: [9])
            expect(subject).to receive(:attr_prefix).with(OpenStruct.new(edit_users: [9]))
            expect(subject.send(:update_edit_users, "diffs", OpenStruct.new(edit_users: [6]), {:edit_users => 9}))
              .to eq "diffs prefix: edit_users '[6]' updated to '[9]'"
          end
        end

        context "when xor variable is empty" do
          before {
            allow(subject).to receive(:diff_attr_if_blank?).with(:edit_users, value: []).and_return true
          }
          it "returns diffs parameter" do
            expect(subject).to receive(:diff_attr_if_blank?).with(:edit_users, value: [])
            expect(subject).not_to receive(:attr_prefix)

            expect(subject.send(:update_edit_users, "diffs", OpenStruct.new(edit_users: []), {:edit_users => nil})).to eq "diffs"
          end
        end
      end

      context "when diff_attr? :edit_users causes Exception" do
        before {
          allow(subject).to receive(:diff_attr?).with(:edit_users).and_raise(Exception, "error message")
          allow(subject).to receive(:attr_prefix).with("cc_or_fs").and_return " prefix"
        }
        it "returns diffs parameter" do
          expect(subject).to receive(:attr_prefix).with("cc_or_fs")

          result = subject.send(:diff_edit_users, "diffs", "cc_or_fs", "cc_or_fs_hash")
          expect result.start_with?("diffs prefix: edit_users -- Exception: Exception: error message at ") == true
        end
      end
    end
  end


  describe "#update_file_set" do
    context "when continue_new_content_service returns false" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return false
      }
      it "returns updates parameter" do
        expect(subject).not_to receive(:update_attr)

        expect(subject.send(:update_file_set, updates: "updates", file_set: "file set", file_set_hash: "file set hash")).to eq "updates"
      end
    end

    context "when continue_new_content_service returns true" do
      file_set = MockUpdateFileSet.new("original name value", "visible")
      file_set_hash = {:original_name => "original name"}
      before {
        allow(subject).to receive(:continue_new_content_service).and_return true
        allow(subject).to receive(:update_attr).with( [], file_set, file_set_hash, attr_name: :curation_notes_admin )
        allow(subject).to receive(:update_attr).with( [], file_set, file_set_hash, attr_name: :curation_notes_admin_ordered, multi: false )
        allow(subject).to receive(:update_attr).with( [], file_set, file_set_hash, attr_name: :curation_notes_user )
        allow(subject).to receive(:update_attr).with( [], file_set, file_set_hash, attr_name: :curation_notes_user_ordered, multi: false )

        allow(subject).to receive(:build_date).with( hash: file_set_hash, key: :date_created ).and_return "date created"
        allow(subject).to receive(:build_date).with( hash: file_set_hash, key: :date_modified ).and_return "date modified"
        allow(subject).to receive(:build_date).with( hash: file_set_hash, key: :date_uploaded ).and_return "date uploaded"

        allow(subject).to receive(:update_attr_value).with( [], file_set, attr_name: :date_created, value: "date created" )
        allow(subject).to receive(:update_attr_value).with( [], file_set, attr_name: :date_modified, value: "date modified" )
        allow(subject).to receive(:update_attr_value).with( [], file_set, attr_name: :date_uploaded, value: "date uploaded")
        allow(subject).to receive(:build_depositor).with( hash: file_set_hash ).and_return "depositor"
        allow(subject).to receive(:update_attr_value).with( [], file_set, attr_name: :depositor, value: "depositor" )

        allow(subject).to receive(:update_edit_users).with( [], file_set, file_set_hash )
        allow(subject).to receive(:update_attr).with( [], file_set, file_set_hash, attr_name: :label, multi: false )
        allow(subject).to receive(:update_value_value).with( [], file_set, attr_name: :original_name, current_value: file_set.original_name_value, value: file_set_hash[:original_name] )
        allow(subject).to receive(:update_attr).with( [], file_set, file_set_hash, attr_name: :prior_identifier )
        allow(subject).to receive(:update_attr).with( [], file_set, file_set_hash, attr_name: :title )
        allow(subject).to receive(:visibility_from_hash).with( hash: file_set_hash ).and_return "visibility"
        allow(subject).to receive(:update_value_value).with( [], file_set, attr_name: :visibility, current_value: file_set.visibility, value: "visibility" )
      }
      context "when updates parameter is NOT empty" do
        it "updates and saves file set and returns updates" do
          #expect(file_set).to receive(:save!)  NOTE: updates is always going to be empty
          expect(subject.send(:update_file_set, updates: ["updates"], file_set: file_set, file_set_hash: file_set_hash)).to eq ["updates"]
        end
      end

      empties = [[], nil]                                    # errors with empty string
      empties.each do |update|
        context "when updates parameter is #{update}" do
          it "updates file set and returns empty array" do
            expect(file_set).not_to receive(:save!)
            expect(subject.send(:update_file_set, updates: update, file_set: file_set, file_set_hash: file_set_hash)).to eq []
          end
        end
      end

      after {
        expect(subject).to have_received(:continue_new_content_service)
        expect(subject).to have_received(:update_attr).with( [], file_set, file_set_hash, attr_name: :curation_notes_admin )
        expect(subject).to have_received(:update_attr).with( [], file_set, file_set_hash, attr_name: :curation_notes_admin_ordered, multi: false )
        expect(subject).to have_received(:update_attr).with( [], file_set, file_set_hash, attr_name: :curation_notes_user )
        expect(subject).to have_received(:update_attr).with( [], file_set, file_set_hash, attr_name: :curation_notes_user_ordered, multi: false )

        expect(subject).to have_received(:update_attr_value).with( [], file_set, attr_name: :date_created, value: "date created" )
        expect(subject).to have_received(:update_attr_value).with( [], file_set, attr_name: :date_modified, value: "date modified" )
        expect(subject).to have_received(:update_attr_value).with( [], file_set, attr_name: :date_uploaded, value: "date uploaded")
        expect(subject).to have_received(:update_attr_value).with( [], file_set, attr_name: :depositor, value: "depositor" )

        expect(subject).to have_received(:update_edit_users).with( [], file_set, file_set_hash )
        expect(subject).to have_received(:update_attr).with( [], file_set, file_set_hash, attr_name: :label, multi: false )
        expect(subject).to have_received(:update_value_value).with( [], file_set, attr_name: :original_name, current_value: file_set.original_name_value, value: file_set_hash[:original_name] )
        expect(subject).to have_received(:update_attr).with( [], file_set, file_set_hash, attr_name: :prior_identifier )
        expect(subject).to have_received(:update_attr).with( [], file_set, file_set_hash, attr_name: :title )
        expect(subject).to have_received(:update_value_value).with( [], file_set, attr_name: :visibility, current_value: file_set.visibility, value: "visibility" )
      }
    end

    after {
      expect(subject).to have_received(:continue_new_content_service).once
    }
  end


  describe "#update_file_sets" do
    context "when work_hash[:file_set_ids] parameter has a value" do
      work_hash = {:file_set_ids => "file set ids"}
      before {
        allow(subject).to receive(:update_file_sets_from_file_set_ids).with(updates: "updates", work_hash: work_hash, work: "work")
                                                                      .and_return "from file set ids"
      }
      it "returns result of update_file_sets_from_file_set_ids" do
        expect(subject).to receive(:update_file_sets_from_file_set_ids).with(updates: "updates", work_hash: work_hash, work: "work")
        expect(subject.send(:update_file_sets, updates: "updates", work_hash: work_hash, work: "work")).to eq "from file set ids"
      end
    end

    context "when work_hash[:file_set_ids] parameter has NO value" do
      it "returns updates" do
        expect(subject).not_to receive(:update_file_sets_from_file_set_ids)

        expect(subject.send(:update_file_sets, updates: "updates", work_hash: {:file_set_ids => ""}, work: "work")).to eq "updates"
      end
    end
  end


  describe "#update_file_sets_from_file_set_ids" do
    context "when update_add_files returns true" do
      work1 = OpenStruct.new(id: "1")
      work = OpenStruct.new(file_sets: [work1, OpenStruct.new(id: "2")])
      work_hash = {:file_set_ids => ["1", "3"], :f_1 => "file set hash 1", :f_3 => "file set hash 3"}
      before {
        allow(subject).to receive(:update_add_files).and_return true
        allow(subject).to receive(:attr_prefix).with(work).and_return " prefix work"
      }

      context "when continue_new_content_service returns false" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return false
        }
        context "when the work parameter has file_sets" do
          it "returns updates parameter" do
            expect(subject).to receive(:continue_new_content_service)
            expect(subject).not_to receive(:update_file_set)

            expect(subject.send(:update_file_sets_from_file_set_ids, updates: "updates", work_hash: work_hash, work: work)).to eq "updates"
          end
        end

        context "when the work_hash parameter has file_set_ids" do
          it "returns updates parameter" do
            expect(subject).to receive(:continue_new_content_service)
            expect(subject).not_to receive(:update_file_set)

            expect(subject.send(:update_file_sets_from_file_set_ids, updates: "updates", work_hash: work_hash, work: OpenStruct.new(file_sets: [])))
                          .to eq "updates"
          end
        end
      end

      context "when continue_new_content_service returns true" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return true
          allow(subject).to receive(:update_file_set).with(updates: "updates", file_set: work1, file_set_hash: "file set hash 1")

          allow(subject).to receive(:add_file_sets_file_size).with( file_set_hash: "file set hash 3" ).and_return "file size"
          allow(subject).to receive(:update_build_mode).and_return "build mode"
          allow(subject).to receive(:build_file_set_from_hash).with( id: "3",
                                                                     file_set_hash: "file set hash 3",
                                                                     parent: work,
                                                                     file_set_of: 1,
                                                                     file_set_count: 1,
                                                                     file_size: "file size",
                                                                     build_mode: "build mode" ).and_return "file set 3"
          allow(subject).to receive(:add_file_set_to_work).with( work: work, file_set: "file set 3" )
          allow(subject).to receive(:update_delete_files).and_return true
        }
        it "updates file sets, add files, removes extra files, and returns updates parameter with messages appended" do
          expect(subject).to receive(:continue_new_content_service).and_return true
          expect(subject).to receive(:update_file_set).with(updates: "updates", file_set: work1, file_set_hash: "file set hash 1")
          expect(subject).to receive(:attr_prefix).with(work)
          expect(subject).to receive(:update_add_files)
          expect(subject).to receive(:build_file_set_from_hash).with( id: "3",
                                                                      file_set_hash: "file set hash 3",
                                                                      parent: work,
                                                                      file_set_of: 1,
                                                                      file_set_count: 1,
                                                                      file_size: "file size",
                                                                      build_mode: "build mode" )
          expect(subject.send(:update_file_sets_from_file_set_ids, updates: "updates", work_hash: work_hash, work: work))
            .to eq "updates prefix work: is missing file 3 prefix work: file added 3 prefix work: has extra file 2 prefix work: file deleted 2"
        end
      end
    end

    context "when update_add_files returns false" do
      work_param = OpenStruct.new(file_sets: [])
      work_hash_param = {:file_set_ids => ["a"], :f_a => "file set hash a"}
      before {
        allow(subject).to receive(:update_add_files).and_return false
        allow(subject).to receive(:continue_new_content_service).and_return true
        allow(subject).to receive(:attr_prefix).with(work_param).and_return " prefix work"
      }
      it "updates file sets and returns updates parameter with messages appended" do
        expect(subject).to receive(:continue_new_content_service).and_return true
        expect(subject).to receive(:update_add_files)
        expect(subject).not_to receive(:update_file_set)
        expect(subject).to receive(:attr_prefix).with(work_param)

        expect(subject.send(:update_file_sets_from_file_set_ids, updates: "updates", work_hash: work_hash_param, work: work_param))
          .to eq "updates prefix work: is missing file a"
      end
    end
  end


  describe "#update_user" do
    context "when user_email parameter is nil" do
      user = User.new
      before {
        allow(User).to receive(:attribute_names).and_return %w[ current_sign_in_at
                                                                current_sign_in_ip
                                                                reset_password_token
                                                                reset_password_sent_at
                                                                id
                                                                email
                                                                guest
                                                              ]
        allow(subject).to receive(:log_msg).with( "update_user user_at_factory_bot" )
      }
      it "updates appropriate attributes, logs and saves" do
        user.email = "user_at_factory_bot"
        expect(subject).to receive(:log_msg).with( "update_user user_at_factory_bot" )
        expect(user).to receive(:save).with(validate: false)
        subject.send(:update_user, user: user, user_hash: {:guest => true})
        expect(user.guest).to eq true
      end
    end

    context "when user_email parameter is NOT nil" do

      context "when continue_new_content_service returns false and updates parameter is nil" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return false
        }
        it "returns empty array" do
          expect(subject.send(:update_user, user: nil, user_hash: nil, user_email: "user email")).to be_empty
        end
      end

      context "when continue_new_content_service returns true" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return true
          allow(User).to receive(:attribute_names).and_return ["age", "date of birth"]
          allow(subject).to receive(:update_user_attr).with("updates", "user", "user hash", "user email", attr_name: "age")
          allow(subject).to receive(:update_user_attr).with("updates", "user", "user hash", "user email", attr_name: "date of birth")
        }
        it "updates user attributes and returns updates parameter" do
          expect(User).to receive(:attribute_names).and_return ["age", "date of birth"]
          expect(subject).to receive(:update_user_attr).with("updates", "user", "user hash", "user email", attr_name: "age")
          expect(subject).to receive(:update_user_attr).with("updates", "user", "user hash", "user email", attr_name: "date of birth")

          expect(subject.send(:update_user, updates: "updates", user: "user", user_hash: "user hash", user_email: "user email")).to eq "updates"
        end
      end

      after {
        expect(subject).to have_received(:continue_new_content_service)
      }
    end
  end


  describe "#update_value_value" do
    before {
      allow(subject).to receive(:attr_prefix).with("cc_or_fs").and_return " prefix"
    }

    context "when update_attr returns false" do
      before {
        allow(subject).to receive(:update_attr?).with("attr_name").and_return false
      }
      it "returns updates parameter" do
        expect(subject.send(:update_value_value, "updates", "cc_or_fs", attr_name: "attr_name", current_value: "current value")).to eq "updates"
      end
    end

    context "when update_attr returns true" do
      before {
        allow(subject).to receive(:update_attr?).with("attr_name").and_return true
      }

      context "when update_attr_if_blank? returns false" do
        before {
          allow(subject).to receive(:update_attr_if_blank?).with(value: "valuable").and_return false
        }
        it "returns updates parameter" do
          expect(subject).to receive(:update_attr_if_blank?).with(value: "valuable")
          expect(subject.send(:update_value_value, "updates", "cc_or_fs", attr_name: "attr_name", current_value: "current value", value: "valuable"))
            .to eq "updates"
        end
      end

      context "when update_attr_if_blank? returns true" do
        before {
          allow(subject).to receive(:update_attr_if_blank?).with(value: "highly valued").and_return true
        }
        context "when current_value parameter is equal to value parameter" do
          it "returns updates parameter" do
            expect(subject.send(:update_value_value, "updates", "cc_or_fs", attr_name: "attr_name", current_value: "highly valued", value: "highly valued"))
              .to eq "updates"
          end
        end

        context "when current_value parameter is NOT equal to value parameter" do
          it "returns updates parameter with message appended" do
            expect(subject).to receive(:attr_prefix).with("cc_or_fs")
            expect(subject.send(:update_value_value, "updates", "cc_or_fs", attr_name: "attr_name", current_value: "current value", value: "highly valued"))
              .to eq "updates prefix: attr_name 'current value' vs. 'highly valued'"
          end
        end

        after {
          expect(subject).to have_received(:update_attr_if_blank?).with(value: "highly valued")
        }
      end

      context "when update_attr_if_blank? raises an error" do
        before {
          allow(subject).to receive(:update_attr_if_blank?).with(value: "value time").and_raise(Exception, "error message")
        }
        it "returns updates parameter with error message appended" do
          expect(subject).to receive(:update_attr_if_blank?).with(value: "value time")
          expect(subject).to receive(:attr_prefix).with("cc_or_fs")
          result = subject.send(:update_value_value, "updates", "cc_or_fs", attr_name: "attr_name", current_value: "current value", value: "value time")
          expect(result.start_with? "updates prefix: attr_name -- Exception: Exception: error message at ").to eq true
        end
      end
    end

    after {
      expect(subject).to have_received(:update_attr?).with("attr_name")
    }
  end


  describe "#update_users" do
    context "when the users function returns no results" do
      before {
        allow(subject).to receive(:users).and_return nil
      }
      it "returns nil" do
        expect(subject).to receive(:users).once
        expect(Benchmark).not_to receive(:measure)

        expect(subject.send(:update_users)).to be_nil
      end
    end

    context "when the users function returns results" do
      user_r = MockCreatedUser.new
      user_d = MockCreatedUser.new
      user_hash_r = {:user_emails => ["r_at_org"], :user_r_at_org => "user r"}
      user_hash_e = {:user_emails => ["e_at_org"], :user_e_at_org => "user e"}
      user_hash_d = {:user_emails => ["d_at_org"], :user_d_at_org => "user d"}

      before {
        allow(subject).to receive(:users).and_return [ {:user_emails => nil}, user_hash_r, user_hash_e, user_hash_d ]
        allow(Benchmark).to receive(:measure).and_return "measurement"
        allow(subject).to receive(:find_user).with(user_hash: "user r").and_return user_r
        allow(subject).to receive(:find_user).with(user_hash: "user e").and_return nil
        allow(subject).to receive(:find_user).with(user_hash: "user d").and_return user_d
        allow(subject).to receive(:update_user).with(user_hash: user_hash_r, user: user_r, user_email: "r_at_org").and_return ["update1", "update2"]
        allow(subject).to receive(:update_user).with(user_hash: user_hash_d, user: user_d, user_email: "d_at_org").and_return nil
      }
      it "calls Benchmark.measure, updates users, and returns result" do
        expect(subject).to receive(:users)
        expect(Benchmark).to receive(:measure)
        expect(subject.send(:update_users)).to eq "measurement"
      end
    end

    skip "add a test for functions inside of Benchmark.measure code block"
  end


  describe "#update_user_attr" do
    context "when calling update_user_attr? with the attr_name parameter returns false" do
      before {
        allow(subject).to receive(:update_user_attr?).with(:attr_name).and_return false
      }
      it "returns updates parameter" do
        expect(subject.send(:update_user_attr, "updates", "user", "user_hash", "user_email", attr_name: "attr_name")).to eq "updates"
      end
    end

    context "when calling update_user_attr? with the attr_name parameter returns true" do
      before {
        allow(subject).to receive(:update_user_attr?).with(:attr_name).and_return true
        allow(subject).to receive(:value_from_attr).with("user_hash", attr_name: :attr_name, attr_name_hash: nil, multi: false).and_return "value"
      }

      context "when update_user_attr_if_blank? returns false" do
        before {
          allow(subject).to receive(:attr_current_time).with("attr_current", "value").and_return ["attr_current", "value"]
          allow(subject).to receive(:update_user_attr_if_blank?).with(value: "value").and_return false
        }
        it "returns the updates parameter" do
          expect(subject).to receive(:attr_current_time).with("attr_current", "value")
          expect(subject).to receive(:update_user_attr_if_blank?).with(value: "value")
          expect(subject.send(:update_user_attr, "updates", {:attr_name => "attr_current"}, "user_hash", "user_email", attr_name: :attr_name))
            .to eq "updates"
        end
      end

      context "when update_user_attr_if_blank? returns true" do
        context "when attr_current is equal to value (after being returned by the attr_current_time function)" do
          before {
            allow(subject).to receive(:attr_current_time).with("attr_current", "value").and_return ["attr_current", "attr_current"]
            allow(subject).to receive(:update_user_attr_if_blank?).with(value: "attr_current").and_return true
          }
          it "returns the updates parameter" do
            expect(subject).to receive(:update_user_attr_if_blank?).with(value: "attr_current")
            expect(subject.send(:update_user_attr, "updates", {:attr_name => "attr_current"}, "user_hash", "user_email", attr_name: "attr_name"))
            .to eq "updates"
          end
        end

        context "when attr_current is NOT equal to value (after being returned by the attr_current_time function)" do
          before {
            allow(subject).to receive(:attr_current_time).with("attr_current", "value").and_return ["attr_current", "value"]
            allow(subject).to receive(:update_user_attr_if_blank?).with(value: "value").and_return true
          }
          it "returns the updates parameter with message appended" do
            expect(subject).to receive(:update_user_attr_if_blank?).with(value: "value")
            expect(subject.send(:update_user_attr, "updates ", {:attr_name => "attr_current"}, "user_hash", "user_email", attr_name: "attr_name"))
              .to eq "updates user_email: attr_name 'attr_current' updated to 'value'"
          end
        end

        after {
          expect(subject).to have_received(:attr_current_time).with("attr_current", "value")
        }
      end

      context "when update_user_attr_if_blank? raises an exception" do
        before {
          allow(subject).to receive(:attr_current_time).with("attr_current", "value").and_return ["attr_current", "value"]
          allow(subject).to receive(:update_user_attr_if_blank?).with(value: "value").and_raise(Exception, "error updating user")
        }
        it "returns the updates parameter with error message appended" do
          expect(subject).to receive(:attr_current_time).with("attr_current", "value")
          expect(subject).to receive(:update_user_attr_if_blank?).with(value: "value")
          result = subject.send(:update_user_attr, "updates ", {:attr_name => "attr_current"}, "user_hash", "user_email", attr_name: "attr_name")
          expect(result.start_with? "updates user_email: attr_name -- Exception: Exception: error updating user at ").to eq true
        end
      end
    end

    after {
      expect(subject).to have_received(:update_user_attr?)
    }
  end


  describe "#update_user_attr?" do
    context "when update_user_attrs_skip includes parameter" do
      before {
        allow(subject).to receive(:update_user_attrs_skip).and_return ["dark", "semisweet", "ruby"]
      }
      it "returns false" do
        expect(subject.send(:update_user_attr?, "dark")).to eq false
      end
    end

    context "when update_user_attrs_skip does NOT include parameter" do
      before {
        allow(subject).to receive(:update_user_attrs_skip).and_return ["white", "milk", "baking"]
      }
      it "returns true" do
        expect(subject.send(:update_user_attr?, "dark")).to eq true
      end
    end

    after {
      expect(subject).to have_received(:update_user_attrs_skip)
    }
  end



  describe "#update_user_attr_if_blank?" do
    value_params = [{:param => "", :expected_result => false}, {:param => nil, :expected_result => false}, {:param => "pistachio", :expected_result => true}]

    value_params.each do |param_hash|
      context "when value parameter is #{param_hash[:param]} #{(param_hash[:param].blank? ? '(blank)' : '')}" do
        it "returns #{param_hash[:expected_result]}" do
          expect(subject.send(:update_user_attr_if_blank?, value: param_hash[:param])).to eq param_hash[:expected_result]
        end
      end
    end
  end


  describe "#update_visibility" do
    context "when calling visibility_curation_concern evaluates to true" do
      before {
        allow(subject).to receive(:visibility_curation_concern).with("public").and_return true
      }
      it "returns curation_concern parameter with visibility field set to visibility parameter" do
        expect(subject).to receive(:visibility_curation_concern).with("public")

        concern = OpenStruct.new(visibility: "private")
        expect(subject.send(:update_visibility, curation_concern: concern, visibility: "public")).to eq "public"

        expect(concern.visibility).to eq "public"
      end
    end

    context "when calling visibility_curation_concern evaluates to false" do
      before {
        allow(subject).to receive(:visibility_curation_concern).with("public").and_return false
      }
      it "returns nil" do
        expect(subject).to receive(:visibility_curation_concern).with("public")
        expect(subject.send(:update_visibility, curation_concern: nil, visibility: "public")).to be_nil
      end
    end
  end


  describe "#update_work" do
    context "when continue_new_content_service returns false" do
      before {
        allow(subject).to receive(:continue_new_content_service).and_return false
      }
      it 'returns value of updates parameter' do
        expect(subject.send(:update_work, updates: "updates", work_hash: "work hash", work: "work")).to eq "updates"
      end
    end

    context "when continue_new_content_service returns true" do
      work_hash = {:resource_type => "typical resource", :methodology => "method"}
      work = MockVisibilityWork.new(1)
      work.visibility ="visible updates"
      before {
        allow(subject).to receive(:continue_new_content_service).and_return(true)

        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :authoremail, multi: false )
        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :contributor )
        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :creator )
        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :creator_ordered, multi: false )
        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :curation_notes_admin )
        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :curation_notes_admin_ordered, multi: false )
        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :curation_notes_user )
        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :curation_notes_user_ordered, multi: false )

        allow(subject).to receive(:build_date_coverage).with(hash: work_hash ).and_return "date coverage"
        allow(subject).to receive(:build_date).with(hash: work_hash, key: :date_created ).and_return "date created"
        allow(subject).to receive(:build_date).with(hash: work_hash, key: :date_modified ).and_return "date modified"
        allow(subject).to receive(:build_date).with(hash: work_hash, key: :date_published ).and_return "date published"
        allow(subject).to receive(:build_date).with(hash: work_hash, key: :date_uploaded ).and_return "date uploaded"

        allow(subject).to receive(:update_attr_value).with( [], work, attr_name: :date_coverage, value: "date coverage" )
        allow(subject).to receive(:update_attr_value).with( [], work, attr_name: :date_created, value: "date created" )
        allow(subject).to receive(:update_attr_value).with( [], work, attr_name: :date_modified, value: "date modified" )
        allow(subject).to receive(:update_attr_value).with( [], work, attr_name: :date_published, value: "date published" )
        allow(subject).to receive(:update_attr_value).with( [], work, attr_name: :date_uploaded, value: "date uploaded" )

        allow(subject).to receive(:build_depositor).with( hash: work_hash ).and_return "depositor"
        allow(subject).to receive(:update_attr_value).with( [], work, attr_name: :depositor, value: "depositor" )
        allow(subject).to receive(:update_attr_value).with( [], work, attr_name: :owner, value: "depositor" )

        allow(subject).to receive(:default_description).with(work_hash[:description]).and_return "description"
        allow(subject).to receive(:update_attr_value).with( [], work, attr_name: :description, value: "description" )
        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :description_ordered, multi: false )
        allow(subject).to receive(:update_edit_users).with( [], work, work_hash )

        allow(subject).to receive(:build_fundedby).with(hash: work_hash ).and_return "funded by"
        allow(subject).to receive(:update_attr_value).with( [], work, attr_name: :fundedby, value: "funded by" )
        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :fundedby_other )

        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :grantnumber, multi: false )
        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :keyword )
        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :keyword_ordered, multi: false )
        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :language )
        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :language_ordered, multi: false )

        allow(subject).to receive(:default_methodology).with(work_hash[:methodology]).and_return "methodology"
        allow(subject).to receive(:update_attr_value).with([], work, attr_name: :methodology, value: "methodology" )

        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :prior_identifier )
        allow(subject).to receive(:build_referenced_by).with(hash: work_hash).and_return "ref by"
        allow(subject).to receive(:update_attr_value).with( [], work, attr_name: :referenced_by, value: "ref by" )
        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :referenced_by_ordered, multi: false )

        allow(subject).to receive(:default_work_resource_type).with(resource_type: work_hash[:resource_type]).and_return 'resource type'
        allow(subject).to receive(:update_attr_value).with( [], work, attr_name: :resource_type, value: 'resource type' )

        allow(subject).to receive(:build_rights_license).with( hash: work_hash ).and_return "rights license"
        allow(subject).to receive(:update_attr_value).with( [], work, attr_name: :rights_license, value: "rights license" )
        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :rights_license_other, multi: false )

        allow(subject).to receive(:build_subject_discipline).with(hash: work_hash ).and_return "subject discipline"
        allow(subject).to receive(:update_attr_value).with( [], work, attr_name: :subject_discipline, value: "subject discipline" )

        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :title )
        allow(subject).to receive(:update_attr).with( [], work, work_hash, attr_name: :title_ordered, multi: false )

        allow(subject).to receive(:visibility_from_hash).with(hash: work_hash ).and_return 'visibility'
        allow(subject).to receive(:update_value_value).with( [], work, attr_name: :visibility, current_value: "visible updates",
                                                             value: "visibility" )
      }

      context "when update_file_sets returns a value" do
        before {
          allow(subject).to receive(:update_file_sets).with( updates: [], work_hash: work_hash, work: work ).and_return ["updated"]
          allow(subject).to receive(:update_attr_doi).with( ["updated"], work, work_hash )
        }
        it 'saves the work parameter and returns concatenated updates' do
          expect(work).to receive(:save!).once
          expect(subject.send(:update_work, updates: ["updates"], work_hash: work_hash, work: work)).to eq ["updates", "updated"]
        end
      end

      context "when update_file_sets does NOT return a value" do
        before {
          allow(subject).to receive(:update_file_sets).with( updates: [], work_hash: work_hash, work: work ).and_return []
          allow(subject).to receive(:update_attr_doi).with( [], work, work_hash )
        }
        it 'saves the work parameter and returns update_attr_doi updates' do
          expect(work).not_to receive(:save!)
          expect(subject.send(:update_work, updates: ["updates"], work_hash: work_hash, work: work)).to eq ["updates"]
        end
      end

      after {
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :authoremail, multi: false )
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :contributor )
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :creator )
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :creator_ordered, multi: false )
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :curation_notes_admin )
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :curation_notes_admin_ordered, multi: false )
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :curation_notes_user )
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :curation_notes_user_ordered, multi: false )

        expect(subject).to have_received(:build_date_coverage).with(hash: work_hash )
        expect(subject).to have_received(:update_attr_value).with( [], work, attr_name: :date_coverage, value: "date coverage" )
        expect(subject).to have_received(:update_attr_value).with( [], work, attr_name: :date_created, value: "date created" )
        expect(subject).to have_received(:update_attr_value).with( [], work, attr_name: :date_modified, value: "date modified" )
        expect(subject).to have_received(:update_attr_value).with( [], work, attr_name: :date_published, value: "date published" )
        expect(subject).to have_received(:update_attr_value).with( [], work, attr_name: :date_uploaded, value: "date uploaded" )

        expect(subject).to have_received(:update_attr_value).with( [], work, attr_name: :depositor, value: "depositor" )
        expect(subject).to have_received(:update_attr_value).with( [], work, attr_name: :owner, value: "depositor" )

        expect(subject).to have_received(:update_attr_value).with( [], work, attr_name: :description, value: "description" )
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :description_ordered, multi: false )
        expect(subject).to have_received(:update_edit_users).with( [], work, work_hash )

        expect(subject).to have_received(:update_attr_value).with( [], work, attr_name: :fundedby, value: "funded by" )
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :fundedby_other )

        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :grantnumber, multi: false )
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :keyword )
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :keyword_ordered, multi: false )
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :language )
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :language_ordered, multi: false )

        expect(subject).to have_received(:update_attr_value).with([], work, attr_name: :methodology, value: "methodology" )

        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :prior_identifier )
        expect(subject).to have_received(:update_attr_value).with( [], work, attr_name: :referenced_by, value: "ref by" )
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :referenced_by_ordered, multi: false )

        expect(subject).to have_received(:update_attr_value).with( [], work, attr_name: :resource_type, value: 'resource type' )

        expect(subject).to have_received(:update_attr_value).with( [], work, attr_name: :rights_license, value: "rights license" )
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :rights_license_other, multi: false )

        expect(subject).to have_received(:update_attr_value).with( [], work, attr_name: :subject_discipline, value: "subject discipline" )

        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :title )
        expect(subject).to have_received(:update_attr).with( [], work, work_hash, attr_name: :title_ordered, multi: false )

        expect(subject).to have_received(:update_value_value).with( [], work, attr_name: :visibility, current_value: "visible updates",
                                                             value: "visibility" )
      }
    end

    after {
      expect(subject).to have_received(:continue_new_content_service).once
    }
  end


  describe "#update_works" do
    context "when works returns nil" do
      before {
        allow(subject).to receive(:works).and_return nil
      }
      it "returns nil" do
        expect(subject).to receive(:works).once
        expect(subject).not_to receive(:continue_new_content_service)
        expect(subject.send(:update_works)).to be_nil
      end
    end

    context "when works function returns results" do
      before {
        allow(subject).to receive(:works).and_return [nil, "work1", "work2", "work3"]
      }

      context "when continue_new_content_service returns false" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return false
        }
        it "returns results of works function" do
          expect(Benchmark).not_to receive(:measure)

          expect(subject.send(:update_works)).to eq [nil, "work1", "work2", "work3"]
        end
      end

      context "when continue_new_content_service returns true" do
        before {
          allow(subject).to receive(:continue_new_content_service).and_return true
          measured = MockMeasurement.new
          allow(Benchmark).to receive(:measure).and_return measured
          allow(subject).to receive(:find_work).with(work_hash: "work1").and_return [nil, "id1"]
          allow(subject).to receive(:find_work).with(work_hash: "work2").and_return ["work two", "id2"]
          allow(subject).to receive(:find_work).with(work_hash: "work3").and_return ["work three", "id3"]
          allow(subject).to receive(:update_work).with(work_hash: "work2", work: "work two").and_return nil
          allow(subject).to receive(:update_work).with(work_hash: "work3", work: "work three").and_return ["updates3", "updates3.1"]
          allow(subject).to receive(:attr_prefix).with("work three").and_return "prefix"

          allow(subject).to receive(:add_work_to_parent_ids).with( work_hash: "work2", work: "work two" )
          allow(subject).to receive(:add_work_to_parent_ids).with( work_hash: "work3", work: "work three" )
          allow(subject).to receive(:doi_mint).with( curation_concern: "work two" )
          allow(subject).to receive(:doi_mint).with( curation_concern: "work three" )
          allow(subject).to receive(:add_measurement).with measured
        }
        it "calls Benchmark.measure and returns results of works function" do
          expect(Benchmark).to receive(:measure)
          expect(subject.send(:update_works)).to eq [nil, "work1", "work2", "work3"]
        end

        skip "add test for Benchmark.measure do"

        after {
          expect(subject).to have_received(:works).twice
          expect(subject).to have_received(:continue_new_content_service).thrice
        }
      end
    end
  end


  describe "#upload_file_to_file_set" do
    context "when no Exception occurs" do
      before {
        allow(Hydra::Works::UploadFileToFileSet).to receive(:call).with( "file set", "a file" )
      }
      it "returns true" do
        expect(subject.send(:upload_file_to_file_set, "file set", "a file")).to eq true
      end
    end

    context "when Ldp::Conflict Exception occurs" do
      before {
        allow(Hydra::Works::UploadFileToFileSet).to receive(:call).with( "file set", "a file" ).and_raise(Ldp::Conflict)
      }
      it "returns false" do
        expect(subject.send(:upload_file_to_file_set, "file set", "a file")).to eq false
      end
    end

    after {
      expect(Hydra::Works::UploadFileToFileSet).to have_received(:call).with( "file set", "a file" )
    }
  end


  describe "#users" do
    context "when @users has a value" do
      before {
        subject.instance_variable_set(:@users, "test users")
      }
      it "returns @users" do
        expect(subject).not_to receive(:users_from_hash)
        expect(subject.send(:users)).to eq "test users"
      end
    end

    context "when @users is nil" do
      before {
        subject.instance_variable_set(:@cfg_hash, :user => "beta")
        allow(subject).to receive(:users_from_hash).with(hash: "beta").and_return "hash users"
      }
      it "sets @users to users_from_hash results" do
        expect(subject.send(:users)).to eq "hash users"

        expect(subject.instance_variable_get(:@users)).to eq "hash users"
      end
    end
  end


  describe "#user_create_users" do
    context "when user_create evaluates to positive" do
      before {
        allow(subject).to receive(:user_create).and_return true
      }

      context "when emails parameter is blank" do
        it "returns nil" do
          expect(User).not_to receive(:find_by_user_key)
          expect(subject.send(:user_create_users, emails: [])).to be_nil
        end
      end

      context "when emails parameter has a value" do
        created_user = MockCreatedUser.new
        before {
          allow(User).to receive(:find_by_user_key).with("email1").and_return "user1"
          allow(User).to receive(:find_by_user_key).with("email2").and_return nil

          allow(User).to receive(:new).with( email: "email2", password: "pword1234" ).and_return created_user
          allow(subject).to receive(:log_msg).with( "Creating user: email2" )
        }
        it "creates and logs new user(s)" do
          expect(User).to receive(:find_by_user_key).with("email1")
          expect(User).to receive(:find_by_user_key).with("email2")
          expect(User).to receive(:new).with( email: "email2", password: "pword1234" )
          expect(subject).to receive(:log_msg).with( "Creating user: email2" )
          subject.send(:user_create_users, emails:["email1", "email2"], password: "pword1234")
        end

        skip "add test for created_user block"
      end
    end

    context "when user_create evaluates to negative" do
      before {
        allow(subject).to receive(:user_create).and_return false
      }
      it "returns nil" do
        expect(User).not_to receive(:find_by_user_key)
        expect(subject.send(:user_create_users, emails:["example_at_org_dot_com"], )).to be_nil
      end
    end

    after {
      expect(subject).to have_received(:user_create)
    }
  end


  describe "#users_from_hash" do
    it "returns value of :users key from hash parameter put into an array" do
      expect(subject.send(:users_from_hash, hash: {:users => "Betty, George"})).to eq ["Betty, George"]
    end
  end


  describe "#user_key" do
    before {
      subject.instance_variable_set(:@cfg_hash, {:user => {:email => "example_at_org_dotcom"}})
    }
    it "returns user email value of @cfg_hash" do
      expect(subject.send(:user_key)).to eq "example_at_org_dotcom"
    end
  end


  describe "#validate_config" do    # NOTE:  error message is contradictory
    context "when @cfg_hash[:user].keys has keys in addition to :collections, :works" do
      before {
        subject.instance_variable_set(:@cfg_hash, { :user => {:collections => "collected", :works => "workable", :email => "emails"} })
      }
      it "returns nil" do
        expect(subject.send(:validate_config)).to be_nil
      end
    end

    context "when @cfg_hash[:user].keys has fewer keys than :collections, :works" do
      before {
        subject.instance_variable_set(:@cfg_hash, { :user => {:collections => "collected"} })
      }
      it "raises TaskConfigError" do
        subject.send(:validate_config)

        rescue Deepblue::NewContentService::TaskConfigError
          # raises Exception
      end
    end

    context "when @cfg_hash[:user].keys has the same keys as :collections, :works" do
      before {
        subject.instance_variable_set(:@cfg_hash, { :user => {:collections => "collected", :works => "workable"} })
      }
      it "raises TaskConfigError" do
        subject.send(:validate_config)

        rescue Deepblue::NewContentService::TaskConfigError => e
          expect(e.message).to eq "user can only contain collections and works"
          # raises Exception
      end
    end

    context "when @cfg_hash does NOT have a key for :user" do
      before {
        subject.instance_variable_set(:@cfg_hash, {:user_email => "nope"})
      }
      it "raises TaskConfigError" do
        subject.send(:validate_config)

        rescue Deepblue::NewContentService::TaskConfigError => e
          expect(e.message).to eq "Top level keys needs to contain 'user'"
          # raises Exception
      end
    end
  end


  describe "#valid_restricted_vocab" do
    context "when vocab includes value" do
      it "returns value" do
        expect(subject.send(:valid_restricted_vocab, "off-white", var: "color", vocab: ["off-white", "beige"])).to eq "off-white"
      end
    end

    context "when vocab does not include value" do
      it "raises RestrictedVocabularyError" do
        expect(subject.send(:valid_restricted_vocab, "off-white", var: "color", vocab: ["eggshell", "ecru"]))
          .to raise_error(Deepblue::NewContentService::RestrictedVocabularyError,
          "Illegal value 'off-white' color, must be one of [\"eggshell\", \"ecru\"]")
        rescue Deepblue::NewContentService::RestrictedVocabularyError
          # raises Exception
      end
    end
  end


  describe "#visibility" do
    context "when @visibility has a value" do
      before {
        subject.instance_variable_set(:@visibility, "private")
      }
      it "return @visibility" do
        expect(subject).not_to receive(:visibility_curation_concern)

        expect(subject.send(:visibility)).to eq "private"
      end
    end

    context "when @visibility is nil" do
      before {
        subject.instance_variable_set(:@cfg_hash, :user => {:visibility => "privacy"})
        allow(subject).to receive(:visibility_curation_concern).with("privacy").and_return "protected"
      }
      it "calls visibility_curation_concern" do
        expect(subject).to receive(:visibility_curation_concern).with("privacy")
        expect(subject.send(:visibility)).to eq "protected"
        expect(subject.instance_variable_get(:@visibility)).to eq "protected"
      end
    end
  end


  describe "#visibility_curation_concern" do
    before {
      allow(subject).to receive(:valid_restricted_vocab).with("vis", var: :visibility, vocab: %w[open restricted],
                                                              error_class: Deepblue::NewContentService::VisibilityError).and_return "visual"
    }
    it "calls valid_restricted_vocab and returns result" do
      expect(subject).to receive(:valid_restricted_vocab).with("vis", var: :visibility, vocab: %w[open restricted],
                                                               error_class: Deepblue::NewContentService::VisibilityError)
      expect(subject.send(:visibility_curation_concern, "vis")).to eq "visual"
    end
  end


  describe "#visibiity_from_hash" do
    before {
      allow(subject).to receive(:visibility_curation_concern).with("public").and_return "open"
    }

    context "when hash parameter has :visibility key" do
      it "calls visibility_curation_concern" do
        expect(subject).to receive(:visibility_curation_concern).with("public")
        expect(subject).not_to receive(:visibility)

        expect(subject.send(:visibility_from_hash, hash: {:visibility => "public"})).to eq "open"
      end
    end

    context "when hash parameter does NOT have a :visibility key" do
      before {
        allow(subject).to receive(:visibility).and_return "visibility"
      }
      it "returns result of visibility function" do
        expect(subject).to receive(:visibility)
        expect(subject).not_to receive(:visibility_curation_concern).with("public")

        expect(subject.send(:visibility_from_hash, hash: {:visibility => nil})).to eq "visibility"
      end
    end
  end


  describe "#work_hash_from_id" do
    it "returns value of work_id key from parent_hash (parameters)" do
      expect(subject.send(:work_hash_from_id, parent_hash: {:works_123 => 'hickory'}, work_id: 123)).to eq "hickory"
    end
  end


  describe "#works" do
    context "when @works variable has a value" do
      before {
        subject.instance_variable_set(:@works, ["work 1", "work 2"])
      }
      it "returns @works" do
        expect(subject).not_to receive(:works_from_hash)

        expect(subject.send(:works)).to eq ["work 1", "work 2"]
      end
    end

    context "when @works variable is nil" do
      before {
        subject.instance_variable_set(:@cfg_hash, :user => "user")
        allow(subject).to receive(:works_from_hash).with(hash: "user").and_return "works from hash"
      }
      it "calls works_from_hash" do
        expect(subject).to receive(:works_from_hash).with(hash: "user")
        expect(subject.send(:works)).to eq "works from hash"
        expect(subject.instance_variable_get(:@works)).to eq "works from hash"
      end
    end
  end


  describe "#works_from_hash" do
    it "returns the value of the works key from the hash parameter in an array" do
      expect(subject.send(:works_from_hash, hash: {:works => "in progress"})).to eq ["in progress"]
    end
  end


end
