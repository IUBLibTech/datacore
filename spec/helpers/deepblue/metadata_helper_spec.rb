class MetadataHelperMock
  include ::Deepblue::MetadataHelper
end

class CurationConcerningMock

  def initialize(depositor, visibility, id)
    @depositor = depositor
    @visibility = visibility
    @id = id
  end

  def depositor
    @depositor
  end

  def visibility
    @visibility
  end

  def id
    @id
  end
end

class CurationConcernProvenanceMigrateMock

  def provenance_migrate(current_user:, parent_id:, migrate_direction:)
  end
end


class MockOutObject

  def puts(message)
  end
end

class MockOutPrint

  def puts(message = "\n")
  end

  def print(message)
  end
end

class MockTargetFile

  def write(message)
  end
end





RSpec.describe Deepblue::MetadataHelper, type: :helper do

  ignore_list = %w[ access_control_id
                    collection_type_gid
                    file_size
                    head
                    part_of tail
                    thumbnail_id ]

  always_cc = %w[ admin_set_id
                  authoremail
                  creator
                  creator_ordered
                  curation_notes_admin
                  curation_notes_admin_ordered
                  curation_notes_user
                  curation_notes_user_ordered
                  date_coverage
                  date_created
                  date_modified
                  date_published
                  date_uploaded
                  depositor
                  description
                  description_ordered
                  doi
                  fundedby
                  fundedby_other
                  grantnumber
                  isReferencedBy
                  isReferencedBy_ordered
                  keyword
                  keyword_ordered
                  language
                  language_ordered
                  methodology
                  owner
                  prior_identifier
                  referenced_by
                  referenced_by_ordered
                  rights_license_other
                  source
                  subject_discipline
                  title
                  title_ordered
                  tombstone
                  access_deepblue
                  access_deepblue_ordered
                  total_file_size ]

  always_file_set = %w[ creator
                        curation_notes_admin
                        curation_notes_admin_ordered
                        curation_notes_user
                        curation_notes_user_ordered
                        date_created
                        date_modified
                        date_uploaded
                        depositor
                        label
                        owner
                        prior_identifier
                        title
                        virus_scan_service
                        virus_scan_status
                        virus_scan_status_date ]

  user_ignore = %w[ current_sign_in_at
                    current_sign_in_ip
                    reset_password_token
                    reset_password_sent_at ]

  subject { MetadataHelperMock.new }

  pending "constants"
  pending "class variable functions"

  pending "self.attribute_names_always_include_cc"
  pending "self.attribute_names_collection"
  pending "self.attribute_names_file_set"
  pending "self.attribute_names_user"


  describe "#self.attribute_names_work" do
    context "when source parameter is 'DBDv2'" do
      before {
        allow(DataSet).to receive(:attribute_names).and_return ["cantaloupe", "apple", "berry"]
      }
      it "returns DataSet attribute names sorted" do
        expect(Deepblue::MetadataHelper.attribute_names_work(source: "DBDv2")).to eq ["apple", "berry", "cantaloupe"]
      end
    end

    context "when source parameter is NOT 'DBDv2'" do
      before {
        allow(GenericWork).to receive(:attribute_names).and_return ["antelope", "cheetah", "buffalo"]
      }
      it "returns GenericWork attribute names sorted" do
        expect(Deepblue::MetadataHelper.attribute_names_work(source: "DBDv1")).to eq ["antelope", "buffalo", "cheetah"]
      end
    end
  end


  describe "#self.init_attribute_names_always_include_cc" do
    it "returns hash" do

      cc_attributes = {
        "admin_set_id"                 => true,
        "authoremail"                  => true,
        "creator"                      => true,
        "creator_ordered"              => true,
        "curation_notes_admin"         => true,
        "curation_notes_admin_ordered" => true,
        "curation_notes_user"          => true,
        "curation_notes_user_ordered"  => true,
        "date_coverage"                => true,
        "date_created"                 => true,
        "date_modified"                => true,
        "date_published"               => true,
        "date_uploaded"                => true,
        "depositor"                    => true,
        "description"                  => true,
        "description_ordered"          => true,
        "doi"                          => true,
        "fundedby"                     => true,
        "fundedby_other"               => true,
        "grantnumber"                  => true,
        "isReferencedBy"               => true,
        "isReferencedBy_ordered"       => true,
        "keyword"                      => true,
        "keyword_ordered"              => true,
        "language"                     => true,
        "language_ordered"             => true,
        "methodology"                  => true,
        "owner"                        => true,
        "prior_identifier"             => true,
        "referenced_by"                => true,
        "referenced_by_ordered"        => true,
        "rights_license_other"         => true,
        "source"                       => true,
        "subject_discipline"           => true,
        "title"                        => true,
        "title_ordered"                => true,
        "tombstone"                    => true,
        "access_deepblue"              => true,
        "access_deepblue_ordered"      => true,
        "total_file_size"              => true
      }

      expect(Deepblue::MetadataHelper.init_attribute_names_always_include_cc).to eq cc_attributes
    end
  end


  describe "#self.file_from_file_set" do
    context "when files on file_set parameter are nil" do
      it "returns nil" do
        expect(Deepblue::MetadataHelper.file_from_file_set OpenStruct.new(files: nil)).to be_blank
      end
    end

    context "when zero files on file_set parameter" do
      it "returns nil" do
        expect(Deepblue::MetadataHelper.file_from_file_set OpenStruct.new(files: [])).to be_blank
      end
    end

    context "when file(s) are on file_set parameter" do
      context "when file original_names exist" do
        it "returns last file with an original_name" do
          file1_o = OpenStruct.new(original_name: "First!!1")
          file2_o = OpenStruct.new(original_name: "a close second...")
          file3_o = OpenStruct.new(original_name: "")
          expect(Deepblue::MetadataHelper.file_from_file_set OpenStruct.new(files: [file1_o, file2_o, file3_o])).to eq file2_o
        end
      end

      context "when file original_names do not exist" do
        it "returns first file" do
          file1 = OpenStruct.new(original_name: "")
          file2 = OpenStruct.new(original_name: "")
          expect(Deepblue::MetadataHelper.file_from_file_set OpenStruct.new(files: [file1, file2])).to eq file1
        end
      end
    end
  end


  describe "#self.human_readable_size" do
    before {
      allow(ActiveSupport::NumberHelper::NumberToHumanSizeConverter).to receive(:convert).with(3500, precision: 3).and_return "3.5 KB"
    }
    it "calls NumberToHumanSizeConverter on value parameter" do
      expect(Deepblue::MetadataHelper.human_readable_size "3500").to eq "3.5 KB"
    end
  end


  describe "#self.log_lines" do
    output_buffer = StringIO.new
    lines = ["line1", "line2", "line3"]

    before {
      allow(File).to receive(:open).with("filename", "a").and_yield(output_buffer)
    }

    it "puts lines to file" do
      File.open("filename", "a") do |f|
        lines.each { |line| f.puts line }
      end
      expect(output_buffer.string).to eq "line1\nline2\nline3\n"

      Deepblue::MetadataHelper.log_lines("filename", lines)
    end
  end


  describe "#self.log_provenance_migrate" do
    context "when source parameter is 'DBDv1'" do

      context "when parent parameter is present" do
        message = "Migrate export classname K-963 parent_id: P-321"
        before {
          allow(PROV_LOGGER).to receive(:info).with message
        }
        it "calls ProvenanceLogger info with text including parent parameter" do
          expect(PROV_LOGGER).to receive(:info).with message
          c_c = OpenStruct.new(id: "K-963", class: OpenStruct.new(name: "classname"))
          Deepblue::MetadataHelper.log_provenance_migrate curation_concern: c_c, parent: OpenStruct.new(id: 'P-321'), migrate_direction: "export", source: "DBDv1"
        end
      end

      context "when parent parameter is NOT present" do
        message = "Migrate export classname E-332"
        before {
          allow(PROV_LOGGER).to receive(:info).with message
        }
        it "calls ProvenanceLogger message with text not including parent parameter" do
          expect(PROV_LOGGER).to receive(:info).with message
          c_c = OpenStruct.new(id: "E-332", class: OpenStruct.new(name: "classname"))
          Deepblue::MetadataHelper.log_provenance_migrate curation_concern: c_c, parent: nil, migrate_direction: "export", source: "DBDv1"
        end
      end
    end

    context "when source parameter is NOT 'DBDv1'" do
      context "when curation_concern does NOT respond to provenance_migrate" do
        it "returns nil" do
          expect(Deepblue::MetadataHelper.log_provenance_migrate curation_concern: OpenStruct.new(id: "K-936"), source: "DBDv2").to be_blank
        end
      end

      context "when curation_concern responds to provenance_migrate" do
        context "when parent parameter is present" do
          it "calls provenance_migrate on curation_concern with parameters including parent id" do
            ccpm = CurationConcernProvenanceMigrateMock.new
            expect(ccpm).to receive(:provenance_migrate).with(current_user: nil, parent_id: "P-885", migrate_direction: "export")
            expect(Deepblue::MetadataHelper.log_provenance_migrate curation_concern: ccpm, parent: OpenStruct.new(id: "P-885"), source: "DVDv2")
          end
        end

        context "when parent parameter is NOT present" do
          it "calls provenance_migrate on curation_concern with parameters excluding parent id" do
            ccpm = CurationConcernProvenanceMigrateMock.new
            expect(ccpm).to receive(:provenance_migrate).with(current_user: nil, parent_id: nil, migrate_direction: "export")
            expect(Deepblue::MetadataHelper.log_provenance_migrate curation_concern: ccpm, parent: nil, source: "DVDv2")
          end
        end
      end
    end
  end


  let(:path_root) { Rails.root.join('app', 'views') }

  describe "#self.metadata_filename_collection" do
    it "returns string" do
      result = Deepblue::MetadataHelper.metadata_filename_collection(path_root, OpenStruct.new(id: "collection_id"))
      expect(result.to_s.last(45)).to eq "app/views/w_collection_id_metadata_report.txt"
    end
  end


  describe "#self.metadata_filename_collection_work" do
    it "returns string" do
      returns = Deepblue::MetadataHelper.metadata_filename_collection_work(path_root, OpenStruct.new(id: "collection_id"), OpenStruct.new(id: "work_id"))
      expect(returns.to_s.last(55)).to eq "app/views/c_collection_id_w_work_id_metadata_report.txt"
    end
  end


  describe "#self.metadata_filename_work" do
    it "returns string" do
      following = Deepblue::MetadataHelper.metadata_filename_work(path_root, OpenStruct.new(id: "work_id"))
      expect(following.to_s.last(39)).to eq "app/views/w_work_id_metadata_report.txt"
    end
  end


  describe "#self.metadata_multi_valued?" do
    context "when attribute_value parameter is blank" do
      it "returns false" do
        expect(Deepblue::MetadataHelper.metadata_multi_valued? "").to eq false
      end
    end

    context "when attribute_value consists of more than one value" do
      it "returns true" do
        expect(Deepblue::MetadataHelper.metadata_multi_valued? ["one", "two"]).to eq true
      end
    end

    context "when attribute_value consists of only one value" do
      it "returns false" do
        expect(Deepblue::MetadataHelper.metadata_multi_valued? ["one"]).to eq false
      end

      it "returns false" do
        expect(Deepblue::MetadataHelper.metadata_multi_valued? "a lot").to eq false
      end
    end
  end


  describe "#self.ordered" do
    context "when values parameter is nil" do
      it "returns nil" do
        expect(Deepblue::MetadataHelper.ordered ordered_values: nil, values: nil).to be_blank
      end
    end

    context "when do_ordered_list_hack evaluates to positive" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:do_ordered_list_hack).and_return true}

      context "when the ordered_values parameter is NOT nil" do
        before {
          allow(Deepblue::OrderedStringHelper).to receive(:deserialize).with("ordered values").and_return "deserialized"
        }
        it "calls OrderedStringHelper.deserialize on ordered_values parameter and returns result" do
          expect(Deepblue::MetadataHelper.ordered ordered_values: "ordered values", values: "values").to eq "deserialized"
        end
      end

      context "when DeserializeError occurs" do
        before {
          allow(Deepblue::OrderedStringHelper).to receive(:deserialize).with("ordered values").and_raise(Deepblue::OrderedStringHelper::DeserializeError)
        }
         it "calls OrderedStringHelper.deserialize on ordered_values parameter, errors and returns values parameter" do
           expect(Deepblue::MetadataHelper.ordered ordered_values: "ordered values", values: "values").to eq "values"
         end
      end

      context "when the ordered_values parameter is nil" do
        it "returns the values parameter" do
          expect(Deepblue::MetadataHelper.ordered ordered_values: nil, values: "values").to eq "values"
        end
      end
    end
  end

  describe "#self.ordered_values" do
    context "when values parameter is nil" do
      it "returns nil" do
        expect(Deepblue::MetadataHelper.ordered_values ordered_values: nil, values: nil).to be_blank
      end
    end

    context "when do_ordered_list_hack evaluates to negative" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:do_ordered_list_hack).and_return false
      }
      it "returns nil" do
        expect(Deepblue::MetadataHelper.ordered_values ordered_values: nil, values: "values").to be_blank
      end
    end

    context "when do_ordered_list_hack evaluates to positive" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:do_ordered_list_hack).and_return true
        allow(Deepblue::OrderedStringHelper).to receive(:serialize).with("values").and_return "serialized"
      }

      context "when do_ordered_list_hack_save evaluates to positive" do
        before {
          allow(DeepBlueDocs::Application.config).to receive(:do_ordered_list_hack_save).and_return true
        }
        it "returns result of OrderedStringHelper.serialize" do
          expect(Deepblue::MetadataHelper.ordered_values ordered_values: nil, values: "values").to eq "serialized"
        end
      end

      # Should line 223 in metadata_helper.rb use ordered_values?
      context "when do_ordered_list_hack_save evaluates to negative and ordered_values parameter is not nil" do
        before {
          allow(DeepBlueDocs::Application.config).to receive(:do_ordered_list_hack_save).and_return false
        }
        it "returns result of OrderedStringHelper.serialize" do
          expect(Deepblue::MetadataHelper.ordered_values ordered_values: "ordered values", values: "values").to eq "serialized"
        end
      end
    end
  end


  describe "#self.report_collection" do
    context "when the out parameter is nil" do
      skip "Add a test for recursion"
    end

    context "when the out parameter is NOT nil" do
      out_collect = MockOutPrint.new
      collection_obj_pos = OpenStruct.new(id: "collection id", title: "title", member_objects: [1,2,3], bytes: 1500, creator: "creator", keyword: "keyword",
                                      subject_discipline: "subject discipline", language: "language", referenced_by: "referenced by", visibility: "visibility")
      collection_obj_zero = OpenStruct.new(id: "collection id", title: "title", member_objects: [], bytes: 1500, creator: "creator", keyword: "keyword",
                                      subject_discipline: "subject discipline", language: "language", referenced_by: "referenced by", visibility: "visibility")

      before {
        allow(Deepblue::MetadataHelper).to receive(:human_readable_size).with(1500).and_return "1.5 KB"

        allow(Deepblue::MetadataHelper).to receive(:report_item).with(out_collect, "ID: ", "collection id")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(out_collect, "Title: ", "title", one_line: true)
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(out_collect, "Total size: ", "1.5 KB")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(out_collect, "Creator: ", "creator", one_line: false, item_prefix: "\t")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(out_collect, "Keyword: ", "keyword", one_line: false, item_prefix: "\t")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(out_collect, "Discipline: ", "subject discipline", one_line: false, item_prefix: "\t")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(out_collect, "Language: ", "language")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(out_collect, "Citation to related material: ", "referenced by")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(out_collect, "Visibility: ", "visibility")
      }

      context "when the number of collection member objects is one or more" do
        before {
          allow(Deepblue::MetadataHelper).to receive(:report_title).with(collection_obj_pos, field_sep: '').and_return "title"
          allow(Deepblue::MetadataHelper).to receive(:report_item).with(out_collect, "Total items: ", 3)
          allow(Deepblue::MetadataHelper).to receive(:report_work).with(1, out: out_collect, depth: "===")
          allow(Deepblue::MetadataHelper).to receive(:report_work).with(2, out: out_collect, depth: "===")
          allow(Deepblue::MetadataHelper).to receive(:report_work).with(3, out: out_collect, depth: "===")
        }
        it "calls report_title then report_item ten times and returns nil" do
          expect(Deepblue::MetadataHelper).to receive(:report_title).with(collection_obj_pos, field_sep: '')
          expect(out_collect).to receive(:puts).with("== Collection: title ==")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(out_collect, "Total items: ", 3)

          expect(out_collect).to receive(:puts).with(no_args).exactly(3).times

          expect(Deepblue::MetadataHelper).to receive(:report_work).with(1, out: out_collect, depth: "===")
          expect(Deepblue::MetadataHelper).to receive(:report_work).with(2, out: out_collect, depth: "===")
          expect(Deepblue::MetadataHelper).to receive(:report_work).with(3, out: out_collect, depth: "===")

          expect(Deepblue::MetadataHelper.report_collection(collection_obj_pos, dir: nil, out: out_collect, depth: '==')).to be_blank
        end
      end

      context "when the number of collection member objects is zero" do
        out_object = MockOutObject.new
        before {
          allow(Deepblue::MetadataHelper).to receive(:report_title).with(collection_obj_zero, field_sep: '').and_return "title"
          allow(Deepblue::MetadataHelper).to receive(:report_item).with(out_object, "Total items: ", 0)
        }
        it "calls report_title then report_item ten times and returns nil" do
          expect(Deepblue::MetadataHelper).to receive(:report_title).with(collection_obj_zero, field_sep: '')
          expect(out_object).to receive(:puts).with("== Collection: title ==")

          expect(Deepblue::MetadataHelper).to receive(:report_item).with(out_object, "ID: ", "collection id")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(out_object, "Title: ", "title", one_line: true)
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(out_object, "Total items: ", 0)
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(out_object, "Total size: ", "1.5 KB")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(out_object, "Creator: ", "creator", one_line: false, item_prefix: "\t")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(out_object, "Keyword: ", "keyword", one_line: false, item_prefix: "\t")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(out_object, "Discipline: ", "subject discipline", one_line: false, item_prefix: "\t")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(out_object, "Language: ", "language")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(out_object, "Citation to related material: ", "referenced by")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(out_object, "Visibility: ", "visibility")

          expect(Deepblue::MetadataHelper).not_to receive(:report_work)

          expect(Deepblue::MetadataHelper.report_collection(collection_obj_zero, dir: nil, out: out_object, depth: '==')).to be_blank
        end
      end
    end
  end


  describe "#self.report_collection_work" do
    context "when the out parameter is nil" do
      it "opens metadata_filename_collection_work and calls report_collection_work" do
        skip "Add a test for recursion"
      end
    end

    context "when the out parameter is NOT nil" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:report_work).with("work", out: "out", depth: '==')
      }
      it "calls report_work and returns nil" do
        expect(Deepblue::MetadataHelper).to receive(:report_work).with("work", out: "out", depth: '==')
        expect(Deepblue::MetadataHelper.report_collection_work "collection", "work", out: "out").to be_blank
      end
    end
  end


  describe "#self.report_file_set" do
    mock_out = MockOutObject.new

    before {
      allow(Deepblue::MetadataHelper).to receive(:human_readable_size).with(2000).and_return "2 KB"
      allow(Deepblue::MetadataHelper).to receive(:report_item).with(mock_out, "ID: ", "file set id")
      allow(Deepblue::MetadataHelper).to receive(:report_item).with(mock_out, "File name: ", "label")
      allow(Deepblue::MetadataHelper).to receive(:report_item).with(mock_out, "Date uploaded: ", "date uploaded")
      allow(Deepblue::MetadataHelper).to receive(:report_item).with(mock_out, "Date modified: ", "date modified")
      allow(Deepblue::MetadataHelper).to receive(:report_item).with(mock_out, "Total file size: ", "2 KB")
      allow(Deepblue::MetadataHelper).to receive(:report_item).with(mock_out, "Checksum: ", "original checksum")
      allow(Deepblue::MetadataHelper).to receive(:report_item).with(mock_out, "Mimetype: ", "mime type")
    }

    it "calls puts on the out parameter and calls report_item seven times" do
      expect(mock_out).to receive(:puts).with("== File Set: label ==")
      expect(Deepblue::MetadataHelper).to receive(:report_item).with(mock_out, "ID: ", "file set id")
      expect(Deepblue::MetadataHelper).to receive(:report_item).with(mock_out, "File name: ", "label")
      expect(Deepblue::MetadataHelper).to receive(:report_item).with(mock_out, "Date uploaded: ", "date uploaded")
      expect(Deepblue::MetadataHelper).to receive(:report_item).with(mock_out, "Date modified: ", "date modified")
      expect(Deepblue::MetadataHelper).to receive(:report_item).with(mock_out, "Total file size: ", "2 KB")
      expect(Deepblue::MetadataHelper).to receive(:report_item).with(mock_out, "Checksum: ", "original checksum")
      expect(Deepblue::MetadataHelper).to receive(:report_item).with(mock_out, "Mimetype: ", "mime type")

      f_s = OpenStruct.new(label: "label", id: "file set id", date_uploaded: "date uploaded", date_modified: "date modified", file_size: [2000, 3000],
                           original_checksum: "original checksum", mime_type: "mime type" )

      Deepblue::MetadataHelper.report_file_set(f_s, out: mock_out, depth: "==")
    end
  end


  describe "#self.report_work" do
    context "when the out parameter is nil" do
      it "calls report_work on target_file and returns target_file" do
        skip "Add a test for open (file) and recursion"
      end
    end

    context "when the out parameter is NOT nil" do
      output = MockOutObject.new
      work_obj = OpenStruct.new(id: "work id", title: "work title", prior_identifier: "prior identifier", methodology: "methodology", description: "description",
                                creator: "creator", depositor: "depositor", authoremail: "author email", subject_discipline: "subject discipline",
                                fundedby: "funded by", fundedby_other: "funded by other", grantnumber: "grant number", keyword: "keyword",
                                date_coverage: "date coverage", referenced_by: "referenced by", language: "language", file_set_ids: ["a1", "b2", "c3"],
                                total_file_size: 4500, doi: "doi", visibility: "visibility", rights_license: "rights license",
                                rights_license_other: "rights license other", admin_set_id: "admin set id", tombstone: "tombstone",
                                file_sets: ["a1 file", "b2 file", "c3 file"] )

      before {
        allow(Deepblue::MetadataHelper).to receive(:report_title).with(work_obj, field_sep: "").and_return "report title"
        allow(output).to receive(:puts).with("== Generic Work: report title ==")

        allow(Deepblue::MetadataHelper).to receive(:human_readable_size).with(4500).and_return "4.5 KB"
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "ID: ", "work id")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Title: ", "work title", one_line: true)
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Prior Identifier: ", "prior identifier", one_line: true)
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Methodology: ", "methodology")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Description: ", "description", one_line: false, item_prefix: "\t")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Creator: ", "creator", one_line: false, item_prefix: "\t")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Depositor: ", "depositor")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Contact: ", "author email")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Discipline: ", "subject discipline", one_line: false, item_prefix: "\t")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Funded by: ", "funded by")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Funded by Other: ", "funded by other")  # DBDv2
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "ORSP Grant Number: ", "grant number")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Keyword: ", "keyword", one_line: false, item_prefix: "\t")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Date coverage: ", "date coverage")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Citation to related material: ", "referenced by")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Language: ", "language")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Total file count: ", 3)
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Total file size: ", "4.5 KB")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "DOI: ", "doi", optional: true)
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Visibility: ", "visibility")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Rights: ", "rights license")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Rights (other): ", "rights license other")  # DBDv2
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Admin set id: ", "admin set id")
        allow(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Tombstone: ", "tombstone", optional: true)

        allow(Deepblue::MetadataHelper).to receive(:report_work_datasets).with(work_obj.file_sets, out: output, depth: '==')
      }

      context "when source is 'DBDv1'" do
        before {
          allow(Deepblue::MetadataHelper).to receive(:report_source).and_return "DBDv1"
        }
        it "calls report item multiple times and returns nil" do
          expect(Deepblue::MetadataHelper).to receive(:report_title).with(work_obj, field_sep: "")
          expect(Deepblue::MetadataHelper).to receive(:human_readable_size).with(4500)
          
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "ID: ", "work id")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Title: ", "work title", one_line: true)
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Prior Identifier: ", "prior identifier", one_line: true)
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Methodology: ", "methodology")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Description: ", "description", one_line: false, item_prefix: "\t")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Creator: ", "creator", one_line: false, item_prefix: "\t")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Depositor: ", "depositor")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Contact: ", "author email")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Discipline: ", "subject discipline", one_line: false, item_prefix: "\t")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Funded by: ", "funded by")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "ORSP Grant Number: ", "grant number")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Keyword: ", "keyword", one_line: false, item_prefix: "\t")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Date coverage: ", "date coverage")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Citation to related material: ", "referenced by")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Language: ", "language")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Total file count: ", 3)
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Total file size: ", "4.5 KB")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "DOI: ", "doi", optional: true)
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Visibility: ", "visibility")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Rights: ", "rights license")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Admin set id: ", "admin set id")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Tombstone: ", "tombstone", optional: true)

          expect(Deepblue::MetadataHelper).not_to receive(:report_item).with(output, "Funded by Other: ", "funded by other")
          expect(Deepblue::MetadataHelper).not_to receive(:report_item).with(output, "Rights (other): ", "rights license other")

          expect(Deepblue::MetadataHelper.report_work(work_obj, out: output, depth: '==')).to be_blank
        end
      end

      context "when source is 'DBDv2'" do
        before {
          allow(Deepblue::MetadataHelper).to receive(:report_source).and_return "DBDv2"
        }
        it "calls report_item multiple times including 'Funded By Other' and 'Rights (other)' and returns nil" do
          expect(Deepblue::MetadataHelper).to receive(:report_title).with(work_obj, field_sep: "")
          expect(Deepblue::MetadataHelper).to receive(:human_readable_size).with(4500)

          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "ID: ", "work id")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Title: ", "work title", one_line: true)
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Prior Identifier: ", "prior identifier", one_line: true)
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Methodology: ", "methodology")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Description: ", "description", one_line: false, item_prefix: "\t")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Creator: ", "creator", one_line: false, item_prefix: "\t")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Depositor: ", "depositor")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Contact: ", "author email")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Discipline: ", "subject discipline", one_line: false, item_prefix: "\t")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Funded by: ", "funded by")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "ORSP Grant Number: ", "grant number")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Keyword: ", "keyword", one_line: false, item_prefix: "\t")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Date coverage: ", "date coverage")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Citation to related material: ", "referenced by")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Language: ", "language")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Total file count: ", 3)
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Total file size: ", "4.5 KB")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "DOI: ", "doi", optional: true)
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Visibility: ", "visibility")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Rights: ", "rights license")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Admin set id: ", "admin set id")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Tombstone: ", "tombstone", optional: true)

          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Funded by Other: ", "funded by other")
          expect(Deepblue::MetadataHelper).to receive(:report_item).with(output, "Rights (other): ", "rights license other")

          expect(Deepblue::MetadataHelper.report_work(work_obj, out: output, depth: '==')).to be_blank
        end
      end

      after {
        expect(output).to have_received(:puts).with "== Generic Work: report title =="

        expect(Deepblue::MetadataHelper).to have_received(:report_work_datasets).with(["a1 file", "b2 file", "c3 file"], out: output, depth: '==')
      }
    end
  end


  describe "#self.report_work_datasets" do
    outmock = MockOutPrint.new

    context "when one or more file sets" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:report_file_set).with("a1 file", out: outmock, depth: "===")
        allow(Deepblue::MetadataHelper).to receive(:report_file_set).with("b2 file", out: outmock, depth: "===")
        allow(Deepblue::MetadataHelper).to receive(:report_file_set).with("c3 file", out: outmock, depth: "===")
      }
      it "calls report_file_set for each file set" do
        expect(Deepblue::MetadataHelper).to receive(:report_file_set).with("a1 file", out: outmock, depth: "===")
        expect(Deepblue::MetadataHelper).to receive(:report_file_set).with("b2 file", out: outmock, depth: "===")
        expect(Deepblue::MetadataHelper).to receive(:report_file_set).with("c3 file", out: outmock, depth: "===")

        expect(outmock).to receive(:puts).thrice

        Deepblue::MetadataHelper.report_work_datasets ["a1 file", "b2 file", "c3 file"], out: outmock, depth: "=="
      end
    end

    context "when zero file sets" do
      it "returns nil" do
        expect(outmock).not_to receive(:puts)
        expect(Deepblue::MetadataHelper.report_work_datasets [], out: outmock, depth: "==").to be_blank
      end
    end
  end


  describe "#self.report_item" do

    context "when 'optional' parameter is true" do
      context "when value parameter is nil" do
        it "returns nil" do
          expect(Deepblue::MetadataHelper.report_item("out", "label", nil, optional: true)).to be_blank
        end
      end

      context "when value parameter is empty string" do
        it "returns nil" do
          expect(Deepblue::MetadataHelper.report_item("out", "label", "", optional: true)).to be_blank
        end
      end

      context "when count of value parameter is zero" do
        it "returns nil" do
          expect(Deepblue::MetadataHelper.report_item("out", "label", [], optional: true)).to be_blank
        end
      end
    end

    context "when 'optional' parameter is false" do
      out_print = MockOutPrint.new

      context "when one_line parameter is true" do

        context "when value can be joined (array)" do

          context "when array has one item" do
            it "puts a string with item" do
              expect(out_print).to receive(:puts).with "label pre_one_item_post"
              expect(Deepblue::MetadataHelper.report_item(out_print, "label ", ["one_item"], item_prefix: "pre_", item_postfix: "_post",
                                                          one_line: nil, optional: false)).to be_blank
            end
          end

          context "when array has more than one item" do
            it "puts a string with joined items" do
              expect(out_print).to receive(:puts).with "label pre_first_itempre_; _postsecond_item_post"
              expect(Deepblue::MetadataHelper.report_item(out_print, "label ", ["first_item", "second_item"], item_prefix: "pre_", item_postfix: "_post",
                                                          one_line: true, optional: false)).to be_blank
            end
          end
        end

        context "when value cannot be joined (hash)" do
          it "prints a label, prints the value, and puts an empty line" do
            expect(out_print).to receive(:print).with "label"
            expect(out_print).to receive(:print).with "pre[\"first\", \"itemized\"]post"
            expect(out_print).to receive(:puts)
            expect(Deepblue::MetadataHelper.report_item(out_print, "label", {"first" => "itemized"}, item_prefix: "pre", item_postfix: "post",
                                                        one_line: nil, optional: false)).to be_blank
          end
        end

        context "when value is a single object"
          it "puts a string" do
            expect(out_print).to receive(:puts).with "label pre_singular_post"
            expect(Deepblue::MetadataHelper.report_item(out_print, "label ", "singular", item_prefix: "pre_", item_postfix: "_post",
                                                        one_line: nil, optional: false)).to be_blank
          end
      end

      context "when value is an enumerator" do

        context "when value has multiple items" do
          it "puts label, then puts each item" do
            expect(out_print).to receive(:puts).with "label"
            expect(out_print).to receive(:puts).with "pre_magenta_post"
            expect(out_print).to receive(:puts).with "pre_yellow_post"
            expect(out_print).to receive(:puts).with "pre_cyan_post"
            Deepblue::MetadataHelper.report_item(out_print, "label", ["magenta", "yellow", "cyan"], item_prefix: "pre_", item_postfix: "_post",
                                                        one_line: nil, optional: false)
          end
        end

        context "when value has one item" do
          it "puts label and value" do
            expect(out_print).to receive(:puts).with "label"
            expect(out_print).to receive(:puts).with "pre_fuschia_post"
            Deepblue::MetadataHelper.report_item(out_print, "label", "fuschia", item_prefix: "pre_", item_postfix: "_post",
                                                        one_line: false, optional: false)
          end
        end
      end
    end
  end

  describe "#self.report_source" do
    it "returns string" do
      expect(Deepblue::MetadataHelper.report_source).to eq "DBDv2"
    end
  end


  describe "#self.report_title" do
    it "joins curation concern title with field separator" do
      expect(Deepblue::MetadataHelper.report_title OpenStruct.new(title: ["title", "subtitle"])).to eq "title; subtitle"
    end
  end


  describe "#self.yaml_body_collections" do
    cc = OpenStruct.new(id: "J-987", edit_users: "edit users", work_ids: ["W1", "W2"], total_file_size: 1000, visibility: "open",
                        collection_type: OpenStruct.new(machine_id: "M-121"))
    concerning_curation = OpenStruct.new(id: "J-988", edit_users: "edit users", work_ids: ["W3", "W4"], total_file_size: 3200, visibility: "public",
                                         collection_type: OpenStruct.new(machine_id: "M-122"))

    context "when source is 'DBDv2' and attribute_names_collection is empty" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":id:", "J-987")
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":collection_type:", "M-121", escape: true)
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":edit_users:", "edit users", escape: true)
        allow(Deepblue::MetadataHelper).to receive(:yaml_item_prior_identifier).with("out", "indent", curation_concern: cc, source: "DBDv2")
        allow(Deepblue::MetadataHelper).to receive(:yaml_item_subject).with("out", "indent", curation_concern: cc, source: "DBDv2")
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_work_count:", 2)
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_file_size:", 1000)
        allow(Deepblue::MetadataHelper).to receive(:human_readable_size).with(1000).and_return "1 KB"
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_file_size_human_readable:", "1 KB", escape: true)
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":visibility:", "open")
        allow(Deepblue::MetadataHelper).to receive(:attribute_names_collection).and_return []
      }
      it "calls methods with source DBDv2" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":id:", "J-987")
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":collection_type:", "M-121", escape: true)
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":edit_users:", "edit users", escape: true)
        expect(Deepblue::MetadataHelper).to receive(:yaml_item_prior_identifier).with("out", "indent", curation_concern: cc, source: "DBDv2")
        expect(Deepblue::MetadataHelper).to receive(:yaml_item_subject).with("out", "indent", curation_concern: cc, source: "DBDv2")
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_work_count:", 2)
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_file_size:", 1000)
        expect(Deepblue::MetadataHelper).to receive(:human_readable_size).with(1000).and_return "1 KB"
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_file_size_human_readable:", "1 KB", escape: true)
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":visibility:", "open")
        expect(Deepblue::MetadataHelper).not_to receive(:yaml_item_collection)

        Deepblue::MetadataHelper.yaml_body_collections("out", indent: "indent", curation_concern: cc, source: "DBDv2")
      end
    end

    context "when source is 'DBDv1' and attribute_names_collection has values" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":id:", "J-988")
        allow(Deepblue::MetadataHelper).to receive(:yaml_item_prior_identifier).with("out", "indent", curation_concern: concerning_curation, source: "DBDv1")
        allow(Deepblue::MetadataHelper).to receive(:yaml_item_subject).with("out", "indent", curation_concern: concerning_curation, source: "DBDv1")
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_work_count:", 2)
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_file_size:", 1000)
        allow(Deepblue::MetadataHelper).to receive(:human_readable_size).with(3200).and_return "3.2 KB"
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_file_size_human_readable:", "3.2KB", escape: true)
        allow(Deepblue::MetadataHelper).to receive(:attribute_names_collection).and_return ["prior_identifier", "rights", "rights_license", "subject",
                                                                                            "subject_discipline", "total_file_size", "umbrella" ]
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":visibility:", "public")
        allow(Deepblue::MetadataHelper).to receive(:yaml_item_collection).with("out", "indent", concerning_curation, name: "umbrella")
      }
      it "calls methods with source DBDv1 including yaml_item_collection" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":id:", "J-988")
        expect(Deepblue::MetadataHelper).not_to receive(:yaml_item).with("out", "indent", ":collection_type:", "M-122", escape: true)
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":edit_users:", "edit users", escape: true)
        expect(Deepblue::MetadataHelper).to receive(:yaml_item_prior_identifier).with("out", "indent", curation_concern: concerning_curation, source: "DBDv1")
        expect(Deepblue::MetadataHelper).to receive(:yaml_item_subject).with("out", "indent", curation_concern: concerning_curation, source: "DBDv1")
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_work_count:", 2)
        expect(Deepblue::MetadataHelper).to receive(:human_readable_size).with(3200).and_return "3.2 KB"
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":visibility:", "public")
        expect(Deepblue::MetadataHelper).to receive(:yaml_item_collection).with("out", "indent", concerning_curation, name: "umbrella")

        Deepblue::MetadataHelper.yaml_body_collections("out", indent: "indent", curation_concern: concerning_curation, source: "DBDv1")
      end
    end
  end

  
  describe "#self.yaml_body_files" do
    before {
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ":file_set_ids:")
    }

    context "when there are zero file sets" do
      it "calls yaml_line once then returns nil" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ":file_set_ids:")

        concerned_curator = OpenStruct.new(file_sets: [])
        expect(Deepblue::MetadataHelper.yaml_body_files("out", indent_base: "base", indent: "indent", curation_concern: concerned_curator,
                                                        mode: "build", source: "base", target_dirname: "directory")).to be_blank
      end
    end

    context "when there are one or more file sets" do
      file_set = OpenStruct.new(id: "I-333", title: ["Headline"], edit_users: "edit users", mime_type: "text/plain", original_checksum: [12, 134],
                                original_file: OpenStruct.new(original_name: "original name"), visibility: "public")
      concerned_curator = OpenStruct.new(file_sets: [file_set])
      checksum = OpenStruct.new(algorithm: "algorithm", value: "value")

      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent-", "", "I-333", escape: true)
        allow(Deepblue::MetadataHelper).to receive(:log_provenance_migrate).with(curation_concern: file_set, parent: concerned_curator, source: "base")
        allow(Deepblue::MetadataHelper).to receive(:yaml_file_set_id).with(file_set).and_return "file id"
        allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ":file id:")
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":id:", "I-333", escape: true)
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":title:", file_set.title, escape: true, single_value: true)
        allow(Deepblue::MetadataHelper).to receive(:yaml_item_prior_identifier).with("out", "baseindent", curation_concern: file_set, source: "base")
        allow(Deepblue::MetadataHelper).to receive(:yaml_export_file_path).with(target_dirname: "directory", file_set: file_set).and_return "file path"
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":file_path:", "file path", escape: true)
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":edit_users:", "edit users", escape: true )
        allow(Deepblue::MetadataHelper).to receive(:yaml_file_size).with(file_set).and_return "file size"
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":file_size:", "file size")
        allow(Deepblue::MetadataHelper).to receive(:human_readable_size).with("file size").and_return "human readable size"
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":file_size_human_readable:", "human readable size", escape: true)
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":mime_type:", "text/plain", escape: true)
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":original_checksum:", 12)
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":original_name:", "original name", escape: true)
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":visibility:", "public")
        allow(Deepblue::MetadataHelper).to receive(:attribute_names_file_set).and_return ["title", "file_size", "server_size"]
        allow(Deepblue::MetadataHelper).to receive(:yaml_item_file_set).with("out", "baseindent", file_set, name: "server_size")
      }

      context "when checksum is present" do
        before {
          allow(Deepblue::MetadataHelper).to receive(:yaml_file_set_checksum).with(file_set: file_set).and_return checksum
          allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":checksum_algorithm:", "algorithm", escape: true)
          allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":checksum_value:", "value", escape: true)
        }

        context "when mode is migrate" do
          it "calls yaml functions including log_provenance_migrate" do
            expect(Deepblue::MetadataHelper).to receive(:log_provenance_migrate).with(curation_concern: file_set, parent: concerned_curator, source: "base" )

            Deepblue::MetadataHelper.yaml_body_files("out", indent_base: "base", indent: "indent", curation_concern: concerned_curator,
                                                            mode: "migrate", source: "base", target_dirname: "directory")
          end
        end

        context "when mode is NOT migrate" do
          it "calls yaml functions excluding log_provenance_migrate" do
            expect(Deepblue::MetadataHelper).not_to receive(:log_provenance_migrate)

            Deepblue::MetadataHelper.yaml_body_files("out", indent_base: "base", indent: "indent", curation_concern: concerned_curator,
                                                     mode: "build", source: "base", target_dirname: "directory")
          end
        end

        after {
          expect(Deepblue::MetadataHelper).to have_received(:yaml_line).with("out", "indent", ":file_set_ids:")
          expect(Deepblue::MetadataHelper).to have_received(:yaml_line).with("out", "indent", ":file id:")
          expect(Deepblue::MetadataHelper).to have_received(:yaml_item).with("out", "baseindent-", "", "I-333", escape: true)
          expect(Deepblue::MetadataHelper).to have_received(:yaml_item).with("out", "baseindent", ":id:", "I-333", escape: true)
          expect(Deepblue::MetadataHelper).to have_received(:yaml_item).with("out", "baseindent", ":title:", file_set.title, escape: true, single_value: true)
          expect(Deepblue::MetadataHelper).to have_received(:yaml_item_prior_identifier).with("out", "baseindent", curation_concern: file_set, source: "base")
          expect(Deepblue::MetadataHelper).to have_received(:yaml_export_file_path).with(target_dirname: "directory", file_set: file_set)
          expect(Deepblue::MetadataHelper).to have_received(:yaml_item).with("out", "baseindent", ":file_path:", "file path", escape: true)
          expect(Deepblue::MetadataHelper).to have_received(:yaml_item).with("out", "baseindent", ":checksum_algorithm:", "algorithm", escape: true)
          expect(Deepblue::MetadataHelper).to have_received(:yaml_item).with("out", "baseindent", ":checksum_value:", "value", escape: true)
          expect(Deepblue::MetadataHelper).to have_received(:yaml_item).with("out", "baseindent", ":edit_users:", "edit users", escape: true)
          expect(Deepblue::MetadataHelper).to have_received(:yaml_item).with("out", "baseindent", ":file_size:", "file size")
          expect(Deepblue::MetadataHelper).to have_received(:human_readable_size).with("file size")
          expect(Deepblue::MetadataHelper).to have_received(:yaml_item).with("out", "baseindent", ":file_size_human_readable:", "human readable size", escape: true)
          expect(Deepblue::MetadataHelper).to have_received(:yaml_item).with("out", "baseindent", ":mime_type:", "text/plain", escape: true)
          expect(Deepblue::MetadataHelper).to have_received(:yaml_item).with("out", "baseindent", ":original_checksum:", 12)
          expect(Deepblue::MetadataHelper).to have_received(:yaml_item).with("out", "baseindent", ":visibility:", "public")
          expect(Deepblue::MetadataHelper).to have_received(:yaml_item).with("out", "baseindent", ":original_name:", "original name", escape: true)
          expect(Deepblue::MetadataHelper).to have_received(:yaml_item_file_set).with("out", "baseindent", file_set, name: "server_size")
        }
      end

      context "when checksum is not present" do
        before {
          allow(Deepblue::MetadataHelper).to receive(:yaml_file_set_checksum).with(file_set: file_set).and_return nil
          allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":checksum_algorithm:", "", escape: true)
          allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":checksum_value:", "", escape: true)
        }
        it "calls yaml functions with empty string instead of checksum values" do
          expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ":file_set_ids:")
          expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent-", "", "I-333", escape: true)
          expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":id:", "I-333", escape: true)
          expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":title:", file_set.title, escape: true, single_value: true)
          expect(Deepblue::MetadataHelper).to receive(:yaml_item_prior_identifier).with("out", "baseindent", curation_concern: file_set, source: "base")
          expect(Deepblue::MetadataHelper).to receive(:yaml_export_file_path).with(target_dirname: "directory", file_set: file_set)
          expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":file_path:", "file path", escape: true)
          expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":checksum_algorithm:", "", escape: true)
          expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":checksum_value:", "", escape: true)
          expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":edit_users:", "edit users", escape: true)
          expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":file_size:", "file size")
          expect(Deepblue::MetadataHelper).to receive(:human_readable_size).with("file size")
          expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":file_size_human_readable:", "human readable size", escape: true)
          expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":mime_type:", "text/plain", escape: true)
          expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":original_checksum:", 12)
          expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":visibility:", "public")
          expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "baseindent", ":original_name:", "original name", escape: true)
          expect(Deepblue::MetadataHelper).to receive(:yaml_item_file_set).with("out", "baseindent", file_set, name: "server_size")

          Deepblue::MetadataHelper.yaml_body_files("out", indent_base: "base", indent: "indent", curation_concern: concerned_curator,
                                                   mode: "build", source: "base", target_dirname: "directory")
        end
      end
    end
  end


  describe "#self.yaml_file_size" do
    context "when file_size is blank" do

      context "when original_file is nil" do
        it "returns zero" do
          expect(Deepblue::MetadataHelper.yaml_file_size OpenStruct.new(file_size: nil, original_file: nil)).to eq 0
        end
      end

      context "when original_file is not nil" do
        it "returns original_file.size" do
          expect(Deepblue::MetadataHelper.yaml_file_size OpenStruct.new(file_size: nil, original_file: OpenStruct.new(size: 22))).to eq 22
        end
      end
    end

    context "when file_size is not blank" do
      it "returns first element in file_size" do
        expect(Deepblue::MetadataHelper.yaml_file_size OpenStruct.new(file_size: [56, 23], original_file: OpenStruct.new(size: 25))).to eq 56
      end
    end

  end


  describe "#self.yaml_body_user_body" do
    other_user = OpenStruct.new(email: "other@example.com")
    before {
      allow(Deepblue::MetadataHelper).to receive(:yaml_user_email).with(other_user).and_return "user_email"
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indentation", ":user_email:")
      allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "basic indentation", ":email:", "other@example.com", escape: true)
      allow(Deepblue::MetadataHelper).to receive(:attribute_names_user).and_return %w[ sepulchre, email ]
      allow(Deepblue::MetadataHelper).to receive(:yaml_item_user).with("out", "basic indentation", other_user, name: "sepulchre")
    }

    it "calls yaml functions" do
      expect(Deepblue::MetadataHelper).to receive(:yaml_user_email).with(other_user).and_return "user_email"
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indentation", ":user_email:")
      expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "basic indentation", ":email:", "other@example.com", escape: true)
      expect(Deepblue::MetadataHelper).to receive(:attribute_names_user).and_return [ "sepulchre", "email" ]
      expect(Deepblue::MetadataHelper).to receive(:yaml_item_user).with("out", "basic indentation", other_user, name: "sepulchre")

      expect(Deepblue::MetadataHelper).not_to receive(:yaml_item_user).with("out", "basic indentation", other_user, name: "email")

      Deepblue::MetadataHelper.yaml_body_user_body("out", indent_base: "basic ", indent: "indentation", user: other_user)
    end
  end


  describe "#self.yaml_body_users" do
    before {
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ":user_emails:")
    }

    context "when users count is one or more" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_user_count:", 1)
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent base indent-", "", "user@example.com", escape: true)
      }
      it "calls yaml_item twice and yaml_line once" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_user_count:", 1)
        expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ":user_emails:")
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent base indent-", "", "user@example.com", escape: true)

        Deepblue::MetadataHelper.yaml_body_users("out", indent_base: "indent base ", indent: "indent", users: [OpenStruct.new(email: "user@example.com")])
      end
    end

    context "when users count zero" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_user_count:", 0)
      }
      it "calls yaml_item and yaml_line" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_user_count:", 0)
        expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ":user_emails:")

        Deepblue::MetadataHelper.yaml_body_users("out", indent_base: "indent base", indent: "indent", users: [])
      end
    end
  end


  describe "#self.yaml_body_works" do
    cura_con = OpenStruct.new(id: "id", admin_set_id: "admin_set_id", edit_users: "edit_users", file_set_ids: ["X", "Y", "Z"], total_file_size: 2500, visibility: "public")
    skip_names = %w[ prior_identifier rights rights_license subject subject_discipline total_file_size ]

    before {
      allow(Deepblue::MetadataHelper).to receive(:human_readable_size).with(2500).and_return "2.5 KB"
      allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":id:", "id")
      allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":admin_set_id:", "admin_set_id", escape: true)
      allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":edit_users:", "edit_users", escape: true)
      allow(Deepblue::MetadataHelper).to receive(:yaml_item_prior_identifier).with("out", "indent", curation_concern: cura_con, source: "source")
      allow(Deepblue::MetadataHelper).to receive(:yaml_item_rights).with("out", "indent", curation_concern: cura_con, source: "source")
      allow(Deepblue::MetadataHelper).to receive(:yaml_item_subject).with("out", "indent", curation_concern: cura_con, source: "source")
      allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_file_count:", 3)
      allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_file_size:", 2500)
      allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_file_size_human_readable:", "2.5 KB", escape: true)
      allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":visibility:", "public")

      allow(Deepblue::MetadataHelper).to receive(:attribute_names_work).with(source: "source")
                                                                       .and_return skip_names.dup.append("creator")
      allow(Deepblue::MetadataHelper).to receive(:yaml_item_work).with("out", "indent", cura_con, name: "creator")
    }
    it "calls yaml functions" do
      expect(Deepblue::MetadataHelper).to receive(:human_readable_size).with(2500).and_return "2.5 KB"
      expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":id:", "id")
      expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":admin_set_id:", "admin_set_id", escape: true)
      expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":edit_users:", "edit_users", escape: true)
      expect(Deepblue::MetadataHelper).to receive(:yaml_item_prior_identifier).with("out", "indent", curation_concern: cura_con, source: "source")
      expect(Deepblue::MetadataHelper).to receive(:yaml_item_rights).with("out", "indent", curation_concern: cura_con, source: "source")
      expect(Deepblue::MetadataHelper).to receive(:yaml_item_subject).with("out", "indent", curation_concern: cura_con, source: "source")
      expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_file_count:", 3)
      expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_file_size:", 2500)
      expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":total_file_size_human_readable:", "2.5 KB", escape: true)
      expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":visibility:", "public")

      expect(Deepblue::MetadataHelper).to receive(:yaml_item_work).with("out", "indent", cura_con, name: "creator")

      skip_names.each do |skipped|
        expect(Deepblue::MetadataHelper).not_to receive(:yaml_item_work).with("out", "indent", cura_con, name: skipped)
      end

      Deepblue::MetadataHelper.yaml_body_works("out", indent: "indent", curation_concern: cura_con, source: "source")
    end
  end


  describe "#self.yaml_escape_value" do
    context "when value is nil" do
      it "returns empty string" do
        expect(Deepblue::MetadataHelper.yaml_escape_value nil, comment: false, escape: false).to be_blank
      end
    end

    context "when escape is false" do
      it "returns value parameter" do
        expect(Deepblue::MetadataHelper.yaml_escape_value "some value", comment: false, escape: false).to eq "some value"
      end
    end

    context "when comment is true" do
      it "returns value entered" do
        expect(Deepblue::MetadataHelper.yaml_escape_value "a value", comment: true, escape: true).to eq "a value"
      end
    end

    context "when JSON encoded value is '\'\'' " do
      it "returns empty string" do
        expect(Deepblue::MetadataHelper.yaml_escape_value "", comment: false, escape: true).to be_blank
      end
    end

    context "when value is NOT '\'\'' " do
      it "returns value parameter with JSON encoding" do
        expect(Deepblue::MetadataHelper.yaml_escape_value "a value", comment: false, escape: true).to eq "\"a value\""
      end
    end
  end


  describe "#self.yaml_export_file_path" do
    file_set = OpenStruct.new(id: "V-533")
    before {
      allow(Deepblue::MetadataHelper).to receive(:file_from_file_set).with(file_set).and_return OpenStruct.new(original_name: "the original")
    }
    it "returns string" do
      expect((Deepblue::MetadataHelper.yaml_export_file_path target_dirname: Pathname.new("dir1"), file_set: file_set).to_s).to eq "dir1/V-533_the original"
    end
  end


  describe "#self.yaml_file_set_checksum" do
    context "when file is present" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:file_from_file_set).with("file set").and_return OpenStruct.new(checksum: "check sum")
      }
      it "returns file checksum" do
        expect(Deepblue::MetadataHelper.yaml_file_set_checksum file_set: "file set").to eq "check sum"
      end
    end

    context "when file is NOT present" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:file_from_file_set).with("file set").and_return nil
      }
      it "returns nil" do
        expect(Deepblue::MetadataHelper.yaml_file_set_checksum file_set: "file set").to be_blank
      end
    end
  end


  describe "#self.yaml_file_set_id" do
    it "returns string that joins 'f_' with file set id" do
      expect(Deepblue::MetadataHelper.yaml_file_set_id OpenStruct.new(id: "F-899")).to eq "f_F-899"
    end
  end


  describe "#self.yaml_filename" do
    context "when pathname_dir parameter is NOT a Pathname" do
      before {
        double_pn = double
        allow(Pathname).to receive(:new).with("pathname directory").and_return double_pn
        allow(double_pn).to receive(:join).with("prefixI-88_task.yml").and_return "new pathname 1/prefixI-88_task.yml"
      }
      it "creates new Pathname to join with prefix" do
        expect(Deepblue::MetadataHelper.yaml_filename(pathname_dir: "pathname directory", id: "I-88", prefix: "prefix",
                                                      task: "task")).to eq "new pathname 1/prefixI-88_task.yml"
      end
    end

    context "when pathname_dir parameter is a Pathname" do
      path_name = Pathname.new("pathname one")
      before {
        allow(path_name).to receive(:join).with("prefixI-88_task.yml").and_return "pathname one/prefixI-88_task.yml"
      }
      it "joins Pathname parameter with prefix" do
        expect(Pathname).not_to receive(:new)
        expect(Deepblue::MetadataHelper.yaml_filename(pathname_dir: path_name, id: "I-88", prefix: "prefix", task: "task"))
          .to eq "pathname one/prefixI-88_task.yml"
      end
    end
  end


  describe "#self.yaml_filename_collection" do
    before {
      allow(Deepblue::MetadataHelper).to receive(:yaml_filename).with(pathname_dir: "pathname directory", id: "P-1212", prefix: "c_", task: "populate")
    }
    it "calls yaml_filename and passes in parameters" do
      expect(Deepblue::MetadataHelper).to receive(:yaml_filename).with(pathname_dir: "pathname directory", id: "P-1212", prefix: "c_", task: "populate")

      Deepblue::MetadataHelper.yaml_filename_collection(pathname_dir: "pathname directory", collection: OpenStruct.new(id: "P-1212"), task: "populate")
    end
  end


  describe "#self.yaml_filename_users" do
    before {
      allow(Deepblue::MetadataHelper).to receive(:yaml_filename).with(pathname_dir: "pathname directory", id: "", prefix: "users", task: "populate")
    }

    it "calls yaml_filename and passes in parameters" do
      expect(Deepblue::MetadataHelper).to receive(:yaml_filename).with(pathname_dir: "pathname directory", id: "", prefix: "users", task: "populate")

      Deepblue::MetadataHelper.yaml_filename_users(pathname_dir: "pathname directory", task: "populate")
    end
  end


  describe "#self.yaml_filename_work" do
    before {
      allow(Deepblue::MetadataHelper).to receive(:yaml_filename).with(pathname_dir: "pathname directory", id: "W-222", prefix: "w_", task: "populate")
    }

    it "calls yaml_filename and passes in parameters" do
      expect(Deepblue::MetadataHelper).to receive(:yaml_filename).with(pathname_dir: "pathname directory", id: "W-222", prefix: "w_", task: "populate")

      Deepblue::MetadataHelper.yaml_filename_work(pathname_dir: "pathname directory", work: OpenStruct.new(id: "W-222"), task: "populate")
    end
  end


  describe "#self.yaml_header" do
    before {
      allow(DateTime).to receive(:now).and_return DateTime.new(2025, 9, 10, 11, 12, 13)
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':email:', "depositor")
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':visibility:', "visible")
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':ingester:', '')
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ":source:", "source")
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ":export_timestamp:", "2025-09-10T11:12:13+00:00")
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':mode:', "mode")
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ":id:", "M-4545")
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", "header type")
    }
    it "calls yaml_line repeatedly with parameters" do
      expect(DateTime).to receive(:now).and_return DateTime.new(2025, 9, 10, 11, 12, 13)
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':email:', "depositor")
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':visibility:', "visible")
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':ingester:', '')
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ":source:", "source")
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ":export_timestamp:", "2025-09-10T11:12:13+00:00")
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':mode:', "mode")
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ":id:", "M-4545")
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", "header type")

      c_c = CurationConcerningMock.new("depositor", "visible", "M-4545")
      Deepblue::MetadataHelper.yaml_header "out", indent: "indent", curation_concern: c_c, header_type: "header type", source: "source", mode: "mode"
    end
  end


  describe "#self.yaml_header_populate" do
    before {
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", "filename", comment: true)
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", 'bundle exec rake umrdr:populate[filename]', comment: true)
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", "---")
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ":user:")
    }
    it "calls yaml_line repeatedly with parameters" do
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", "filename", comment: true)
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", 'bundle exec rake umrdr:populate[filename]', comment: true)
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", "---")
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ":user:")

      Deepblue::MetadataHelper.yaml_header_populate "out", indent: "indent", rake_task: 'umrdr:populate', target_filename: "filename"
    end
  end


  describe "#self.yaml_header_users" do
    before {
      allow(DateTime).to receive(:now).and_return DateTime.new(2025, 9, 10)
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':ingester:', '')
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':source:', "source")
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':export_timestamp:', "2025-09-10T00:00:00+00:00")
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':mode:', 'mode')
      allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", 'users:')
    }
    it "calls yaml_line repeatedly with parameters" do
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':ingester:', '')
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':source:', "source")
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':export_timestamp:', "2025-09-10T00:00:00+00:00")
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':mode:', 'mode')
      expect(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "indent", ':users:')

      Deepblue::MetadataHelper.yaml_header_users "out", indent: "indent", header_type: ':users:', source: "source", mode: "mode"
    end
  end


  describe "#self.yaml_is_a_work?" do
    context "when source parameter is 'DBDv2'" do
      context "when curation_concern parameter is a DataSet" do
        it "returns true" do
          expect(Deepblue::MetadataHelper.yaml_is_a_work? curation_concern: DataSet.new, source: "DBDv2").to eq true
        end
      end

      context "when curation_concern parameter is NOT a DataSet" do
        it "returns false" do
          expect(Deepblue::MetadataHelper.yaml_is_a_work? curation_concern: GenericWork.new, source: "DBDv2").to eq false
        end
      end
    end

    context "when source parameter is NOT 'DBDv2'" do
      context "when curation_concern parameter is a GenericWork"
        it "returns true" do
          expect(Deepblue::MetadataHelper.yaml_is_a_work? curation_concern: GenericWork.new, source: "DBDv1").to eq true
        end
    end

    context "when curation_concern parameter is NOT a GenericWork" do
      it "returns false" do
        expect(Deepblue::MetadataHelper.yaml_is_a_work? curation_concern: DataSet.new, source: "DBDv1").to eq false
      end
    end
  end


  describe "#self.yaml_item" do
    context "when single_value is true, value is present and value is an enumerator" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_escape_value).with("value", comment: false, escape: false).and_return "yaml escape value"
      }
      it "calls yaml_escape_value and puts parameters as a string" do
        mo = MockOutObject.new

        expect(Deepblue::MetadataHelper).to receive(:yaml_escape_value)
        expect(mo).to receive(:puts).with "indentlabel yaml escape value"
        Deepblue::MetadataHelper.yaml_item(mo, "indent", "label", ["value"], single_value: true)
      end
    end

    context "when single_value is false, value is present and value is an enumerator" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_escape_value).with("value1", comment: false, escape: false).and_return "yaml escape value1"
        allow(Deepblue::MetadataHelper).to receive(:yaml_escape_value).with("value2", comment: false, escape: false).and_return "yaml escape value2"
      }
      it "calls yaml_escape_value and puts items as strings" do
        mo_o = MockOutObject.new

        expect(Deepblue::MetadataHelper).to receive(:yaml_escape_value).twice
        expect(mo_o).to receive(:puts).with "indentlabel "
        expect(mo_o).to receive(:puts).with "indentbase- yaml escape value1"
        expect(mo_o).to receive(:puts).with "indentbase- yaml escape value2"
        Deepblue::MetadataHelper.yaml_item(mo_o, "indent", "label", ["value1", "value2"], single_value: false, indent_base: "base")
      end
    end

    context "when single_value is false, and value is not an enumerator- and comment is true" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_escape_value).with("only value", comment: true, escape: false).and_return "yaml escape only value"
      }
      it "calls yaml_escape_value and puts parameters as a comment string" do
        mo = MockOutObject.new

        expect(Deepblue::MetadataHelper).to receive(:yaml_escape_value)
        expect(mo).to receive(:puts).with "# indentlabel yaml escape only value"
        Deepblue::MetadataHelper.yaml_item(mo, "indent", "label", "only value", single_value: false, comment: true)
      end
    end
  end


  describe "#self.yaml_item_collection" do
    ignore_list.each do |attr|
      context "when ATTRIBUTE_NAMES_IGNORE includes name parameter (#{attr})" do
        it "returns nil" do
          expect(Deepblue::MetadataHelper).not_to receive(:yaml_item)
          expect(Deepblue::MetadataHelper.yaml_item_collection "out", "indent", "curation concern", name: attr).to be_blank
        end
      end
    end

    context "when file_set value is blank" do
      context "when ATTRIBUTE_NAMES_ALWAYS_INCLUDE_CC does NOT include name" do
        it "returns nil" do
          expect(Deepblue::MetadataHelper).not_to receive(:yaml_item)
          expect(Deepblue::MetadataHelper.yaml_item_collection "out", "indent", { }, name: "writer").to be_blank
        end
      end

      always_cc.each do |attr|
        context "when ATTRIBUTE_NAMES_ALWAYS_INCLUDE_CC includes name (#{attr})" do
          before {
            allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":#{attr}:", "", escape: true)
          }
          it "calls yaml_item with parameters including blank value" do
            expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":#{attr}:", "", escape: true)
            Deepblue::MetadataHelper.yaml_item_collection "out", "indent", {attr => ""}, name: attr
          end
        end
      end
    end

    context "when ATTRIBUTE_NAMES_IGNORE does NOT include name and file_set has value" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":writer:", "novelist", escape: true)
      }
      it "calls yaml_item with parameters" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":writer:", "novelist", escape: true)
        Deepblue::MetadataHelper.yaml_item_collection "out", "indent", {"writer" => "novelist"}, name: "writer"
      end
    end
  end


  describe "#self.yaml_item_file_set" do
    ignore_list.each do |attr|
      context "when ATTRIBUTE_NAMES_IGNORE includes name parameter (#{attr})" do
        it "returns nil" do
          expect(Deepblue::MetadataHelper).not_to receive(:yaml_item)
          expect(Deepblue::MetadataHelper.yaml_item_file_set("out", "indent", "file set", name: attr )).to be_blank
        end
      end
    end

    context "when file_set value is blank" do
      always_file_set.each do |attr|
        context "when file_set value is blank and ATTRIBUTE_NAMES_ALWAYS_INCLUDE_FILE_SET includes name (#{attr})" do
          before {
            allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":#{attr}:", "", escape: true)
          }
          it "calls yaml_item with name (#{attr}) and blank value" do
            expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":#{attr}:", "", escape: true)
            expect(Deepblue::MetadataHelper.yaml_item_file_set("out", "indent", OpenStruct.new("#{attr}": ""), name: attr )).to be_blank
          end
        end
      end

      context "when file_set value is blank and ATTRIBUTE_NAMES_ALWAYS_INCLUDE_FILE_SET does NOT include name" do
        it "returns nil" do
          expect(Deepblue::MetadataHelper).not_to receive(:yaml_item)
          expect(Deepblue::MetadataHelper.yaml_item_file_set("out", "indent", OpenStruct.new("dopamine": ""), name: "dopamine" )).to be_blank
        end
      end
    end

    context "when ATTRIBUTE_NAMES_IGNORE does NOT include name and value is not blank" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":Home:", "File Set", escape: true)
      }
      it "calls yaml_item with name and value" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":Home:", "File Set", escape: true)
        Deepblue::MetadataHelper.yaml_item_file_set("out", "indent", OpenStruct.new(Home: "File Set"), name: "Home")
      end
    end
  end


  describe "#self.yaml_item_prior_identifier" do
    context "when source is 'DBDv1'" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":prior_identifier:", "")
      }
      it "calls yaml_item with prior_identifier and blank value" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":prior_identifier:", "")
        Deepblue::MetadataHelper.yaml_item_prior_identifier("out", "indent", curation_concern: "", source: "DBDv1")
      end
    end

    context "when source is NOT 'DBDv1'" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":prior_identifier:", "The Priory")
      }
      it "calls yaml_item with prior_identifier and value" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":prior_identifier:", "The Priory")
        Deepblue::MetadataHelper.yaml_item_prior_identifier("out", "indent", curation_concern: OpenStruct.new(prior_identifier: "The Priory"), source: "DBDv2")
      end
    end
  end


  describe "#self.yaml_item_referenced_by" do
    context "when source is 'DBDv1'" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":isReferencedBy:", "bibliography", escape: true)
      }
      it "calls yaml_item with isReferencedBy" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":isReferencedBy:", "bibliography", escape: true)
        Deepblue::MetadataHelper.yaml_item_referenced_by("out", "indent", curation_concern: OpenStruct.new(isReferencedBy: "bibliography"), source: "DBDv1")
      end
    end

    context "when source is NOT 'DBDv1'" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":referenced_by:", "discography", escape: true)
      }
      it "calls yaml_item with referenced_by" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":referenced_by:", "discography", escape: true)
        Deepblue::MetadataHelper.yaml_item_referenced_by("out", "indent", curation_concern: OpenStruct.new(referenced_by: "discography"), source: "DBDv2")
      end
    end
  end


  describe "#self.yaml_item_rights" do
    context "when source is 'DBDv1'" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":rights:", "universal", escape: true)
      }
      it "calls yaml_item with rights" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":rights:", "universal", escape: true)
        Deepblue::MetadataHelper.yaml_item_rights("out", "indent", curation_concern: OpenStruct.new(rights: "universal"), source: "DBDv1")
      end
    end

    context "when source is NOT 'DBDv1'" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":rights_license:", "trademark", escape: true)
      }
      it "calls yaml_item with rights_license" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":rights_license:", "trademark", escape: true)
        Deepblue::MetadataHelper.yaml_item_rights("out", "indent", curation_concern: OpenStruct.new(rights_license: "trademark"), source: "DBDv2")
      end
    end
  end


  describe "#self.yaml_item_subject" do
    context "when source is 'DBDv1'" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":subject:", "subjectivity", escape: true)
      }
      it "calls yaml_item with subject" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":subject:", "subjectivity", escape: true)
        Deepblue::MetadataHelper.yaml_item_subject("out", "indent", curation_concern: OpenStruct.new(subject: "subjectivity"), source: "DBDv1")
      end
    end

    context "when source is NOT 'DBDv1'" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":subject_discipline:", "dressage", escape: true)
      }
      it "calls yaml_item with subject_discipline" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":subject_discipline:", "dressage", escape: true)
        Deepblue::MetadataHelper.yaml_item_subject("out", "indent", curation_concern: OpenStruct.new(subject_discipline: "dressage"), source: "DBDv2")
      end
    end
  end


  describe "#self.yaml_item_user" do
    user_ignore.each do |attr|
      context "when name is ignored attribute name (#{attr})" do
        it "returns nil" do
          expect(Deepblue::MetadataHelper).not_to receive(:yaml_item)
          expect(Deepblue::MetadataHelper.yaml_item_user "out", "indent", {"name" => "baby"}, name: attr).to be_blank
        end
      end
    end

    context "when value is blank" do
      context "when ATTRIBUTE_NAMES_ALWAYS_INCLUDE_USER does NOT include name" do
        it "returns nil" do
          expect(Deepblue::MetadataHelper).not_to receive(:yaml_item)
          expect(Deepblue::MetadataHelper.yaml_item_user "out", "indent", {"name" => ""}, name: "name").to be_blank
        end
      end

      %w[ email id ].each do |attr|
        context "when ATTRIBUTE_NAMES_ALWAYS_INCLUDE_USER includes name (#{attr})" do
          it "calls yaml_item with attribute name (#{attr})" do
            expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":#{attr}:", "", escape: true)
            expect(Deepblue::MetadataHelper.yaml_item_user "out", "indent", {"#{attr}" => ""}, name: attr).to be_blank
          end
        end
      end
    end

    context "when value is not ignored attribute name" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":name:", "baby", escape: true)
      }
      it "calls yaml_item with attribute name" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":name:", "baby", escape: true)
        expect(Deepblue::MetadataHelper.yaml_item_user "out", "indent", {"name" => "baby"}, name: "name")
      end
    end
  end


  describe "#self.yaml_item_work" do

    ignore_list.each do |attr|
      context "when name is ignored attribute name (#{attr})" do
        it "returns nil" do
          expect(Deepblue::MetadataHelper).not_to receive(:yaml_item)
          expect(Deepblue::MetadataHelper.yaml_item_work "out", "indent", {"#{attr}" => "concern"}, name: attr).to be_blank
        end
      end
    end

    context "when value is blank" do
      context "when ATTRIBUTE_NAMES_ALWAYS_INCLUDE_CC does NOT include name" do
        it "returns nil" do
          expect(Deepblue::MetadataHelper).not_to receive(:yaml_item)
          expect(Deepblue::MetadataHelper.yaml_item_work "out", "indent", {"curation" => ""}, name: "curation").to be_blank
        end
      end

      always_cc.each do |attr|
        context "when ATTRIBUTE_NAMES_ALWAYS_INCLUDE_CC includes name" do
          it "calls yaml_item" do
            expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":#{attr}:", "", escape: true)
            expect(Deepblue::MetadataHelper.yaml_item_work "out", "indent", {"#{attr}" => ""}, name: attr).to be_blank
          end
        end
      end
    end

    context "when value is not blank and attribute name is not ignored" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":curation:", "concern", escape: true)
      }
      it "calls yaml_item" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "indent", ":curation:", "concern", escape: true)
        expect(Deepblue::MetadataHelper.yaml_item_work "out", "indent", {"curation" => "concern"}, name: "curation")
      end
    end
  end


  describe "#self.yaml_line" do
    out_put = MockOutObject.new

    context "when comment parameter is true" do
      before{
        allow(Deepblue::MetadataHelper).to receive(:yaml_escape_value).with("value", comment: true, escape: false).and_return "_escape_value"
      }
      it "calls yaml_escape_value and puts a string comment" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_escape_value).with("value", comment: true, escape: false)
        expect(out_put).to receive(:puts).with "# indentlabelpost_escape_value"

        Deepblue::MetadataHelper.yaml_line(out_put, "indent", "label", "value", comment: true, label_postfix: "post")
      end
    end

    context "when comment parameter is false" do
      before{
        allow(Deepblue::MetadataHelper).to receive(:yaml_escape_value).with("value", comment: false, escape: false).and_return "_escape_value"
      }
      it "calls yaml_escape_value and puts a string" do
        expect(Deepblue::MetadataHelper).to receive(:yaml_escape_value).with("value", comment: false, escape: false)
        expect(out_put).to receive(:puts).with "indentlabelpost_escape_value"

        Deepblue::MetadataHelper.yaml_line(out_put, "indent", "label", "value", label_postfix: "post")
      end
    end
  end


  describe "#self.yaml_populate_collection" do
    context "when the out parameter is nil" do
      skip "Add a test for recursion"
    end

    context "when the out parameter is not nil" do
      work1 = OpenStruct.new(id: "123")
      work2 = OpenStruct.new(id: "567")
      coll = OpenStruct.new(member_objects: [work1, work2])

      before {
        allow(Deepblue::MetadataHelper).to receive(:log_provenance_migrate).with(curation_concern: coll, source: "DBDv2")
        allow(Deepblue::MetadataHelper).to receive(:yaml_header_populate).with("out", indent: "", target_filename: "target filename")
        allow(Deepblue::MetadataHelper).to receive(:yaml_body_collections).with("out", indent: "    ", curation_concern: coll, source: "DBDv2")
        allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "    ", ":works:")
        allow(Deepblue::MetadataHelper).to receive(:yaml_is_a_work?).with(curation_concern: work1, source: "DBDv2").and_return false
        allow(Deepblue::MetadataHelper).to receive(:yaml_is_a_work?).with(curation_concern: work2, source: "DBDv2").and_return true
        allow(Deepblue::MetadataHelper).to receive(:yaml_item).with("out", "      -", "", "567", escape: true)
        allow(Deepblue::MetadataHelper).to receive(:yaml_line).with("out", "    ", ":works_567:")
        allow(Deepblue::MetadataHelper).to receive(:log_provenance_migrate).with(curation_concern: work2, parent: coll, source: "DBDv2")
        allow(Deepblue::MetadataHelper).to receive(:yaml_body_works).with("out", indent: "      ", curation_concern: work2, source: "DBDv2")
      }

      context "when populate_works parameter is true" do
        context "when mode parameter is migrate" do
          before {
            allow(Deepblue::MetadataHelper).to receive(:yaml_header).with("out", indent: "  ", curation_concern: coll, header_type: ":collections:", source: "DBDv2",
                                                                          mode: "migrate")
            allow(Deepblue::MetadataHelper).to receive(:yaml_body_files).with("out", indent_base: "  ", indent: "      ", curation_concern: work2, mode: "migrate",
                                                                              source: "DBDv2", target_dirname: "target dirname")
          }

          it "calls yaml functions including log_provenance_migrate" do
            expect(Deepblue::MetadataHelper).to receive(:log_provenance_migrate).with(curation_concern: coll, source: "DBDv2")
            expect(Deepblue::MetadataHelper).to receive(:yaml_header).with("out", indent: "  ", curation_concern: coll, header_type: ":collections:", source: "DBDv2",
                                                                           mode: "migrate")
            expect(Deepblue::MetadataHelper).not_to receive(:log_provenance_migrate).with(curation_concern: work1, parent: coll, source: "DBDv2")
            expect(Deepblue::MetadataHelper).to receive(:log_provenance_migrate).with(curation_concern: work2, parent: coll, source: "DBDv2")
            expect(Deepblue::MetadataHelper).not_to receive(:yaml_body_files).with("out", indent_base: "  ", indent: "      ", curation_concern: work1, mode: "migrate",
                                                                                   source: "DBDv2", target_dirname: "target dirname")
            expect(Deepblue::MetadataHelper).to receive(:yaml_body_files).with("out", indent_base: "  ", indent: "      ", curation_concern: work2, mode: "migrate",
                                                                               source: "DBDv2", target_dirname: "target dirname")

            Deepblue::MetadataHelper.yaml_populate_collection(collection: coll, out: "out", mode: "migrate", target_filename: "target filename", target_dirname: "target dirname")
          end
        end

        context "when mode parameter is NOT migrate" do
          it "calls yaml functions excluding log_provenance_migrate" do
            expect(Deepblue::MetadataHelper).not_to receive(:log_provenance_migrate)
            expect(Deepblue::MetadataHelper).to receive(:yaml_header).with("out", indent: "  ", curation_concern: coll, header_type: ":collections:", source: "DBDv2",
                                                                           mode: "build")
            expect(Deepblue::MetadataHelper).not_to receive(:yaml_body_files).with("out", indent_base: "  ", indent: "      ", curation_concern: work1, mode: "build",
                                                                                   source: "DBDv2", target_dirname: "target dirname")
            expect(Deepblue::MetadataHelper).to receive(:yaml_body_files).with("out", indent_base: "  ", indent: "      ", curation_concern: work2, mode: "build",
                                                                               source: "DBDv2", target_dirname: "target dirname")

            Deepblue::MetadataHelper.yaml_populate_collection(collection: coll, out: "out", mode: "build", target_filename: "target filename", target_dirname: "target dirname")
          end
        end

        after {
          expect(Deepblue::MetadataHelper).to have_received(:yaml_body_collections).with("out", indent: "    ", curation_concern: coll, source: "DBDv2")
          expect(Deepblue::MetadataHelper).to have_received(:yaml_line).with("out", "    ", ":works:")
          expect(Deepblue::MetadataHelper).to have_received(:yaml_is_a_work?).with(curation_concern: work1, source: "DBDv2").twice
          expect(Deepblue::MetadataHelper).to have_received(:yaml_is_a_work?).with(curation_concern: work2, source: "DBDv2").twice
          expect(Deepblue::MetadataHelper).not_to have_received(:yaml_item).with("out", "indent", "", "123", escape: true)
          expect(Deepblue::MetadataHelper).to have_received(:yaml_item).with("out", "      -", "", "567", escape: true)
          expect(Deepblue::MetadataHelper).not_to have_received(:yaml_line).with("out", "    ", ":works_123:")
          expect(Deepblue::MetadataHelper).to have_received(:yaml_line).with("out", "    ", ":works_567:")
          expect(Deepblue::MetadataHelper).not_to have_received(:yaml_body_works).with("out", indent: "      ", curation_concern: work1, source: "DBDv2")
          expect(Deepblue::MetadataHelper).to have_received(:yaml_body_works).with("out", indent: "      ", curation_concern: work2, source: "DBDv2")
        }
      end

      context "when populate_works parameter is false" do
        before {
          allow(Deepblue::MetadataHelper).to receive(:yaml_header).with("out", indent: "  ", curation_concern: coll, header_type: ":collections:", source: "DBDv2",
                                                                        mode: "build")
        }

        it "calls yaml functions" do
          expect(Deepblue::MetadataHelper).to receive(:yaml_header).with("out", indent: "  ", curation_concern: coll, header_type: ":collections:", source: "DBDv2",
                                                                         mode: "build")
          expect(Deepblue::MetadataHelper).to receive(:yaml_body_collections).with("out", indent: "    ", curation_concern: coll, source: "DBDv2")

          expect(Deepblue::MetadataHelper).not_to receive(:yaml_line)
          expect(Deepblue::MetadataHelper).not_to receive(:yaml_is_a_work?)
          expect(Deepblue::MetadataHelper).not_to receive(:yaml_body_files)
          expect(Deepblue::MetadataHelper).not_to receive(:yaml_item)
          expect(Deepblue::MetadataHelper).not_to receive(:yaml_body_works)

          Deepblue::MetadataHelper.yaml_populate_collection(collection: coll, out: "out", populate_works: false, mode: "build", target_filename: "target filename")
        end
      end

      context "when member_objects parameter is empty" do
        collected = OpenStruct.new(member_objects: [])
        before {
          allow(Deepblue::MetadataHelper).to receive(:yaml_header).with("out", indent: "  ", curation_concern: collected, header_type: ":collections:", source: "DBDv2",
                                                                        mode: "build")
        }
        it "calls yaml functions" do
          expect(Deepblue::MetadataHelper).to receive(:yaml_header).with("out", indent: "  ", curation_concern: collected, header_type: ":collections:", source: "DBDv2",
                                                                         mode: "build")
          expect(Deepblue::MetadataHelper).to receive(:yaml_body_collections).with("out", indent: "    ", curation_concern: collected, source: "DBDv2")

          expect(Deepblue::MetadataHelper).not_to receive(:yaml_line)
          expect(Deepblue::MetadataHelper).not_to receive(:yaml_is_a_work?)
          expect(Deepblue::MetadataHelper).not_to receive(:yaml_body_files)
          expect(Deepblue::MetadataHelper).not_to receive(:yaml_item)
          expect(Deepblue::MetadataHelper).not_to receive(:yaml_body_works)

          Deepblue::MetadataHelper.yaml_populate_collection(collection: collected, out: "out", populate_works: true, mode: "build", target_filename: "target filename")
        end
      end

      after {
        expect(Deepblue::MetadataHelper).to have_received(:yaml_header_populate).with("out", indent: "", target_filename: "target filename")
      }
    end
  end


  describe "#self.yaml_populate_users" do   #906
    context "when out parameter is nil" do
      skip "Add a test for recursion"
    end

    context "when out parameter is not nil" do
      users = ["user1", "user2"]

      before {
        allow(Pathname).to receive(:new).with("/deepbluedata-prep/").and_return "deepbluedataprep"
        allow(Dir).to receive(:exist?).with("deepbluedataprep").and_return false
        allow(Dir).to receive(:mkdir).with("deepbluedataprep")
        allow(Deepblue::MetadataHelper).to receive(:yaml_header_populate).with("out", indent: "", rake_task: "umrdr:populate_users", target_filename: "target filename")
        allow(Deepblue::MetadataHelper).to receive(:yaml_header_users).with("out", indent: "  ", source: "DBDv2", mode: "migrate")
        allow(User).to receive(:all).and_return users
        allow(Deepblue::MetadataHelper).to receive(:yaml_body_users).with("out", indent_base: "  ", indent: "    ", users: users)
        allow(Deepblue::MetadataHelper).to receive(:yaml_body_user_body).with("out", indent_base: "  ", indent: "    ", user: "user1")
        allow(Deepblue::MetadataHelper).to receive(:yaml_body_user_body).with("out", indent_base: "  ", indent: "    ", user: "user2")
      }
      it "calls yaml functions and returns nil" do
        expect(Pathname).to receive(:new).with("/deepbluedata-prep/")
        expect(Dir).to receive(:exist?).with("deepbluedataprep")
        expect(Dir).to receive(:mkdir).with("deepbluedataprep")
        expect(Deepblue::MetadataHelper).to receive(:yaml_header_populate).with("out", indent: "", rake_task: "umrdr:populate_users", target_filename: "target filename")
        expect(Deepblue::MetadataHelper).to receive(:yaml_header_users).with("out", indent: "  ", source: "DBDv2", mode: "migrate")
        expect(Deepblue::MetadataHelper).to receive(:yaml_body_users).with("out", indent_base: "  ", indent: "    ", users: users)
        expect(Deepblue::MetadataHelper).to receive(:yaml_body_user_body).with("out", indent_base: "  ", indent: "    ", user: "user1")
        expect(Deepblue::MetadataHelper).to receive(:yaml_body_user_body).with("out", indent_base: "  ", indent: "    ", user: "user2")

        expect(Deepblue::MetadataHelper.yaml_populate_users(out: "out", target_filename: "target filename")).to be_blank
      end
    end
  end


  describe "#self.yaml_populate_work" do
    context "when out parameter is nil" do
      skip "Add a test for recursion"
    end

    context "when out parameter is not nil" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:yaml_header_populate).with("out", indent: "", target_filename: "target filename")
        allow(Deepblue::MetadataHelper).to receive(:yaml_header).with("out", indent: "  ", curation_concern: "concern", header_type: ":works:",
                                                                      source: "DBDv2", mode: "migrate")
        allow(Deepblue::MetadataHelper).to receive(:yaml_body_works).with("out", indent: "    ", curation_concern: "concern", source: "DBDv2")
        allow(Deepblue::MetadataHelper).to receive(:yaml_body_files).with("out", indent_base: "  ", indent: "    ", curation_concern: "concern",
                                                                          mode: "migrate", source: "DBDv2", target_dirname: "target dirname")
      }

      context "when mode is 'migrate'" do
        before {
          allow(Deepblue::MetadataHelper).to receive(:log_provenance_migrate).with(curation_concern: "concern", source: "DBDv2")
        }
        it "calls yaml functions excluding log_provenance_migrate and returns nil" do
          expect(Deepblue::MetadataHelper).to receive(:log_provenance_migrate).with(curation_concern: "concern", source: "DBDv2")
          expect(Deepblue::MetadataHelper).to receive(:yaml_header).with("out", indent: "  ", curation_concern: "concern", header_type: ":works:",
                                                                         source: "DBDv2", mode: "migrate")

          expect(Deepblue::MetadataHelper).to receive(:yaml_body_files).with("out", indent_base: "  ", indent: "    ", curation_concern: "concern",
                                                                             mode: "migrate", source: "DBDv2", target_dirname: "target dirname")

          expect(Deepblue::MetadataHelper.yaml_populate_work(curation_concern: "concern", out: "out", source: "DBDv2", mode: "migrate",
                                                             target_filename: "target filename", target_dirname: "target dirname")).to be_blank
        end
      end

      context "when mode is not 'migrate'" do
        it "calls yaml functions including log_provenance_migrate and returns nil" do
          expect(Deepblue::MetadataHelper).to receive(:yaml_header).with("out", indent: "  ", curation_concern: "concern", header_type: ":works:",
                                                                         source: "DBDv2", mode: "build")
          expect(Deepblue::MetadataHelper).to receive(:yaml_body_files).with("out", indent_base: "  ", indent: "    ", curation_concern: "concern",
                                                                             mode: "build", source: "DBDv2", target_dirname: "target dirname")

          expect(Deepblue::MetadataHelper.yaml_populate_work(curation_concern: "concern", out: "out", source: "DBDv2", mode: "build",
                                                             target_filename: "target filename", target_dirname: "target dirname")).to be_blank
        end
      end

      after {
        expect(Deepblue::MetadataHelper).to have_received(:yaml_header_populate).with("out", indent: "", target_filename: "target filename")
        expect(Deepblue::MetadataHelper).to have_received(:yaml_body_works).with("out", indent: "    ", curation_concern: "concern", source: "DBDv2")
      }
    end
  end


  describe "#self.yaml_targetdir" do
    context "when pathname_dir is not a Pathname object" do
      it "creates new pathname with parameters" do
        expect((Deepblue::MetadataHelper.yaml_targetdir pathname_dir: "pathname dir", id: "I-0001", prefix: "y_", task: "decimate").to_s).to eq "pathname dir/y_I-0001_decimate"
      end
    end

    context "when pathname_dir is a Pathname object" do
      it "adds parameters to pathname" do
        expect((Deepblue::MetadataHelper.yaml_targetdir pathname_dir: Pathname.new("to be"), id: "J-0002", prefix: "x_", task: "decade").to_s).to eq "to be/x_J-0002_decade"
      end
    end
  end


  describe "#self.yaml_targetdir_collection" do
    before {
      allow(Deepblue::MetadataHelper).to receive(:yaml_targetdir).with(pathname_dir: "pathname dir", id: "C-456", prefix: "c_", task: "populate")
    }
    it "calls yaml_target_dir with collection id and 'c_'" do
      expect(Deepblue::MetadataHelper).to receive(:yaml_targetdir).with(pathname_dir: "pathname dir", id: "C-456", prefix: "c_", task: "populate")
      Deepblue::MetadataHelper.yaml_targetdir_collection pathname_dir: "pathname dir", collection: OpenStruct.new(id: "C-456")
    end
  end


  describe "#self.yaml_targetdir_users" do
    before {
      allow(Deepblue::MetadataHelper).to receive(:yaml_targetdir).with(pathname_dir: "pathname dir", id: "", prefix: "users", task: "populate")
    }
    it "calls yaml_target_dir with 'users'" do
      expect(Deepblue::MetadataHelper).to receive(:yaml_targetdir).with(pathname_dir: "pathname dir", id: "", prefix:"users", task: "populate")
      Deepblue::MetadataHelper.yaml_targetdir_users pathname_dir: "pathname dir"
    end
  end


  describe "#self.yaml_targetdir_work" do
    before {
      allow(Deepblue::MetadataHelper).to receive(:yaml_targetdir).with(pathname_dir: "pathname dir", id: "W-123", prefix: "w_", task: "populate")
    }
    it "calls yaml_target_dir with work id and 'w_'" do
      expect(Deepblue::MetadataHelper).to receive(:yaml_targetdir).with(pathname_dir: "pathname dir", id: "W-123", prefix:"w_", task: "populate")
      Deepblue::MetadataHelper.yaml_targetdir_work pathname_dir: "pathname dir", work: OpenStruct.new(id: "W-123")
    end
  end


  describe "#self.yaml_user_email" do
    it "returns user email preceded by 'user_'" do
      expect(Deepblue::MetadataHelper.yaml_user_email OpenStruct.new(email: "email@example.com")).to eq "user_email@example.com"
    end
  end


  describe "self.yaml_work_export_files" do
    context "when Exception does not occur" do
      it "opens file and calls log_lines" do
        skip "Add a test"
      end
    end

    context "when Exception occurs" do
      before {
        allow(File).to receive(:open).with("target.export.log", "w").and_raise

      }
      it "puts string" do
        expect(Deepblue::MetadataHelper).to receive(:puts)

        Deepblue::MetadataHelper.yaml_work_export_files(work: "work", target_dirname: "target")
      end
    end
  end


  describe "#self.yaml_work_find" do
    context "when source is 'DBDv2'" do
      before {
        allow(DataSet).to receive(:find).with("curation concern").and_return "Data Set"
      }
      it "calls find on DataSet" do
        expect(Deepblue::MetadataHelper.yaml_work_find curation_concern: "curation concern", source: "DBDv2").to eq "Data Set"
      end
    end

    context "when source is NOT 'DBDv2'" do
      before {
        allow(GenericWork).to receive(:find).with("curation concern").and_return "Generic Work"
      }
      it "calls find on GenericWork" do
        expect(Deepblue::MetadataHelper.yaml_work_find curation_concern: "curation concern", source: "DBDv1").to eq "Generic Work"
      end
    end
  end
end
