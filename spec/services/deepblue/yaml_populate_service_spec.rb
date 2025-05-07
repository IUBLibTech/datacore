require 'rails_helper'

class MockOutput
  def puts text
    text
  end
end

class MockFileSet
  def original_name
    "original name"
  end

  def to_s
    "file name"
  end
end

RSpec.describe Deepblue::YamlPopulateService do
  subject { described_class.new }

  def expected_attribute_names_ignore
    %w[ access_control_id
        collection_type_gid
        file_size
        head
        part_of tail
        thumbnail_id ]
  end

  def expected_attribute_names_user_ignore
    %w[ current_sign_in_at
        current_sign_in_ip
        reset_password_token
        reset_password_sent_at ]
  end

  describe 'constants' do
    it do
      expect( Deepblue::YamlPopulateService::DEFAULT_CREATE_ZERO_LENGTH_FILES ).to eq true
      expect( Deepblue::YamlPopulateService::DEFAULT_OVERWRITE_EXPORT_FILES ).to eq true
    end
  end

  describe "#initialize" do
    it "sets instance variables" do
      instance_variable_get(:@create_zero_length_files) == true
      instance_variable_get(:@mode) == 'build'

      instance_variable_get(:@overwrite_export_files) == true
      instance_variable_get(:@source) == 'DBDv2'
      instance_variable_get(:@total_collections_exported) == 0
      instance_variable_get(:@total_file_sets_exported) == 0
      instance_variable_get(:@total_file_sets_size_exported) == 0
      instance_variable_get(:@total_works_exported) == 0
      instance_variable_get(:@total_users_exported) == 0
    end
  end

  describe "#yaml_body_collections" do
    context do
      concern = OpenStruct.new(id: "XYZ-1000", edit_users: "editors", collection_type: OpenStruct.new(machine_id: "HAL"),
                               work_ids: [101,202,303,404], total_file_size: 203, visibility: "public")

      before {
        allow(subject).to receive(:yaml_item).with "out", "concave", ":id:", "XYZ-1000"
        allow(subject).to receive(:source).and_return 'DBDv2'
        allow(subject).to receive(:yaml_item).with "out", "concave", ":collection_type:", "HAL", escape: true
        allow(subject).to receive(:yaml_item).with "out", "concave", ":edit_users:", "editors", escape: true
        allow(subject).to receive(:yaml_item_prior_identifier).with "out", "concave", curation_concern: concern
        allow(subject).to receive(:yaml_item_subject).with "out", "concave", curation_concern: concern

        allow(subject).to receive(:yaml_item).with "out", "concave", ":total_work_count:", 4
        allow(subject).to receive(:yaml_item).with "out", "concave", ":total_file_size:", 203

        allow(subject).to receive(:human_readable_size).with( 203 ).and_return "203 MB"
        allow(subject).to receive(:yaml_item).with "out", "concave", ":total_file_size_human_readable:", "203 MB", escape: true
        allow(subject).to receive(:yaml_item).with "out", "concave", ":visibility:", "public"

        allow(subject).to receive(:attribute_names_collection).and_return %w[ prior_identifier rights rights_license
          subject subject_discipline total_file_size visionary ]
        allow(subject).to receive(:yaml_item_collection).with "out", "concave", concern, name: "visionary"
      }

      it "calls functions with curation_concern values" do
        instance_variable_get(:@total_collections_exported) == 0

        expect(subject).to receive(:yaml_item).with "out", "concave", ":id:", "XYZ-1000"
        expect(subject).to receive(:yaml_item).with "out", "concave", ":collection_type:", "HAL", escape: true
        expect(subject).to receive(:yaml_item).with "out", "concave", ":edit_users:", "editors", escape: true
        expect(subject).to receive(:yaml_item_prior_identifier).with "out", "concave", curation_concern: concern
        expect(subject).to receive(:yaml_item_subject).with "out", "concave", curation_concern: concern

        expect(subject).to receive(:yaml_item).with "out", "concave", ":total_work_count:", 4
        expect(subject).to receive(:yaml_item).with "out", "concave", ":total_file_size:", 203
        expect(subject).to receive(:yaml_item).with "out", "concave", ":total_file_size_human_readable:", "203 MB", escape: true
        expect(subject).to receive(:yaml_item).with "out", "concave", ":visibility:", "public"

        expect(subject).to receive(:yaml_item_collection).with "out", "concave", concern, name: "visionary"

        subject.yaml_body_collections "out", indent: "concave", curation_concern: concern
      end
    end
  end

  describe "#yaml_file_size" do
    context "when file_set.file_size is blank and file_set.original_file is nil" do
      it "returns 0" do
        fileset = OpenStruct.new(file_size: "", original_file: nil)
        expect(subject.yaml_file_size fileset).to eq 0
      end
    end

    context "when file_set.file_size is blank and file_set.original_file is not nil" do
      it "returns file_set.original_file.size" do
        fileset = OpenStruct.new(file_size: "", original_file: OpenStruct.new(size: 80))
        expect(subject.yaml_file_size fileset).to eq 80
      end
    end

    context "when file_set.file_size is not blank" do
      it "returns file_set.file_size[0]" do
        fileset = OpenStruct.new(file_size: [9], original_file: OpenStruct.new(size: 80))
        expect(subject.yaml_file_size fileset).to eq 9
      end
    end
  end

  describe "#yaml_body_files" do
    before {
      allow(subject).to receive(:yaml_line).with("out", "indent", ":file_set_ids:")
    }

    context "curation_concern.file_sets.count is not positive" do
      it "calls yaml_line once" do
        expect(subject).to receive(:yaml_line).with("out", "indent", ":file_set_ids:")

        concern = OpenStruct.new(file_sets: [])
        subject.yaml_body_files "out", indent_base: "base ", indent: "indent", curation_concern: concern, target_dirname: "target"
      end
    end

    context "curation_concern.file_sets.count is positive" do
      fileset1 = OpenStruct.new(id: 1, title: ["Why we are No. 1"], edit_users: "admin users", mime_type: "text/plain", original_checksum: ["beauty","beast"],
                                original_file: OpenStruct.new(original_name: "When we were No. 2"), visibility: "public")
      concern = OpenStruct.new(file_sets: [fileset1])
      # TODO: put YamlPopulateService.rb edits in earlier commit
      #

      before {
        allow(subject).to receive(:yaml_item).with("out", "baseindent-", "", 1, escape: true)
        allow(subject).to receive(:mode).and_return "migrate"
        allow(subject).to receive(:log_provenance_migrate).with( curation_concern: fileset1, parent: concern )
        allow(subject).to receive(:yaml_file_set_id).with(fileset1).and_return "file id 1"
        allow(subject).to receive(:yaml_line).with("out", "indent", ":file id 1:")
        allow(subject).to receive(:yaml_item).with("out", "baseindent", ":id:", 1, escape: true)
        allow(subject).to receive(:yaml_item).with("out", "baseindent", ':title:', ["Why we are No. 1"], escape: true, single_value: true )
        allow(subject).to receive(:yaml_item_prior_identifier).with("out", "baseindent", curation_concern: fileset1 )
        allow(subject).to receive(:yaml_export_file_path).with(target_dirname: "target", file_set: fileset1 ).and_return "filepath"
        allow(subject).to receive(:yaml_item).with( "out", "baseindent", ':file_path:', "filepath", escape: true )
        allow(subject).to receive(:yaml_file_set_checksum).with( file_set: fileset1 ).and_return OpenStruct.new(algorithm: "11", value: "111*")
        allow(subject).to receive(:yaml_item).with( "out", "baseindent", ":checksum_algorithm:", "11", escape: true )
        allow(subject).to receive(:yaml_item).with( "out", "baseindent", ":checksum_value:", "111*", escape: true )
        allow(subject).to receive(:yaml_item).with( "out", "baseindent", ":edit_users:", "admin users", escape: true )
        allow(subject).to receive(:yaml_file_size).with( fileset1 ).and_return "76"
        allow(subject).to receive(:yaml_item).with( "out", "baseindent", ":file_size:", "76" )
        allow(subject).to receive(:human_readable_size).with( "76" ).and_return "76 kb"
        allow(subject).to receive(:yaml_item).with( "out", "baseindent", ":file_size_human_readable:", "76 kb", escape: true )
        allow(subject).to receive(:yaml_item).with( "out", "baseindent", ":mime_type:", "text/plain", escape: true )
        allow(subject).to receive(:yaml_item).with( "out", "baseindent", ":original_checksum:", "beauty" )
        allow(subject).to receive(:yaml_item).with( "out", "baseindent", ":original_name:", "When we were No. 2", escape: true )
        allow(subject).to receive(:yaml_item).with( "out", "baseindent", ":visibility:", "public" )

        allow(subject).to receive(:attribute_names_file_set).and_return %w[ title file_size irascible ]
        allow(subject).to receive(:yaml_item_file_set).with( "out", "baseindent", fileset1, name: "irascible" )
      }
      it "calls yaml_item for each file set in curation_concern" do
        expect(subject).to receive(:yaml_line).with("out", "indent", ":file_set_ids:")
        expect(subject).to receive(:yaml_item).with("out", "baseindent-", "", 1, escape: true)

        expect(subject).to receive(:log_provenance_migrate).with( curation_concern: fileset1, parent: concern )
        expect(subject).to receive(:yaml_line).with("out", "indent", ":file id 1:")
        expect(subject).to receive(:yaml_item).with("out", "baseindent", ":id:", 1, escape: true)
        expect(subject).to receive(:yaml_item).with("out", "baseindent", ':title:', ["Why we are No. 1"], escape: true, single_value: true )
        expect(subject).to receive(:yaml_item_prior_identifier).with("out", "baseindent", curation_concern: fileset1 )
        expect(subject).to receive(:yaml_export_file_path).with(target_dirname: "target", file_set: fileset1 )
        expect(subject).to receive(:yaml_item).with( "out", "baseindent", ':file_path:', "filepath", escape: true )
        expect(subject).to receive(:yaml_file_set_checksum).with( file_set: fileset1 )
        expect(subject).to receive(:yaml_item).with( "out", "baseindent", ":checksum_algorithm:", "11", escape: true )
        expect(subject).to receive(:yaml_item).with( "out", "baseindent", ":checksum_value:", "111*", escape: true )
        expect(subject).to receive(:yaml_item).with( "out", "baseindent", ":edit_users:", "admin users", escape: true )
        expect(subject).to receive(:yaml_item).with( "out", "baseindent", ":file_size:", "76" )
        expect(subject).to receive(:yaml_item).with( "out", "baseindent", ":file_size_human_readable:", "76 kb", escape: true )
        expect(subject).to receive(:yaml_item).with( "out", "baseindent", ":mime_type:", "text/plain", escape: true )
        expect(subject).to receive(:yaml_item).with( "out", "baseindent", ":original_checksum:", "beauty" )
        expect(subject).to receive(:yaml_item).with( "out", "baseindent", ":original_name:", "When we were No. 2", escape: true )
        expect(subject).to receive(:yaml_item).with( "out", "baseindent", ":visibility:", "public" )
        expect(subject).to receive(:yaml_item_file_set).with( "out", "baseindent", fileset1, name: "irascible" )

        subject.yaml_body_files "out", indent_base: "base", indent: "indent", curation_concern: concern, target_dirname: "target"

        subject.instance_variable_get(:@total_file_sets_exported) == 1
        subject.instance_variable_get(:@total_file_sets_size_exported) == 76
      end
    end
  end

  describe "#yaml_body_user_body" do
    user = OpenStruct.new(email: 'email z')
    before {
      allow(subject).to receive(:yaml_user_email).with(user).and_return "user_email_z"
      allow(subject).to receive(:yaml_line).with( "out", "indent", ":user_email_z:")
      allow(subject).to receive(:yaml_item).with( "out", "base indent", ":email:", "email z", escape: true)
      allow(subject).to receive(:attribute_names_user).and_return ["snail mail", "email"]
      allow(subject).to receive(:yaml_item_user).with("out", "base indent", user, name: "snail mail")
    }

    it "calls various functions" do
      expect(subject).to receive(:yaml_user_email).with(user).and_return "user_email_z"
      expect(subject).to receive(:yaml_line).with( "out", "indent", ":user_email_z:")
      expect(subject).to receive(:yaml_item).with( "out", "base indent", ":email:", "email z", escape: true)
      expect(subject).to receive(:attribute_names_user).and_return ["snail mail", "email"]
      expect(subject).to receive(:yaml_item_user).with("out", "base indent", user, name: "snail mail")

      subject.yaml_body_user_body "out", indent_base: "base ", indent: "indent", user: user

      subject.instance_variable_get(:@total_users_exported) == 1
    end
  end

  describe "#yaml_body_users" do
    before {
      allow(subject).to receive(:yaml_line).with( "out", "indent", ':user_emails:' )
    }

    context "has users" do
      before {
        allow(subject).to receive(:yaml_item).with( "out", "indent", ":total_user_count:", 3 )

        allow(subject).to receive(:yaml_item).with( "out", "baseindent-", "", "email1", escape: true )
        allow(subject).to receive(:yaml_item).with( "out", "baseindent-", "", "email2", escape: true )
        allow(subject).to receive(:yaml_item).with( "out", "baseindent-", "", "email3", escape: true )
      }
      it "calls yaml_item, yaml_line, and yaml_item again for each user" do
        users = [OpenStruct.new(email: 'email1'), OpenStruct.new(email: 'email2'), OpenStruct.new(email: 'email3')]
        subject.yaml_body_users "out", indent_base: "base", indent: "indent", users: users
      end
    end

    context "has no users" do
      before {
        allow(subject).to receive(:yaml_item).with( "out", "indent", ":total_user_count:", 0 )
      }
      it "calls yaml_item and yaml_line" do
        subject.yaml_body_users "out", indent_base: "base", indent: "indent", users: []
      end
    end
  end

  describe "#yaml_body_works" do
    context "when result of attribute_names_work is in skip array" do
      concern = OpenStruct.new(id: "id", admin_set_id: "admin set id", edit_users: "edit users", file_set_ids: ["id1", "id2"],
                               total_file_size: 2, visibility: "promotional")
      before {
        allow(subject).to receive(:human_readable_size).with(2).and_return "a goodly number of 2"
        allow(subject).to receive(:attribute_names_work).and_return %w[ prior_identifier rights rights_license subject subject_discipline total_file_size ]

        allow(subject).to receive(:yaml_item).with( "out", "indent", ":id:", "id")
        allow(subject).to receive(:yaml_item).with( "out", "indent", ":admin_set_id:", "admin set id", escape: true )
        allow(subject).to receive(:yaml_item).with( "out", "indent", ":edit_users:", "edit users", escape: true )

        allow(subject).to receive(:yaml_item_prior_identifier).with( "out", "indent", curation_concern: concern )
        allow(subject).to receive(:yaml_item_rights).with( "out", "indent", curation_concern: concern )
        allow(subject).to receive(:yaml_item_subject).with( "out", "indent", curation_concern: concern )

        allow(subject).to receive(:yaml_item).with( "out", "indent", ":total_file_count:", 2 )
        allow(subject).to receive(:yaml_item).with( "out", "indent", ":total_file_size:", 2 )
        allow(subject).to receive(:yaml_item).with( "out", "indent", ":total_file_size_human_readable:", "a goodly number of 2", escape: true )
        allow(subject).to receive(:yaml_item).with( "out", "indent", ":visibility:", "promotional")
      }
      it "skips yaml_item_work" do
        expect(subject).to receive(:yaml_item).with( "out", "indent", ":id:", "id")
        expect(subject).to receive(:yaml_item).with( "out", "indent", ":admin_set_id:", "admin set id", escape: true )
        expect(subject).to receive(:yaml_item).with( "out", "indent", ":edit_users:", "edit users", escape: true )

        expect(subject).to receive(:yaml_item_prior_identifier).with( "out", "indent", curation_concern: concern )
        expect(subject).to receive(:yaml_item_rights).with( "out", "indent", curation_concern: concern )
        expect(subject).to receive(:yaml_item_subject).with( "out", "indent", curation_concern: concern )

        expect(subject).to receive(:yaml_item).with( "out", "indent", ":total_file_count:", 2 )
        expect(subject).to receive(:yaml_item).with( "out", "indent", ":total_file_size:", 2 )
        expect(subject).to receive(:yaml_item).with( "out", "indent", ":total_file_size_human_readable:", "a goodly number of 2", escape: true )
        expect(subject).to receive(:yaml_item).with( "out", "indent", ":visibility:", "promotional")

        subject.yaml_body_works "out", indent: "indent", curation_concern: concern

        subject.instance_variable_get(:@total_works_exported) == 1
      end

      context "when result of attribute_names_work is not in skip array" do
        before {
          allow(subject).to receive(:attribute_names_work).and_return ["unidentifiable"]
          allow(subject).to receive(:yaml_item_work).with( "out", "indent", concern, name: "unidentifiable")
        }

        it "calls yaml_item_work" do
          expect(subject).to receive(:yaml_item_work).with( "out", "indent", concern, name: "unidentifiable")

          subject.yaml_body_works "out", indent: "indent", curation_concern: concern
        end
      end
    end
  end

  describe "#yaml_escape_value" do
    context "when value argument is nil" do
      it "returns blank" do
        expect(subject.yaml_escape_value nil).to be_blank
      end
    end

    context "when value argument is not nil and escape is false" do
      it "returns value argument" do
        expect(subject.yaml_escape_value "valuable").to eq "valuable"
      end
    end

    context "when value argument is not nil and comment and escape are true" do
      it "returns value argument" do
        expect(subject.yaml_escape_value "valuable", comment: true, escape: true).to eq "valuable"
      end
    end

    context "when value argument is not nil and escape is true and comment is false" do
      it "returns value argument as json" do
        expect(subject.yaml_escape_value "valuable", comment: false, escape: true).to eq "\"valuable\""
      end
    end

    context "when value argument is blank and escape is true and comment is false" do
      it "returns blank" do
        expect(subject.yaml_escape_value "", comment: false, escape: true).to be_blank
      end
    end
  end

  describe "#yaml_export_file_path" do
    file_set = OpenStruct.new(id: 'file set id')
    before {
      allow(subject).to receive(:yaml_export_file_name).with(file_set: file_set).and_return "export file name "
    }
    it "returns string" do
      expect(subject.yaml_export_file_path target_dirname: ["dirname1 ", "dirname2 "], file_set: file_set)
        .to eq "dirname1 file set id_export file name dirname2 "
    end
  end

  # NOTE: if/else in function doesn't make a difference
  describe "#yaml_export_file_name" do
    fileset_arg = OpenStruct.new(title: ["*file^", "set"])
    context "when file is nil" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:file_from_file_set).with(fileset_arg).and_return nil
      }
      it "returns filename appropriate string" do
        expect(subject.yaml_export_file_name file_set: fileset_arg).to eq "_file_"
      end
    end

    context "when file is not nil" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:file_from_file_set).with(fileset_arg).and_return MockFileSet.new
      }
      it "returns filename appropriate string" do
        expect(subject.yaml_export_file_name file_set: fileset_arg).to eq "_file_"
      end
    end
  end

  describe "#yaml_file_set_checksum" do
    context "when file present" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:file_from_file_set).with("fileset").and_return OpenStruct.new(checksum: 'check sum')
      }
      it "returns file.checksum" do
        expect(subject.yaml_file_set_checksum file_set: "fileset").to eq "check sum"
      end
    end

    context "when file not present" do
      before {
        allow(Deepblue::MetadataHelper).to receive(:file_from_file_set).with("fileset").and_return nil
      }
      it "returns nil" do
        expect(subject.yaml_file_set_checksum file_set: "fileset").to be_blank
      end
    end
  end

  pending "#yaml_filename"

  describe "#yaml_filename_collection" do
    before {
      allow(subject).to receive(:yaml_filename).with pathname_dir: "pathname", id: "ID", prefix: 'c_', task: "populate"
    }
    it "calls yaml_filename" do
      expect(subject).to receive(:yaml_filename).with pathname_dir: "pathname", id: "ID", prefix: 'c_', task: "populate"

      subject.yaml_filename_collection pathname_dir: "pathname", collection: OpenStruct.new(id: 'ID'), task: 'populate'
    end
  end

  describe "#yaml_filename_users" do
    before {
      allow(subject).to receive(:yaml_filename).with pathname_dir: "pathname", id: "", prefix: 'users', task: "populate"
    }
    it "calls yaml_filename" do
      expect(subject).to receive(:yaml_filename).with pathname_dir: "pathname", id: "", prefix: 'users', task: "populate"

      subject.yaml_filename_users pathname_dir: "pathname", task: 'populate'
    end
  end

  describe "#yaml_filename_work" do
    before {
      allow(subject).to receive(:yaml_filename).with pathname_dir: "pathname", id: "identify", prefix: 'w_', task: "populate"
    }
    it "calls yaml_filename" do
      expect(subject).to receive(:yaml_filename).with pathname_dir: "pathname", id: "identify", prefix: 'w_', task: "populate"

      subject.yaml_filename_work pathname_dir: "pathname", work: OpenStruct.new(id: 'identify'), task: 'populate'
    end
  end

  describe "#yaml_header" do
    before {
      allow(DateTime).to receive(:now).and_return DateTime.new(2025, 6, 6, 9, 10, 35)
      allow(subject).to receive(:source).and_return "DBDv3"
      allow(subject).to receive(:mode).and_return "modular"

      allow(subject).to receive(:yaml_line).with "out", "indent", ':email:', "depositor"
      allow(subject).to receive(:yaml_line).with "out", "indent", ':visibility:', "visible"
      allow(subject).to receive(:yaml_line).with "out", "indent", ':ingester:', ''
      allow(subject).to receive(:yaml_line).with "out", "indent", ':source:', "DBDv3"
      allow(subject).to receive(:yaml_line).with "out", "indent", ':export_timestamp:', '2025-06-06T09:10:35+00:00'
      allow(subject).to receive(:yaml_line).with "out", "indent", ':mode:', "modular"
      allow(subject).to receive(:yaml_line).with "out", "indent", ':id:', "identifier"
      allow(subject).to receive(:yaml_line).with "out", "indent", "header"
    }
    it "calls yaml_line multiple times with different arguments" do
      expect(subject).to receive(:yaml_line).with "out", "indent", ':email:', "depositor"
      expect(subject).to receive(:yaml_line).with "out", "indent", ':visibility:', "visible"
      expect(subject).to receive(:yaml_line).with "out", "indent", ':ingester:', ''
      expect(subject).to receive(:yaml_line).with "out", "indent", ':source:', "DBDv3"
      expect(subject).to receive(:yaml_line).with "out", "indent", ':export_timestamp:', '2025-06-06T09:10:35+00:00'
      expect(subject).to receive(:yaml_line).with "out", "indent", ':mode:', "modular"
      expect(subject).to receive(:yaml_line).with "out", "indent", ':id:', "identifier"
      expect(subject).to receive(:yaml_line).with "out", "indent", "header"

      concern = OpenStruct.new(depositor: 'depositor', visibility: "visible", id: "identifier")
      subject.yaml_header "out", indent: "indent", curation_concern: concern, header_type: "header"
    end
  end

  describe "#yaml_header_populate" do
    before {
      allow(subject).to receive(:yaml_line).with "out", "indent", 'target', comment: true
      allow(subject).to receive(:yaml_line).with "out", "indent", "bundle exec rake umrdr:populate[target]", comment: true
      allow(subject).to receive(:yaml_line).with "out", "indent", "---"
      allow(subject).to receive(:yaml_line).with "out", "indent", ":user:"
    }
    it "calls yaml_line multiple times with different arguments" do
      expect(subject).to receive(:yaml_line).with "out", "indent", 'target', comment: true
      expect(subject).to receive(:yaml_line).with "out", "indent", "bundle exec rake umrdr:populate[target]", comment: true
      expect(subject).to receive(:yaml_line).with "out", "indent", "---"
      expect(subject).to receive(:yaml_line).with "out", "indent", ":user:"

      subject.yaml_header_populate "out", indent: "indent", target_filename: "target"
    end
  end

  describe "#yaml_header_users" do
    before {
      allow(subject).to receive(:source).and_return "DBDv3"
      allow(subject).to receive(:mode).and_return "modular"
      allow(DateTime).to receive(:now).and_return DateTime.new(2025, 6, 6, 0, 0, 30)

      allow(subject).to receive(:yaml_line).with "out", "indent", ':ingester:', ''
      allow(subject).to receive(:yaml_line).with "out", "indent", ':source:', "DBDv3"
      allow(subject).to receive(:yaml_line).with "out", "indent", ':export_timestamp:', '30'
      allow(subject).to receive(:yaml_line).with "out", "indent", ':mode:', 'modular'
      allow(subject).to receive(:yaml_line).with "out", "indent", ':users:'
    }
    it "calls yaml_line multiple times with different arguments" do
      expect(subject).to receive(:yaml_line).with "out", "indent", ':ingester:', ''
      expect(subject).to receive(:yaml_line).with "out", "indent", ':source:', "DBDv3"
      expect(subject).to receive(:yaml_line).with "out", "indent", ':export_timestamp:', '2025-06-06T00:00:30+00:00'
      expect(subject).to receive(:yaml_line).with "out", "indent", ':mode:', 'modular'
      expect(subject).to receive(:yaml_line).with "out", "indent", ':users:'

      subject.yaml_header_users "out", indent: "indent"
    end
  end

  describe "#yaml_is_a_work?" do
    context "when source is 'DBDv2'" do
      before {
        allow(subject).to receive(:source).and_return "DBDv2"
      }

      it "returns true when curation_concern is a DataSet" do
        expect(subject.yaml_is_a_work? curation_concern: DataSet.new).to eq true
      end

      it "returns false when curation_concern is not a DataSet" do
        expect(subject.yaml_is_a_work? curation_concern: GenericWork.new).to eq false
      end
    end

    context "when source is not 'DBDv2'" do
      before {
        allow(subject).to receive(:source).and_return "DBDv1"
      }

      it "returns true when curation_concern is a GenericWork" do
        expect(subject.yaml_is_a_work? curation_concern: GenericWork.new).to eq true
      end

      it "returns false when curation_concern is not a GenericWork" do
        expect(subject.yaml_is_a_work? curation_concern: DataSet.new).to eq false
      end
    end
  end


  pending "#yaml_item"

  describe "#yaml_item_collection" do
    context "when ATTRIBUTE_NAMES_IGNORE includes name argument" do
      it "returns blank" do
        expected_attribute_names_ignore.each do |attr_name|
          expect(subject.yaml_item_collection "out", "indent", "curation concern", name: attr_name).to be_blank
        end
      end
    end

    context "when ATTRIBUTE_NAMES_IGNORE doesn't include name argument" do
      it "calls yaml_item" do
        expect(subject).to receive(:yaml_item).with "out", "indent", ":banana:", "yellow", escape: true
        subject.yaml_item_collection "out", "indent", { "banana" => "yellow"}, name: "banana"
      end
    end

    context "when value blank and name not in ATTRIBUTE_NAMES_ALWAYS_INCLUDE_CC" do
      it "returns blank" do
        expect(subject.yaml_item_collection "out", "indent", { "banana" => "" }, name: "banana").to be_blank
      end
    end
  end

  describe "#yaml_item_file_set" do
    context "when ATTRIBUTE_NAMES_IGNORE includes name argument" do
      it "returns blank" do
        expected_attribute_names_ignore.each do |attr_name|
          expect(subject.yaml_item_file_set "out", "indent", "file set", name: attr_name).to be_blank
        end
      end
    end

    context "when ATTRIBUTE_NAMES_IGNORE doesn't include name argument" do
      it "calls yaml_item" do
        expect(subject).to receive(:yaml_item).with "out", "indent", ":apple:", "red", escape: true
        subject.yaml_item_file_set "out", "indent", { "apple" => "red"}, name: "apple"
      end
    end

    context "when value blank and name not in ATTRIBUTE_NAMES_ALWAYS_INCLUDE_FILE_SET" do
      it "returns blank" do
        expect(subject.yaml_item_file_set "out", "indent", { "apple" => "" }, name: "apple").to be_blank
      end
    end
  end

  describe "#yaml_item_prior_identifier" do
    context "when source is 'DBDv1'" do
      before {
        allow(subject).to receive(:source).and_return "DBDv1"
      }
      it "calls yaml_item without curation_concern.prior_identifier" do
        expect(subject).to receive(:yaml_item).with "out", "indent", ":prior_identifier:", ""
        subject.yaml_item_prior_identifier "out", "indent", curation_concern: "concern"
      end
    end

    context "when source is not 'DBDv1'" do
      before {
        allow(subject).to receive(:source).and_return "DBDv2"
      }
      it "calls yaml_item with curation_concern.prior_identifier" do
        expect(subject).to receive(:yaml_item).with "out", "indent", ":prior_identifier:", "concern identifier"
        subject.yaml_item_prior_identifier "out", "indent", curation_concern: OpenStruct.new(prior_identifier: 'concern identifier')
      end
    end
  end

  describe "#yaml_item_referenced_by" do
    context "when source is 'DBDv1'" do
      before {
        allow(subject).to receive(:source).and_return "DBDv1"
      }
      it "calls yaml_item with subject" do
        expect(subject).to receive(:yaml_item).with "out", "indent", ":isReferencedBy:", "reference concern", escape: true
        subject.yaml_item_referenced_by "out", "indent", curation_concern: OpenStruct.new(isReferencedBy: 'reference concern')
      end
    end

    context "when source is not 'DBDv1'" do
      before {
        allow(subject).to receive(:source).and_return "DBDv2"
      }
      it "calls yaml_item with subject_discipline" do
        expect(subject).to receive(:yaml_item).with "out", "indent", ":referenced_by:", "referral concern", escape: true
        subject.yaml_item_referenced_by "out", "indent", curation_concern: OpenStruct.new(referenced_by: 'referral concern')
      end
    end
  end

  describe "#yaml_item_rights" do
    context "when source is 'DBDv1'" do
      before {
        allow(subject).to receive(:source).and_return "DBDv1"
      }
      it "calls yaml_item with subject" do
        expect(subject).to receive(:yaml_item).with "out", "indent", ":rights:", "rights concern", escape: true
        subject.yaml_item_rights "out", "indent", curation_concern: OpenStruct.new(rights: 'rights concern')
      end
    end

    context "when source is not 'DBDv1'" do
      before {
        allow(subject).to receive(:source).and_return "DBDv2"
      }
      it "calls yaml_item with subject_discipline" do
        expect(subject).to receive(:yaml_item).with "out", "indent", ":rights_license:", "license", escape: true
        subject.yaml_item_rights "out", "indent", curation_concern: OpenStruct.new(rights_license: 'license')
      end
    end
  end

  describe "#yaml_item_subject" do
    context "when source is 'DBDv1'" do
      before {
        allow(subject).to receive(:source).and_return "DBDv1"
      }
      it "calls yaml_item with subject" do
        expect(subject).to receive(:yaml_item).with "out", "indent", ":subject:", "subject concern", escape: true
        subject.yaml_item_subject "out", "indent", curation_concern: OpenStruct.new(subject: 'subject concern')
      end
    end

    context "when source is not 'DBDv1'" do
      before {
        allow(subject).to receive(:source).and_return "DBDv2"
      }
      it "calls yaml_item with subject_discipline" do
        expect(subject).to receive(:yaml_item).with "out", "indent", ":subject_discipline:", "discipline", escape: true
        subject.yaml_item_subject "out", "indent", curation_concern: OpenStruct.new(subject_discipline: 'discipline')
      end
    end
  end

  describe "#yaml_item_user" do
    context "when ATTRIBUTE_NAMES_USER_IGNORE includes name argument" do
      it "returns blank" do
        expected_attribute_names_user_ignore.each do |attr_name|
          expect(subject.yaml_item_user "out", "indent", "user", name: attr_name).to be_blank
        end
      end
    end

    context "when ATTRIBUTE_NAMES_USER_IGNORE doesn't include name argument" do
      it "calls yaml_item" do
        expect(subject).to receive(:yaml_item).with "out", "indent", ":frosting:", "cream cheese", escape: true
        subject.yaml_item_user "out", "indent", { "frosting" => "cream cheese"}, name: "frosting"
      end
    end

    context "when value blank and name not in ATTRIBUTE_NAMES_ALWAYS_INCLUDE_USER" do
      it "returns blank" do
        expect(subject.yaml_item_user "out", "indent", { "frosting" => "" }, name: "frosting").to be_blank
      end
    end
  end

  describe "#yaml_item_work" do
    context "when ATTRIBUTE_NAMES_IGNORE includes name argument" do
      it "returns blank" do
        expected_attribute_names_ignore.each do |attr_name|
          expect(subject.yaml_item_work "out", "indent", "curation concern", name: attr_name).to be_blank
        end
      end
    end

    context "when ATTRIBUTE_NAMES_IGNORE doesn't include name argument" do
      it "calls yaml_item" do
        expect(subject).to receive(:yaml_item).with "out", "indent", ":cake:", "chocolate", escape: true
        subject.yaml_item_work "out", "indent", { "cake" => "chocolate" }, name: "cake"
      end
    end

    context "when value blank and name not in ATTRIBUTE_NAMES_ALWAYS_INCLUDE_CC" do
      it "returns blank" do
        expect(subject.yaml_item_work "out", "indent", { "cake" => "" }, name: "cake").to be_blank
      end
    end
  end

  describe "#yaml_line" do
    context "when comment is false" do
      before {
        allow(subject).to receive(:yaml_escape_value).with('', comment: false, escape: false).and_return "yaml escape value"
      }
      it "outputs text" do
        out_object = MockOutput.new
        expect(out_object).to receive(:puts).with("indent label yaml escape value")
        subject.yaml_line out_object, "indent ", "label", comment: false
      end
    end

    context "when comment is true" do
      before {
        allow(subject).to receive(:yaml_escape_value).with('', comment: true, escape: false).and_return "comment"
      }
      it "outputs text with preceding hashtag" do
        out_object = MockOutput.new
        expect(out_object).to receive(:puts).with("# indent label comment")
        subject.yaml_line out_object, "indent ", "label", comment: true
      end
    end
  end

  describe "#yaml_populate_collection" do
    object1 = OpenStruct.new(id: 111)
    object2 = OpenStruct.new(id: 222)
    concern_objects = OpenStruct.new(member_objects: [object1, object2])
    concern_empty = OpenStruct.new(member_objects: [])

    context "when out argument is not nil" do
      before {
        allow(subject).to receive(:log_provenance_migrate).with( curation_concern: concern_objects )
        allow(subject).to receive(:yaml_header_populate).with( "outboard", indent: "", target_filename: "filename" )
        allow(subject).to receive(:yaml_header).with( "outboard", indent: "  ",  curation_concern: concern_objects,
                                                      header_type: ':collections:')
        allow(subject).to receive(:yaml_body_collections).with( "outboard", indent: "   ",  curation_concern: concern_objects)
      }

      context "when populate_works is false" do
        before {
          allow(subject).to receive(:mode).and_return "work"
        }
        it "calls various methods" do
          expect(subject).not_to receive(:log_provenance_migrate)
          expect(subject).to receive(:yaml_header_populate).with( "outboard", indent: "", target_filename: "filename" )
          expect(subject).to receive(:yaml_header).with( "outboard", indent: "  ", curation_concern: concern_objects,
                                                        header_type: ':collections:')
          expect(subject).to receive(:yaml_body_collections).with( "outboard", indent: "    ", curation_concern: concern_objects)

          subject.yaml_populate_collection collection: concern_objects, out: "outboard", populate_works: false, target_filename: "filename"
        end
      end

      context "when populate_works is true and collection.member_objects has no values" do
        before {
          allow(subject).to receive(:mode).and_return "work"
          allow(subject).to receive(:log_provenance_migrate).with( curation_concern: concern_empty )
          allow(subject).to receive(:yaml_header).with( "outboard", indent: "  ",  curation_concern: concern_empty,
                                                        header_type: ':collections:')
          allow(subject).to receive(:yaml_body_collections).with( "outboard", indent: "    ",  curation_concern: concern_empty)
        }
        it "calls various methods" do
          expect(subject).not_to receive(:log_provenance_migrate)
          expect(subject).to receive(:yaml_header_populate).with( "outboard", indent: "", target_filename: "filename" )
          expect(subject).to receive(:yaml_header).with( "outboard", indent: "  ", curation_concern: concern_empty,
                                                         header_type: ':collections:')
          expect(subject).to receive(:yaml_body_collections).with( "outboard", indent: "    ",  curation_concern: concern_empty)

          subject.yaml_populate_collection collection: concern_empty, out: "outboard", populate_works: true, target_filename: "filename"
        end
      end

      context "when populate_works is true and collection.member_objects has value(s) and mode is MetadataHelper::MODE_MIGRATE" do
        before {
          allow(subject).to receive(:mode).and_return "migrate"

          allow(subject).to receive(:yaml_line).with( "outboard", "      ", ':works:' )
          allow(subject).to receive(:yaml_is_a_work?).with( curation_concern: object1 ).and_return true
          allow(subject).to receive(:yaml_is_a_work?).with( curation_concern: object2 ).and_return false
          allow(subject).to receive(:yaml_item).with( "outboard", "      -", '', 111, escape: true )
          allow(subject).to receive(:yaml_line).with( "outboard", "    ", ":works_111:" )
          allow(subject).to receive(:log_provenance_migrate).with( curation_concern: object1, parent: concern_objects )
          allow(subject).to receive(:yaml_body_works).with( "outboard", indent: "      ", curation_concern: object1 )
          allow(subject).to receive(:yaml_body_files).with( "outboard", indent_base: "  ", indent: "    ",
                                    curation_concern: object1, target_dirname:  "directoryname")
        }
        it "calls various methods" do
          expect(subject).to receive(:log_provenance_migrate).with( curation_concern: concern_objects )
          expect(subject).to receive(:yaml_header_populate).with( "outboard", indent: "", target_filename: "filename" )
          expect(subject).to receive(:yaml_header).with( "outboard", indent: "  ",  curation_concern: concern_objects,
                                                         header_type: ':collections:')
          expect(subject).to receive(:yaml_body_collections).with( "outboard", indent: "    ", curation_concern: concern_objects)
          # expect(subject).to receive(:yaml_line).with( "outboard", "      ", ':works:' )

          expect(subject).to receive(:yaml_item).with( "outboard", "      -", '', 111, escape: true )
          expect(subject).not_to receive(:yaml_item).with( "outboard", "      -", '', 222, escape: true )
          expect(subject).to receive(:yaml_line).with( "outboard", "    ", ":works_111:" )
          expect(subject).not_to receive(:yaml_line).with( "outboard", "    ", ":works_222:" )
          expect(subject).to receive(:log_provenance_migrate).with( curation_concern: object1, parent: concern_objects )
          expect(subject).not_to receive(:log_provenance_migrate).with( curation_concern: object2, parent: concern_objects )

          expect(subject).to receive(:yaml_body_works).with( "outboard", indent: "      ", curation_concern: object1 )
          # expect(subject).to receive(:yaml_body_files).with( "outboard", indent_base: "  ", indent: "    ",
          #                                                    curation_concern: object1, target_dirname: "directoryname")
          expect(subject).not_to receive(:yaml_body_works).with( "outboard", indent: "      ", curation_concern: object2 )
          expect(subject).not_to receive(:yaml_body_files).with( "outboard", indent_base: "  ", indent: "    ",
                                                            curation_concern: object2, target_dirname:  "directoryname")

          subject.yaml_populate_collection collection: concern_objects, out: "outboard", populate_works: true, target_filename: "filename",
                                           target_dirname: "directoryname"
        end
      end
    end

    context "when out argument is nil" do
      skip "Add tests"
    end
  end

  describe "#yaml_populate_stats" do
    before {
      allow(subject).to receive(:human_readable_size).with(0).and_return 100
    }
    it "returns Hash" do
      expected_hash = {:total_collections_exported => 0,
                       :total_works_exported => 0,
                       :total_file_sets_exported => 0,
                       :total_file_sets_size_exported => 0,
                       :total_file_sets_size_readable_exported => 100,
                       :total_users_exported => 0 }
      expect(subject.yaml_populate_stats).to eq expected_hash
    end
  end

  describe "#yaml_populate_users" do
    context "when out argument is not nil" do
      before {
        allow(Dir).to receive(:mkdir).with(anything)
        allow(subject).to receive(:yaml_header_populate).with( "outside", indent: "", rake_task: 'umrdr:populate_users', target_filename: "filename" )
        allow(subject).to receive(:yaml_header_users).with( "outside", indent: "  ")
        allow(User).to receive(:all).and_return ["user1"]
        allow(subject).to receive(:yaml_body_users).with( "outside",
                                                          indent_base: "  ",
                                                          indent: "    ",
                                                          users: ["user1"])
        allow(subject).to receive(:yaml_body_user_body).with( "outside",
                                                              indent_base: "  ",
                                                              indent: "    ",
                                                              user:"user1")
      }
      it "returns nil" do
        expect(subject).to receive(:yaml_header_populate).with( "outside", indent: "", rake_task: 'umrdr:populate_users', target_filename: "filename" )
        expect(subject).to receive(:yaml_header_users).with( "outside", indent: "  ")
        expect(subject).to receive(:yaml_body_users).with( "outside",
                                                          indent_base: "  ",
                                                          indent: "    ",
                                                          users: ["user1"])
        expect(subject).to receive(:yaml_body_user_body).with( "outside",
                                                              indent_base: "  ",
                                                              indent: "    ",
                                                              user:"user1")

        expect(subject.yaml_populate_users out: "outside", target_filename: "filename").to be_blank
      end
    end

    context "when out argument is nil" do
      skip "Add tests"
    end
  end

  describe "#yaml_populate_work" do
    context "when out argument is not nil" do
      before {
        allow(subject).to receive(:log_provenance_migrate).with( curation_concern: "concern" )
        allow(subject).to receive(:yaml_header_populate).with( "I'm going out", indent: "", target_filename: "filename" )
        allow(subject).to receive(:yaml_header).with( "I'm going out",
                     indent: "  ",
                     curation_concern: "concern",
                     header_type: ':works:' )
        allow(subject).to receive(:yaml_body_works).with( "I'm going out", indent: "    ", curation_concern: "concern" )
        allow(subject).to receive(:yaml_body_files).with( "I'm going out",
                         indent_base: "  ",
                         indent: "    ",
                         curation_concern: "concern",
                         target_dirname: "dirname" )
      }
      context "when mode is MetadataHelper::MODE_MIGRATE" do
        before {
          allow(subject).to receive(:mode).and_return "migrate"
        }
        it 'calls log_provenance_migrate, other functions and returns nil' do
          expect(subject).to receive(:log_provenance_migrate).with( curation_concern: "concern" )
          expect(subject).to receive(:yaml_header_populate).with( "I'm going out", indent: "", target_filename: "filename" )
          expect(subject).to receive(:yaml_header).with( "I'm going out",
                                                        indent: "  ",
                                                        curation_concern: "concern",
                                                        header_type: ':works:' )
          expect(subject).to receive(:yaml_body_works).with( "I'm going out", indent: "    ", curation_concern: "concern" )
          expect(subject).to receive(:yaml_body_files).with( "I'm going out",
                                                            indent_base: "  ",
                                                            indent: "    ",
                                                            curation_concern: "concern",
                                                            target_dirname: "dirname" )

          expect(subject.yaml_populate_work(curation_concern: "concern", out: "I'm going out", target_filename: "filename",
                                            target_dirname: "dirname")).to be_blank
        end
      end
      context "when mode is not MetadataHelper::MODE_MIGRATE" do
        before {
          allow(subject).to receive(:mode).and_return "work"
        }
        it 'does not call log_provenance_migrate, calls various functions and returns nil' do
          expect(subject).not_to receive(:log_provenance_migrate)
          expect(subject).to receive(:yaml_header_populate).with( "I'm going out", indent: "", target_filename: "filename" )
          expect(subject).to receive(:yaml_header).with( "I'm going out",
                                                         indent: "  ",
                                                         curation_concern: "concern",
                                                         header_type: ':works:' )
          expect(subject).to receive(:yaml_body_works).with( "I'm going out", indent: "    ", curation_concern: "concern" )
          expect(subject).to receive(:yaml_body_files).with( "I'm going out",
                                                             indent_base: "  ",
                                                             indent: "    ",
                                                             curation_concern: "concern",
                                                             target_dirname: "dirname" )

          expect(subject.yaml_populate_work(curation_concern: "concern", out: "I'm going out", target_filename: "filename",
                                            target_dirname: "dirname")).to be_blank
        end
      end
    end

    context "when out argument is nil" do
      skip "Add tests"
    end
  end

  describe "#yaml_targetdir" do
    context "when called with an object that is not a Pathname" do
      it "creates a new Pathname and returns text" do
        skip "Add a test"
      end
    end

    context "when called with a Pathname" do
      it "returns text" do
        skip "Add a test"
      end
    end
  end

  describe "#yaml_targetdir_collection" do
    before {
      allow(subject).to receive(:yaml_targetdir).with(pathname_dir: "pathname dir", id: "collection id", prefix: "c_", task: "populate")
                                                .and_return "population"
    }
    it "calls yaml_targetdir" do
      expect(subject.yaml_targetdir_collection pathname_dir: "pathname dir", collection: OpenStruct.new(id: 'collection id')).to eq "population"
    end
  end

  describe "#yaml_targetdir_users" do
    before {
      allow(subject).to receive(:yaml_targetdir).with(pathname_dir: "pathname dir", id: "", prefix: "users", task: "populate")
                                                .and_return "population"
    }
    it "calls yaml_targetdir" do
      expect(subject.yaml_targetdir_users pathname_dir: "pathname dir").to eq "population"
    end
  end

  describe "#yaml_targetdir_work" do
    before {
      allow(subject).to receive(:yaml_targetdir).with(pathname_dir: "pathname dir", id: "work id", prefix: "w_", task: "populate")
                                                .and_return "yaml targetdir"
    }
    it "calls yaml_targetdir" do
      expect(subject.yaml_targetdir_work pathname_dir: "pathname dir", work: OpenStruct.new(id: 'work id')).to eq "yaml targetdir"
    end
  end

  describe "#yaml_user_email" do
    it "returns string" do
      expect(subject.yaml_user_email OpenStruct.new(email: "bpotter@example.com")).to eq "user_bpotter@example.com"
    end
  end

  describe "#yaml_work_export_files" do
    exception = StandardError.new("error message")
    exception.set_backtrace("backtrace")

    context "when error occurs" do
      before {
        allow(subject).to receive(:open).with("dirname", "w").and_raise( exception )
        allow(subject).to receive(:puts).with "StandardError: error message at backtrace"
      }
      it "catch error" do
        expect(subject).to receive(:open).with("dirname", "w").and_raise( exception )
        expect(subject).to receive(:puts).with "StandardError: error message at backtrace"

        subject.yaml_work_export_files(work: "work", target_dirname: ["dirname"], log_filename: nil)
      end
    end

    context "when error does not occur" do
      skip "Add tests"
    end
  end

  describe "#yaml_work_find" do
    context "when source is 'DBDv2'" do
      before {
        allow(DataSet).to receive(:find).and_return "DataSet find"
      }
      it "calls DataSet.find" do
        expect(subject.yaml_work_find curation_concern: "concern").to eq "DataSet find"
      end
    end

    context "when source is not 'DBDv2'" do
      before {
        allow(subject).to receive(:source).and_return "DBDv1"
        allow(GenericWork).to receive(:find).and_return "GenericWork find"
      }
      it "calls GenericWork.find" do
        expect(subject.yaml_work_find curation_concern: "concern").to eq "GenericWork find"
      end
    end
  end

  pending "#self.init_attribute_names_always_include_cc"
end
