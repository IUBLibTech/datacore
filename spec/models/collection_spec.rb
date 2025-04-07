require 'rails_helper'

RSpec.describe Collection do

  let( :IGNORE_BLANK_KEY_VALUES) { true }

  let( :metadata_keys_all) {
    %i[
      child_collection_ids
      child_collection_count
      child_work_ids
      child_work_count
      collection_type
      creator
      curation_notes_admin
      curation_notes_user
      date_created
      date_modified
      date_updated
      description
      keyword
      language
      prior_identifier
      referenced_by
      subject_discipline
      title
      total_file_size
      visibility
    ]
  }

  let( :metadata_keys_brief ) {
    %i[
      creator
      title
      visibility
    ]
  }

  let( :metadata_keys_report ) {
    %i[
      child_collection_count
      child_work_count
      collection_type
      creator
      curation_notes_user
      description
      keyword
      language
      referenced_by
      subject_discipline
      title
      total_file_size
    ]
  }

  let( :metadata_keys_update ) {
    %i[
      creator
      title
      visibility
    ]
  }

  describe "#attributes_all_for_email" do
    it 'returns metadata_keys_all' do
      expect(subject.attributes_all_for_email).to eq metadata_keys_all
    end
  end

  describe "#attributes_all_for_provenance" do
    it 'returns metadata_keys_all' do
      expect(subject.attributes_all_for_provenance).to eq metadata_keys_all
    end
  end

  describe "#attributes_brief_for_email" do
    it 'returns metadata_keys_brief' do
      expect(subject.attributes_brief_for_email).to eq metadata_keys_brief
    end
  end

  describe "#attributes_brief_for_provenance" do
    it 'returns metadata_keys_brief' do
      expect(subject.attributes_brief_for_provenance).to eq metadata_keys_brief
    end
  end

  describe "#attributes_standard_for_email" do
    it 'returns metadata_keys_brief' do
      expect(subject.attributes_standard_for_email).to eq metadata_keys_brief
    end
  end

  describe "#attributes_update_for_email" do
    it 'returns metadata_keys_update' do
      expect(subject.attributes_update_for_email).to eq metadata_keys_update
    end
  end

  describe "#attributes_update_for_provenance" do
    it 'returns metadata_keys_update' do
      expect(subject.attributes_update_for_provenance).to eq metadata_keys_update
    end
  end


  describe "#for_email_route" do
    context "id has data set path" do
      before {
        allow(subject).to receive(:for_event_route).and_return("http://www.example.rog")
      }
      it 'returns for_email_route' do
        expect(subject.for_provenance_route).to eq "http://www.example.rog"
      end
    end
  end

  pending "#for_event_route"


  describe "#for_provenance_route" do
    context "id has data set path" do
      before {
        allow(subject).to receive(:for_event_route).and_return("http://www.example.ogr")
      }
      it 'returns for_event_route' do
        expect(subject.for_provenance_route).to eq "http://www.example.ogr"
      end
    end
  end

  pending "#child_collection_count"
  pending "#child_collection_ids"
  pending "#child_work_count"
  pending "#child_work_ids"


  describe "#total_file_size" do
    context "has bytes value" do
      before {
        allow(subject).to receive(:bytes).and_return(300)
      }
      it 'returns bytes' do
        expect(subject.total_file_size).to eq 300
      end
    end
  end

  describe "#total_file_size_human_readable" do
    context "has bytes value" do
      before {
        allow(subject).to receive(:total_file_size).and_return(1234)
      }
      it 'returns human-friendly formatting of bytes' do
        expect(subject.total_file_size_human_readable).to eq "1.21 KB"
      end
    end
  end

  describe "#title_type" do
    context "has human_readable_type value" do
      before {
        allow(subject).to receive(:human_readable_type).and_return("Fabulous Data Set")
      }
      it 'returns human_readable_type' do
        expect(subject.title_type).to eq "Fabulous Data Set"
      end
    end
  end

  pending "#map_email_attributes_override!"
  pending "#map_provenance_attributes_override!"
  pending "#metadata_hash_override"


  describe "#metadata_report_contained_objects" do
    context "has member_objects" do
      before {
        allow(subject).to receive(:member_objects).and_return [1,2,3]
      }
      it 'returns member_objects' do
        expect(subject.metadata_report_contained_objects).to eq [1,2,3]
      end
    end
  end

  describe "#metadata_report_keys" do
    it 'returns IGNORE_BLANK_KEY_VALUES, metadata_keys_report' do
      expect(subject.metadata_report_keys).to eq [true, metadata_keys_report]
    end
  end

  pending "#metadata_report_label_override"


  describe '#metadata_report_title_pre' do
     it 'returns string' do
       expect(subject.metadata_report_title_pre).to eq('Collection: ')
     end
  end

  pending "#creator"
  pending "#creator="
  pending "#curation_notes_admin"
  pending "#curation_notes_admin="
  pending "#curation_notes_user"
  pending "#curation_notes_user="
  pending "#description"
  pending "#description="
  pending "#referenced_by"
  pending "#referenced_by="
  pending "#keyword"
  pending "#keyword="
  pending "#language"
  pending "#language="
  pending "#title"
  pending "#title="

end
