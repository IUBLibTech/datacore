# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::DsFileSetPresenter do
  subject { described_class.new(double, double) }
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:request) { double(host: 'example.org', base_url: 'http://example.org') }

  let(:ability) { double Ability }
  let(:presenter) { described_class.new(solr_document, ability, request) }

  describe "delegates methods to solr_document:" do
    [:doi, :doi_the_correct_one, :doi_minted?, :doi_minting_enabled?, :doi_pending?, :file_size, :file_size_human_readable,
     :original_checksum, :mime_type, :title, :virus_scan_service, :virus_scan_status, :virus_scan_status_date].each do
    |method|
      it "#{method}" do
        expect(subject).to delegate_method(method).to(:solr_document)
      end
    end
  end

  # NOTE:  relative_url_root function exactly the same in collection_presenter, work_show_presenter
  describe "#relative_url_root" do
    context "when DeepBlueDocs::Application.config.relative_url_root has value" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:relative_url_root).and_return "site root"
      }
      it "returns value" do
        expect(DeepBlueDocs::Application.config).to receive(:relative_url_root)
        expect(subject.relative_url_root).to eq "site root"
      end
    end

    context "when DeepBlueDocs::Application.config.relative_url_root is nil or false" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:relative_url_root).and_return false
      }
      it "returns empty string" do
        expect(DeepBlueDocs::Application.config).to receive(:relative_url_root)
        expect(subject.relative_url_root).to be_blank
      end
    end
  end

  describe "#parent_doi_minted?" do
    context "calls DataSet.find on parent.id" do
      before {
        allow(subject).to receive(:parent).and_return OpenStruct.new(id: 222)
        allow(DataSet).to receive(:find).with(222).and_return OpenStruct.new(doi_minted?: true)
      }
      it "returns value of doi_minted?" do
        expect(DataSet).to receive(:find).with(222)
        expect(subject.parent_doi_minted?).to eq true
      end
    end
  end

  describe '#display_provenance_log_enabled?' do
     it 'returns true' do
        expect(subject.display_provenance_log_enabled?).to eq true
     end
  end

  # NOTE:  provenance_log_entries? function exactly the same in collection_presenter
  describe "#provenance_log_entries?" do
    context "calls Deepblue::ProvenancePath.path_for_reference" do
      before {
        allow(subject).to receive(:id).and_return 1000
        allow(Deepblue::ProvenancePath).to receive(:path_for_reference).with(1000).and_return "file_path"
        allow(File).to receive(:exist?).with("file_path").and_return true
      }
      it "returns whether file path exists" do
        expect(Deepblue::ProvenancePath).to receive(:path_for_reference)
        expect(File).to receive(:exist?).with("file_path")

        expect(subject.provenance_log_entries?).to eq true
      end
    end
  end

  describe "#parent_public?" do
    context "calls DataSet.find on parent.id" do
      before {
        allow(subject).to receive(:parent).and_return OpenStruct.new(id: 333)
        allow(DataSet).to receive(:find).with(333).and_return OpenStruct.new(public?: true)
      }
      it "returns value of public?" do
        expect(DataSet).to receive(:find).with(333)
        expect(subject.parent_public?).to eq true
      end
    end
  end

  describe "#first_title" do
    context "when the document has no title" do
      before {
        allow(subject).to receive(:title).and_return([])
      }
      it "returns string \'File\'" do
        expect(subject.first_title).to eq "File"
      end
    end

    context "when the document has at least one title" do
      before {
        allow(subject).to receive(:title).and_return(["Descriptive Title", "Obtuse Title"])
      }
      it "returns first title" do
        expect(subject.first_title).to eq "Descriptive Title"
      end
    end
  end

  describe "#link_name" do
    abilities = [{"admin" => true, "can" => true, "expected_result" => true},
                 {"admin" => true, "can" => false, "expected_result" => true},
                 {"admin" => false, "can" => true, "expected_result" => true},
                 {"admin" => false, "can" => false, "expected_result" => false}]

    before {
      allow(subject).to receive(:id).and_return 3000
      allow(subject).to receive(:first_title).and_return "Red Hot Spectacular"
    }

    abilities.each do |ability|
      context "when current_ability.admin? is #{ability[:admin]} and current_ability.can?[:read id] is #{ability[:can]}" do
        before {
          allow(subject.current_ability).to receive(:admin?).and_return ability[:admin]
          allow(subject.current_ability).to receive(:can?).with(:read, 3000).and_return ability[:can]
        }

        if ability[:expected_result]
          it "calls first_title" do
            expect(subject).to receive(:first_title)
            expect(subject.link_name).to eq "Red Hot Spectacular"
          end
        else
          it "returns string 'File'" do
            expect(subject.link_name).to eq "File"
          end
        end
      end
    end
  end

  describe "#file_name" do
    before {
      allow(subject).to receive(:link_name).and_return "link name"
    }

    context "when tombstone has a value" do
      it "return link_name" do
        expect(subject).not_to receive(:file_size_too_large_to_download?)
        expect(subject.file_name OpenStruct.new(tombstone: "monument"), "link to").to eq "link name"
      end
    end

    context "when tombstone does not have a value and file_size_too_large_to_download?" do
      before {
        allow(subject).to receive(:file_size_too_large_to_download?).and_return true
      }
      it "return link_name" do
        expect(subject).to receive(:file_size_too_large_to_download?)
        expect(subject.file_name OpenStruct.new(tombstone: nil), "link to").to eq "link name"
      end
    end

    context "when tombstone does not have a value and not file_size_too_large_to_download?" do
      before {
        allow(subject).to receive(:file_size_too_large_to_download?).and_return false
      }
      it "return link_to argument" do
        expect(subject).to receive(:file_size_too_large_to_download?)
        expect(subject.file_name OpenStruct.new(tombstone: nil), "link to").to eq "link to"
      end
    end
  end

  describe "#file_size_too_large_to_download?" do
     expected_results = [OpenStruct.new(file_size: nil, expected_result: false, comparison: "file size is nil" ),
                         OpenStruct.new(file_size: 6, expected_result: false, comparison: "file size is less than max_work_file_size_to_download" ),
                         OpenStruct.new(file_size: 7, expected_result: true, comparison: "file size is equal to max_work_file_size_to_download" ),
                         OpenStruct.new(file_size: 9, expected_result: true, comparison: "file size is greater than max_work_file_size_to_download" )]
     before {
       allow(DeepBlueDocs::Application.config).to receive(:max_work_file_size_to_download).and_return 7
     }

     expected_results.each { |n|
       context "when #{n.comparison}" do
         before {
           subject.instance_variable_set(:@solr_document, OpenStruct.new(file_size: n.file_size))
         }
         it "returns #{n.expected_result}" do
           expect(subject.file_size_too_large_to_download?).to eq(n.expected_result)
         end
       end
     }
  end

end
