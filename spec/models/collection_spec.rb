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

  describe "#for_event_route" do
    before {
      allow(subject).to receive(:id).and_return 1000
      # Could not stub Rails.application.routes.url_helpers.hyrax_data_set_path
    }
    it do
      expect(subject.for_event_route).to eq "/concern/data_sets/1000"
    end
  end

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

  describe "#child_collection_count" do
    before {
      allow(subject).to receive(:id).and_return 1000
      allow(ActiveFedora::Base).to receive(:where).with( "member_of_collection_ids_ssim:1000 AND generic_type_sim:Collection" )
                                                  .and_return ["a", "b", "c"]
    }
    it do
      expect(ActiveFedora::Base).to receive(:where).with( "member_of_collection_ids_ssim:1000 AND generic_type_sim:Collection" )
      expect(subject.child_collection_count).to eq 3
    end
  end

  describe "#child_collection_ids" do
    before {
      allow(subject).to receive(:id).and_return 1000
      allow(ActiveFedora::Base).to receive(:where).with( "member_of_collection_ids_ssim:1000 AND generic_type_sim:Collection" )
                                                  .and_return [OpenStruct.new(id: "a"), OpenStruct.new(id: "b"), OpenStruct.new(id: "c")]
    }
    it do
      expect(ActiveFedora::Base).to receive(:where).with( "member_of_collection_ids_ssim:1000 AND generic_type_sim:Collection" )
      expect(subject.child_collection_ids).to eq ["a", "b", "c"]
    end
  end

  describe "#child_work_count" do
    before {
      allow(subject).to receive(:id).and_return 2000
      allow(ActiveFedora::Base).to receive(:where).with( "member_of_collection_ids_ssim:2000 AND generic_type_sim:Work" )
                                                  .and_return ["a", "b", "c", "d", "e"]
    }
    it do
      expect(ActiveFedora::Base).to receive(:where).with( "member_of_collection_ids_ssim:2000 AND generic_type_sim:Work" )
      expect(subject.child_work_count).to eq 5
    end
  end

  describe "#child_work_ids" do
    before {
      allow(subject).to receive(:id).and_return 2000
      allow(ActiveFedora::Base).to receive(:where).with( "member_of_collection_ids_ssim:2000 AND generic_type_sim:Work" )
        .and_return [OpenStruct.new(id: "a"), OpenStruct.new(id: "b"), OpenStruct.new(id: "c"), OpenStruct.new(id: "d"), OpenStruct.new(id: "e")]
    }
    it do
      expect(ActiveFedora::Base).to receive(:where).with( "member_of_collection_ids_ssim:2000 AND generic_type_sim:Work" )
      expect(subject.child_work_ids).to eq ["a", "b", "c", "d", "e"]
    end
  end

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
    context "has total_file_size value" do
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

  describe "#map_email_attributes_override!" do
    email_attributes = [{attribute: "child_collection_count", value: "child work count", handled: true},
                        {attribute: "child_collection_ids", value: "collection ids", handled: true},
                        {attribute: "child_work_count", value: "child work count", handled: true},
                        {attribute: "child_work_ids", value: "child work ids", handled: true},
                        {attribute: "collection_type", value: "machine id", handled: true},
                        {attribute: "total_file_size", value: "total file size", handled: true},
                        {attribute: "total_file_size_human_readable", value: "total file size human readable", handled: true},
                        {attribute: "visibility", value: "visibility", handled: true},
                        {attribute: "something_else", value: nil, handled: false}]
    email_values = {}

    context "when values present" do
      before {
        allow(subject).to receive(:child_work_count).and_return "child work count"
        allow(subject).to receive(:collection_ids).and_return "collection ids"
        allow(subject).to receive(:child_work_ids).and_return "child work ids"
        allow(subject).to receive(:collection_type).and_return OpenStruct.new(machine_id: "machine id")
        allow(subject).to receive(:total_file_size).and_return "total file size"
        allow(subject).to receive(:total_file_size_human_readable).and_return "total file size human readable"
        allow(subject).to receive(:visibility).and_return "visibility"
      }

      email_attributes.each do |h|
        it "called with attribute #{h[:attribute]} and ignore_blank_key_values true" do
          expect(subject.map_email_attributes_override!(event: "event", attribute: h[:attribute], ignore_blank_key_values: true, email_key_values: email_values))
            .to eq h[:handled]
          expect(email_values[h[:attribute]]).to eq h[:value]
        end
      end
    end

    context "when values are not present" do
      email_attributes[1] = {attribute: "child_collection_ids", value: "collection ids", handled: false}

      before {
        allow(subject).to receive(:child_work_count).and_return nil
        allow(subject).to receive(:collection_ids).and_return nil
        allow(subject).to receive(:child_work_ids).and_return nil
        allow(subject).to receive(:collection_type).and_return OpenStruct.new(machine_id: nil)
        allow(subject).to receive(:total_file_size).and_return nil
        allow(subject).to receive(:total_file_size_human_readable).and_return nil
        allow(subject).to receive(:visibility).and_return nil

      }
      email_attributes.each do |h|
        it "called with attribute #{h[:attribute]} and ignore_blank_key_values false" do
          expect(subject.map_email_attributes_override!(event: "event", attribute: h[:attribute], ignore_blank_key_values: false, email_key_values: email_values))
            .to eq h[:handled]
          if h[:handled]
            expect(email_values[h[:attribute]]).to be_blank
          end
        end
      end
    end
  end


  describe "#map_provenance_attributes_override!" do
    email_attributes = [{attribute: "child_collection_count", value: "child work count", handled: true},
                        {attribute: "child_collection_ids", value: "collection ids", handled: true},
                        {attribute: "child_work_count", value: "child work count", handled: true},
                        {attribute: "child_work_ids", value: "child work ids", handled: true},
                        {attribute: "collection_type", value: "machine id", handled: true},
                        {attribute: "total_file_size", value: "total file size", handled: true},
                        {attribute: "total_file_size_human_readable", value: "total file size human readable", handled: true},
                        {attribute: "visibility", value: "visibility", handled: true},
                        {attribute: "something_else", value: nil, handled: false}]
    email_values = {}

    context "when values present" do
      before {
        allow(subject).to receive(:child_work_count).and_return "child work count"
        allow(subject).to receive(:collection_ids).and_return "collection ids"
        allow(subject).to receive(:child_work_ids).and_return "child work ids"
        allow(subject).to receive(:collection_type).and_return OpenStruct.new(machine_id: "machine id")
        allow(subject).to receive(:total_file_size).and_return "total file size"
        allow(subject).to receive(:total_file_size_human_readable).and_return "total file size human readable"
        allow(subject).to receive(:visibility).and_return "visibility"
      }

      email_attributes.each do |h|
        it "called with attribute #{h[:attribute]} and ignore_blank_key_values true" do
          expect(subject.map_email_attributes_override!(event: "event", attribute: h[:attribute], ignore_blank_key_values: true, email_key_values: email_values))
            .to eq h[:handled]
          expect(email_values[h[:attribute]]).to eq h[:value]
        end
      end
    end

    context "when values are not present" do
      email_attributes[1] = {attribute: "child_collection_ids", value: "collection ids", handled: false}

      before {
        allow(subject).to receive(:child_work_count).and_return nil
        allow(subject).to receive(:collection_ids).and_return nil
        allow(subject).to receive(:child_work_ids).and_return nil
        allow(subject).to receive(:collection_type).and_return OpenStruct.new(machine_id: nil)
        allow(subject).to receive(:total_file_size).and_return nil
        allow(subject).to receive(:total_file_size_human_readable).and_return nil
        allow(subject).to receive(:visibility).and_return nil

      }
      email_attributes.each do |h|
        it "called with attribute #{h[:attribute]} and ignore_blank_key_values false" do
          expect(subject.map_provenance_attributes_override!(event: "event", attribute: h[:attribute], ignore_blank_key_values: false, prov_key_values: email_values))
            .to eq h[:handled]
          if h[:handled]
            expect(email_values[h[:attribute]]).to be_blank
          end
        end
      end
    end
  end


  describe "#metadata_hash_override" do
    email_attributes = [{attribute: "child_collection_count", value: "child work count", handled: true},
                        {attribute: "child_collection_ids", value: "collection ids", handled: true},
                        {attribute: "child_work_count", value: "child work count", handled: true},
                        {attribute: "child_work_ids", value: "child work ids", handled: true},
                        {attribute: "collection_type", value: "machine id", handled: true},
                        {attribute: "total_file_size", value: "total file size", handled: true},
                        {attribute: "total_file_size_human_readable", value: "total file size human readable", handled: true},
                        {attribute: "visibility", value: "visibility", handled: true},
                        {attribute: "something_else", value: nil, handled: false}]
    email_values = {}

    context "when values present" do
      before {
        allow(subject).to receive(:child_work_count).and_return "child work count"
        allow(subject).to receive(:collection_ids).and_return "collection ids"
        allow(subject).to receive(:child_work_ids).and_return "child work ids"
        allow(subject).to receive(:collection_type).and_return OpenStruct.new(machine_id: "machine id")
        allow(subject).to receive(:total_file_size).and_return "total file size"
        allow(subject).to receive(:total_file_size_human_readable).and_return "total file size human readable"
        allow(subject).to receive(:visibility).and_return "visibility"
      }

      email_attributes.each do |h|
        it "called with attribute #{h[:attribute]} and ignore_blank_key_values true" do
          expect(subject.metadata_hash_override(key: h[:attribute], ignore_blank_values: true, key_values: email_values))
            .to eq h[:handled]
          expect(email_values[h[:attribute]]).to eq h[:value]
        end
      end
    end

    context "when values are not present" do
      email_attributes[1] = {attribute: "child_collection_ids", value: "collection ids", handled: false}

      before {
        allow(subject).to receive(:child_work_count).and_return nil
        allow(subject).to receive(:collection_ids).and_return nil
        allow(subject).to receive(:child_work_ids).and_return nil
        allow(subject).to receive(:collection_type).and_return OpenStruct.new(machine_id: nil)
        allow(subject).to receive(:total_file_size).and_return nil
        allow(subject).to receive(:total_file_size_human_readable).and_return nil
        allow(subject).to receive(:visibility).and_return nil

      }
      email_attributes.each do |h|
        it "called with attribute #{h[:attribute]} and ignore_blank_key_values false" do
          expect(subject.map_provenance_attributes_override!(event: "event", attribute: h[:attribute], ignore_blank_key_values: false, prov_key_values: email_values))
            .to eq h[:handled]
          if h[:handled]
            expect(email_values[h[:attribute]]).to be_blank
          end
        end
      end
    end
  end


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

  describe "#metadata_report_label_override" do
    expected_values = {'child_collection_count': 'Child Collection Count: ', 'child_collection_ids': 'Child Collection Identifiers: ',
                       'child_work_count': 'Child Work Count: ', 'child_work_ids': 'Child Work Identifiers: ',
    'collection_type': 'Collection Type: ', 'total_file_size': 'Total File Size: ', 'total_file_size_human_readable': 'Total File Size: '  }
    expected_values.each do |val, expected|
      it "returns #{expected} when metadata_key is #{val}" do
        expect(subject.metadata_report_label_override metadata_key:val, metadata_value: nil).to eq(expected)
      end
    end
  end

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
