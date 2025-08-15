require 'rails_helper'

class CharacterMock
  include Hyrax::CharacterizationBehavior

  def solr_document
    attributes = {}
    SolrDocument.new(attributes)
  end
end

RSpec.describe Hyrax::CharacterizationBehavior do

  subject { CharacterMock.new }

  def char_terms
    [
      :byte_order,
      :compression,
      :height,
      :width,
      :height,
      :color_space,
      :profile_name,
      :profile_version,
      :orientation,
      :color_map,
      :image_producer,
      :capture_device,
      :scanning_software,
      :gps_timestamp,
      :latitude,
      :longitude,
      :file_format,
      :file_title,
      :page_count,
      :duration,
      :sample_rate,
      :format_label,
      :file_size_human_readable,
      :filename,
      :well_formed,
      :last_modified,
      :original_checksum,
      :mime_type
    ]
  end
  def char_terms_admin_only
    %i[
        virus_scan_service
        virus_scan_status
        virus_scan_status_date
      ]
  end

  describe "#characterization_terms" do
    it do
      expect( CharacterMock.characterization_terms).to eq char_terms
    end
  end

  describe "#characterization_terms_admin_only" do
    it do
      expect( CharacterMock.characterization_terms_admin_only).to eq char_terms_admin_only
    end
  end


  pending "#characterized?"


  describe "#characterization_metadata" do
    context "when instance variable is set" do
      before {
        subject.instance_variable_set(:@characterization_metadata, "characterization metadata")
      }
      it "returns value of instance variable" do
        expect(subject.characterization_metadata).to eq "characterization metadata"
      end
    end

    context "when instance variable is not set" do
      before {
        allow(subject).to receive(:build_characterization_metadata).and_return "built"
      }
      it "returns value of instance variable" do
        expect(subject.characterization_metadata).to eq "built"
      end
    end
  end


  describe "#characterization_metadata_admin_only" do
    context "when instance variable is set" do
      before {
        subject.instance_variable_set(:@characterization_metadata_admin_only, "characterization metadata admin only")
      }
      it "returns value of instance variable" do
        expect(subject.characterization_metadata_admin_only).to eq "characterization metadata admin only"
      end
    end

    context "when instance variable is not set" do
      before {
        allow(subject).to receive(:build_characterization_metadata_admin_only).and_return "built in a day"
      }
      it "returns result of build_characterization_metadata_admin_only" do
        expect(subject).to receive(:build_characterization_metadata_admin_only).and_return "built in a day"

        expect(subject.characterization_metadata_admin_only).to eq "built in a day"
      end
    end
  end


  describe "#additional_characterization_metadata" do
    context "when instance variable is set" do
      before {
        subject.instance_variable_set(:@additional_characterization_metadata, "additional characterization")
      }
      it "returns value of instance variable" do
        expect(subject.additional_characterization_metadata).to eq "additional characterization"
      end
    end

    context "when instance variable is not set" do
      it "returns empty hash" do
        expect(subject.additional_characterization_metadata).to be_blank
      end
    end
  end


  describe "#additional_characterization_metadata_admin_only" do
    context "when instance variable is set" do
      before {
        subject.instance_variable_set(:@additional_characterization_metadata_admin_only, "additional characterization admin only")
      }
      it "returns value of instance variable" do
        expect(subject.additional_characterization_metadata_admin_only).to eq "additional characterization admin only"
      end
    end

    context "when instance variable is not set" do
      it "returns empty hash" do
        expect(subject.additional_characterization_metadata_admin_only).to be_blank
      end
    end
  end


  describe "#label_for_term" do
    context "when I18n has translation data" do
      before {
        allow(MsgHelper).to receive(:t).with("show.file_set.label.1001", raise: true ).and_return "labelmaker"
      }
      it "returns term label" do
        expect(subject.label_for_term "1001").to eq "labelmaker"
      end
    end

    context "when MissingTranslationData error occurs" do
      it "returns term capitalized" do
        skip "Add a test"
      end
    end
  end


  describe "#primary_characterization_values" do
    context "when characterization_metadata returns results for term" do
      before {
        allow(Hyrax.config).to receive(:fits_message_length).and_return 5
        allow(subject).to receive(:characterization_metadata).and_return [ ["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer vel leo quis sapien placerat fringilla. Fusce mattis metus orci, sit amet efficitur lectus blandit et. Vivamus rhoncus turpis eget maximus porttitor. Nunc sagittis consequat eros luctus semper.", "Lion", "Tortoise", "Tiger", "Leopard", "Flamingo"] ]
      }
      it "returns truncated values" do
        expect(subject.primary_characterization_values 0).to eq ["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer vel leo quis sapien placerat fringilla. Fusce mattis metus orci, sit amet efficitur lectus blandit et. Vivamus rhoncus turpis eget maximus porttitor. Nunc sagittis consequat eros luc...", "Lion", "Tortoise", "Tiger", "Leopard"]
      end
    end
  end


  describe "#primary_characterization_values_admin_only" do
    context "when characterization_metadata_admin_only returns results for term" do
      before {
        allow(Hyrax.config).to receive(:fits_message_length).and_return 5
        allow(subject).to receive(:characterization_metadata_admin_only).and_return [ ["Maecenas sapien tortor, laoreet eu ipsum vitae, rutrum rhoncus magna. Maecenas suscipit vitae augue eu auctor. Nullam sed suscipit sapien. Pellentesque tincidunt dapibus nisi, a sagittis velit ultrices ac. Integer ut elit ut justo consequat vulputate sed vel sapien.", "Eagle", "Hippopotamus", "Falcon", "Wolf", "Gazelle"] ]
      }
      it "returns truncated values" do
        expect(subject.primary_characterization_values_admin_only 0).to eq ["Maecenas sapien tortor, laoreet eu ipsum vitae, rutrum rhoncus magna. Maecenas suscipit vitae augue eu auctor. Nullam sed suscipit sapien. Pellentesque tincidunt dapibus nisi, a sagittis velit ultrices ac. Integer ut elit ut justo consequat vulput...", "Eagle", "Hippopotamus", "Falcon", "Wolf"]
      end
    end
  end


  describe "#secondary_characterization_values" do
    context "when characterization_metadata returns results for term" do
      before {
        allow(Hyrax.config).to receive(:fits_message_length).and_return 5
        allow(subject).to receive(:characterization_metadata).and_return [ ["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer vel leo quis sapien placerat fringilla. Fusce mattis metus orci, sit amet efficitur lectus blandit et. Vivamus rhoncus turpis eget maximus porttitor. Nunc sagittis consequat eros luctus semper.", "Lion", "Tortoise", "Tiger", "Leopard", "Flamingo"] ]
      }
      it "returns truncated values" do
        expect(subject.secondary_characterization_values 0).to eq ["Flamingo"]
      end
    end

    context "when characterization_metadata does not return results" do
      before {
        allow(Hyrax.config).to receive(:fits_message_length).and_return 5
      }
      it "returns empty array" do
        expect(subject.secondary_characterization_values 0).to be_empty
      end
    end
  end


  describe "#secondary_characterization_values_admin_only" do
    context "when characterization_metadata_admin_only returns results for term" do
      before {
        allow(Hyrax.config).to receive(:fits_message_length).and_return 5
        allow(subject).to receive(:characterization_metadata_admin_only).and_return [ ["Maecenas sapien tortor, laoreet eu ipsum vitae, rutrum rhoncus magna. Maecenas suscipit vitae augue eu auctor. Nullam sed suscipit sapien. Pellentesque tincidunt dapibus nisi, a sagittis velit ultrices ac. Integer ut elit ut justo consequat vulputate sed vel sapien.", "Eagle", "Hippopotamus", "Falcon", "Wolf", "Gazelle"] ]
      }
      it "returns truncated values" do
        expect(subject.secondary_characterization_values_admin_only 0).to eq ["Gazelle"]
      end
    end

    context "when characterization_metadata_admin_only does not return results" do
      before {
        allow(Hyrax.config).to receive(:fits_message_length).and_return 5
      }
      it "returns empty array" do
        expect(subject.secondary_characterization_values_admin_only 0).to be_empty
      end
    end
  end
end
