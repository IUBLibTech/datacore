# frozen_string_literal: true

require_relative '../../../../app/models/concerns/deepblue/abstract_event_behavior'
require_relative '../../../../app/models/concerns/deepblue/metadata_behavior'

class CurationConcernEmptyMock
  include ::Deepblue::MetadataBehavior
end

class CurationConcernMock
  include ::Deepblue::MetadataBehavior

  def description
    ['The Description']
  end

  def id
    'id123'
  end

  def title
    ['The Title', 'Part 2']
  end

  def visiblity
    Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
  end

  def metadata_keys_all
    %i[ id title description ]
  end

  def metadata_keys_brief
    %i[ id title ]
  end

  def metadata_hash_override( key:, ignore_blank_values:, key_values: )
    value = nil
    handled = case key.to_s
              when 'description'
                value = description
                true
              else
                false
              end
    return false unless handled
    if ignore_blank_values
      key_values[key] = value if value.present?
    else
      key_values[key] = value
    end
    return true
  end

end

class OutputMock
  def puts(text)

  end
end



RSpec.describe Deepblue::AbstractEventBehavior do

  let( :empty_mock ) { CurationConcernEmptyMock.new }
  let( :mock ) { CurationConcernMock.new }

  describe 'constants' do
    it do
      expect( Deepblue::MetadataBehavior::METADATA_FIELD_SEP ).to eq '; '
      expect( Deepblue::MetadataBehavior::METADATA_REPORT_DEFAULT_DEPTH ).to eq 2
      expect( Deepblue::MetadataBehavior::METADATA_REPORT_DEFAULT_FILENAME_POST ).to eq '_metadata_report'
      expect( Deepblue::MetadataBehavior::METADATA_REPORT_DEFAULT_FILENAME_EXT ).to eq '.txt'
    end
  end

  describe '#for_metadata_id' do
    it do
      expect( mock.for_metadata_id ).to eq 'id123'
    end
  end

  describe '#for_metadata_title' do
    it do
      expect( mock.for_metadata_title ).to eq ['The Title', 'Part 2']
    end
  end

  describe 'default values' do
    it do
      expect( empty_mock.metadata_keys_all ).to eq []
      expect( empty_mock.metadata_keys_brief ).to eq []
      expect( empty_mock.metadata_hash_override( key: 'key', ignore_blank_values: false, key_values: [ key: 'value' ] ) ).to eq false
      expect( empty_mock.metadata_report_label_override(metadata_key: 'key', metadata_value: 'value' ) ).to eq nil
      ignore_blank_key_values, keys = empty_mock.metadata_report_keys
      expect( ignore_blank_key_values ).to eq ::Deepblue::AbstractEventBehavior::IGNORE_BLANK_KEY_VALUES
      expect( keys ).to eq []
      expect( empty_mock.metadata_report_contained_objects ).to eq []
      expect( empty_mock.metadata_report_title_pre ).to eq ''
      expect( empty_mock.metadata_report_title_field_sep ).to eq ' '
    end
  end

  describe '#metadata_hash' do
    let( :empty_hash ) { {} }
    let( :expected_hash_all ) { { id: mock.id, title: mock.title, description: mock.description } }
    let( :expected_hash_brief ) { { id: mock.id, title: mock.title } }
    let( :expected_kv_hash_all ) { { key: 'value', id: mock.id, title: mock.title, description: mock.description } }
    let( :expected_kv_hash_brief ) { { key: 'value', id: mock.id, title: mock.title } }
    context 'empty' do
      it do
        expect( mock.metadata_hash( metadata_keys: [], ignore_blank_values: false ) ).to eq empty_hash
        expect( mock.metadata_hash( metadata_keys: [], ignore_blank_values: false, **empty_hash ) ).to eq empty_hash
      end
    end
    context 'returns correct value for id, title' do
      it do
        expect( mock.metadata_hash( metadata_keys: mock.metadata_keys_brief, ignore_blank_values: false ) ).to eq expected_hash_brief
        expect( mock.metadata_hash( metadata_keys: mock.metadata_keys_all, ignore_blank_values: false ) ).to eq expected_hash_all
        kv_hash = { key: 'value' }
        expect( mock.metadata_hash( metadata_keys: mock.metadata_keys_brief, ignore_blank_values: false, **kv_hash ) ).to eq expected_kv_hash_brief
        kv_hash = { key: 'value' }
        expect( mock.metadata_hash( metadata_keys: mock.metadata_keys_all, ignore_blank_values: false, **kv_hash ) ).to eq expected_kv_hash_all
      end
    end
  end


  describe "#metadata_report" do
    context "when dir is empty and out is empty" do
      it "raises a MetadataError" do
        expect { mock.metadata_report }.to raise_error("Either dir: or out: must be specified.")
      end
    end

    context "when out is empty" do
      before {
        allow(mock).to receive(:metadata_report_filename).with(pathname_dir: "directory", filename_pre: '', filename_post: '_metadata_report', filename_ext: '.txt').and_return "target file"
        allow(mock).to receive(:open).with("target file", 'w').and_return "out 2"
      }

      it "calls open on the result of calling metadata_report_filename" do
        expect(mock).to receive(:metadata_report_filename).with(pathname_dir: "directory", filename_pre: '', filename_post: '_metadata_report', filename_ext: '.txt')
        expect(mock).to receive(:open).with("target file", 'w')

        expect(mock.metadata_report(dir: "directory")).to eq "target file"
      end

      it "calls metadata_report" do
        skip "Add a test"
      end
    end

    context "when dir and out both have values" do
      let( :out_obj ) { OutputMock.new }

      before {
        allow(mock).to receive(:metadata_report_title).with(depth: 2).and_return "report title"
        allow(out_obj).to receive(:puts).with "report title"
        allow(mock).to receive(:metadata_report_keys).and_return ["ignore", "keys"]
        allow(mock).to receive(:metadata_hash).with(metadata_keys: "keys", ignore_blank_values: "ignore").and_return "metadata hash"
        allow(mock).to receive(:metadata_report_to).with(out: out_obj, metadata_hash: "metadata hash", depth: 2)
      }
      it "calls metadata_report_title" do
        expect(mock).to receive(:metadata_report_title)
        expect(out_obj).to receive(:puts).with "report title"
        expect(mock).to receive(:metadata_report_keys)
        expect(mock).to receive(:metadata_hash).with(metadata_keys: "keys", ignore_blank_values: "ignore")
        expect(mock).to receive(:metadata_report_to).with(out: out_obj, metadata_hash: "metadata hash", depth: 2)

        expect(mock.metadata_report(dir: "directory", out: out_obj)).to be_blank
      end
    end
  end


  describe '#metadata_report_filename' do
    let( :pathname_dir ) { "/some/path" }
    let( :filename_pre ) { "pre_" }
    context 'basic parms' do
      it do
        expect( mock.metadata_report_filename( pathname_dir: Pathname.new( pathname_dir ),
                                               filename_pre: filename_pre ) ).to eq Pathname.new "/some/path/pre_id123_metadata_report.txt"
      end
    end
    context 'all parms' do
      it do
        expect( mock.metadata_report_filename( pathname_dir: Pathname.new( pathname_dir ),
                                               filename_pre: filename_pre,
                                               filename_post: "_post",
                                               filename_ext: ".ext" ) ).to eq Pathname.new "/some/path/pre_id123_post.ext"
      end
    end
  end


  describe "#metadata_report_label" do
    context "when metadata_key is blank" do
      it "returns nil" do
        expect(mock.metadata_report_label(metadata_key: "", metadata_value: nil)).to be_blank
      end
    end

    context "when metadata_report_label_override returns a label" do
      before {
        allow(mock).to receive(:metadata_report_label_override).with(metadata_key: "key", metadata_value: "value").and_return "label"
      }
      it "returns label" do
        expect(mock).to receive(:metadata_report_label_override)
        expect(mock.metadata_report_label(metadata_key: "key", metadata_value: "value")).to eq "label"
      end
    end

    context "when metadata_report_label_override does not return a label" do
      metadata_labels = [{"key" => "id", "label" => "ID: "},
                         {"key" => "location", "label" => "Location: "},
                         {"key" => "route", "label" => "Route: "},
                         {"key" => "title", "label" => "Title: "},
                         {"key" => "visibility", "label" => "Visibility: "},
                         {"key" => "outland BAGPIPES", "label" => "Outland Bagpipes"}]

      metadata_labels.each do |report|
        before {
          allow(mock).to receive(:metadata_report_label_override).with(metadata_key: report[:key], metadata_value: "value")
        }
        it "returns a label '#{report[:label]}' based on metadata_key '#{report[:key]}'" do
          expect(mock.metadata_report_label(metadata_key: report[:key], metadata_value: "value")).to eq report[:label]
        end
      end

    end
  end


  describe "#metadata_report_to" do
    context "when out argument passed in is nil" do
      it "returns nil" do
        expect(mock.metadata_report_to(out: nil, metadata_hash: "hash")).to be_blank
      end
    end

    context "when out is not nil and metadata_hash has pairs" do
      before {
        allow(mock).to receive(:metadata_report_item_to).with(out: "out", key: :a, value: 100, depth: 0)
        allow(mock).to receive(:metadata_report_item_to).with(out: "out", key: :b, value: 200, depth: 0)
      }
      it "calls metadata_report_item_to for each pair" do
        expect(mock).to receive(:metadata_report_item_to).with(out: "out", key: :a, value: 100, depth: 0)
        expect(mock).to receive(:metadata_report_item_to).with(out: "out", key: :b, value: 200, depth: 0)

        expect(mock.metadata_report_to(out: "out", metadata_hash: { a: 100, b: 200 }))
      end
    end

    context "when out is not nil and metadata_hash does not have pairs" do
      it "returns nil" do
        expect(mock.metadata_report_to(out: "outside", metadata_hash: { })).to be_blank
      end
    end
  end


  describe "#metadata_report_item_to" do
    before {
      allow(mock).to receive(:metadata_report_label).with(metadata_key: "key", metadata_value: "value").and_return "label"
      allow(Deepblue::MetadataHelper).to receive(:report_item).with("out", "label", "value")
    }
    it "calls MetadataHelper.report_item" do
      expect(mock).to receive(:metadata_report_label)
      expect(Deepblue::MetadataHelper).to receive(:report_item).with("out", "label", "value")
      mock.metadata_report_item_to(out: "out", key: "key", value: "value", depth: 0)
    end
  end


  describe "#metadata_report_visibility_value" do
    context "when visibility is VISIBILITY_TEXT_VALUE_PUBLIC" do
      it "returns published" do
        expect(mock.metadata_report_visibility_value(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)).to eq "published"
      end
    end

    context "when visibility is VISIBILITY_TEXT_VALUE_PRIVATE" do
      it "returns private" do
        expect(mock.metadata_report_visibility_value(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)).to eq "published"
      end
    end

    context "when visibility is not public or private - other " do

      it "returns value of visibility" do
        expect(mock.metadata_report_visibility_value("anything else")).to eq "anything else"
      end
    end
  end


end
