# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::DataSetPresenter do
  subject { described_class.new(double, double) }
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:request) { double(host: 'example.org', base_url: 'http://example.org') }
  let(:user_key) { 'a_user_key' }

  let(:attributes) do
    { "id" => '888888',
      "title_tesim" => ['foo', 'bar'],
      "human_readable_type_tesim" => ["Generic Work"],
      "has_model_ssim" => ["DataSet"],
      "date_created_tesim" => ['an unformatted date'],
      "depositor_tesim" => user_key }
  end
  let(:ability) { double Ability }
  let(:presenter) { described_class.new(solr_document, ability, request) }

  describe "delegates methods to solr_document:" do
    [:authoremail,
     :based_near_label,
     :curation_notes_admin,
     :curation_notes_user,
     :date_created, :date_modified,
     :date_published, :date_published2,
     :date_uploaded,
     :depositor,
     :doi, :doi_the_correct_one,
     :doi_minted?,
     :doi_minting_enabled?,
     :doi_pending?,
     :fundedby,
     :fundedby_other,
     :grantnumber,
     :methodology,
     :prior_identifier,
     :referenced_by,
     :related_url,
     :rights_license,
     :rights_license_other,
     :subject_discipline,
     :access_deepblue,
     :geo_location_place,
     :geo_location_box,
     :license_other,
     :academic_affiliation,
     :alt_title,
     :bibliographic_citation,
     :contributor_affiliationumcampus,
     :date_attribute,
     :date_issued,
     :description_abstract,
     :description_mapping,
     :description_sponsorship,
     :external_link,
     :identifier,
     :identifier_orcid,
     :identifier_source,
     :itemtype,
     :keyword,
     :language_none,
     :linked,
     :other_affiliation,
     :peerreviewed,
     :relation_ispartofseries,
     :resource_type,
     :to_s,
     :type_none].each do
    |method|
      it "#{method}" do
        expect(subject).to delegate_method(method).to(:solr_document)
      end
    end
  end

  pending "delegates date_coverage and total_file_size to solr_document"

  describe "#box_enabled?" do
    before {
      allow(DeepBlueDocs::Application.config).to receive(:box_integration_enabled).and_return "box integration enabled"
    }
    it "returns result of DeepBlueDocs::Application.config.box_integration_enabled"  do
      expect(subject.box_enabled?).to eq "box integration enabled"
    end
  end

  describe "#box_link" do
    context "when box_enabled? is false" do
      before {
        allow(subject).to receive(:box_enabled?).and_return false
      }
      it "returns nil" do
        expect(subject.box_link).to be_blank
      end
    end

    context "when box_enabled? is true" do
      it "returns result of BoxHelper.box_link" do
        skip "Add a test"
      end
    end
  end


  describe "#box_link_display_for_work?" do
    context "when box_enabled? is false" do
      before {
        allow(subject).to receive(:box_enabled?).and_return false
      }
      it "returns false" do
        expect(subject.box_link_display_for_work? "current user").to eq false
      end
    end

    context "when box_enabled? is true" do
      it "returns result of BoxHelper.box_link_display_for_work?" do
        skip "Add a test"
      end
    end
  end


  describe "#date_coverage" do
    context "when @solr_document.date_coverage is blank" do
      before {
        subject.instance_variable_set(:@solr_document, OpenStruct.new(date_coverage: []))
      }
      it "returns nil" do
        expect(subject.date_coverage).to be_blank
      end
    end

    context "when @solr_document.date_coverage contains '/open'" do
      before {
        subject.instance_variable_set(:@solr_document, OpenStruct.new(date_coverage: "/open/hello world"))
      }
      it "returns substring" do
        expect(subject.date_coverage).to eq "/hello world"
      end
    end

    context "when @solr_document.date_coverage does not contain '/open'" do
      before {
        subject.instance_variable_set(:@solr_document, OpenStruct.new(date_coverage: "/closed/hello world"))
      }
      it "returns substring" do
        expect(subject.date_coverage).to eq " to closed/hello world"
      end
    end
  end


  describe "#display_provenance_log_enabled?" do
    it "returns true" do
      expect(subject.display_provenance_log_enabled?).to eq true
    end
  end


  describe "#provenance_log_entries?" do
    before {
      allow(subject).to receive(:id).and_return 1234
      allow(Deepblue::ProvenancePath).to receive(:path_for_reference).with(1234).and_return "file path"
    }

    context "when path_for_reference exists" do
      before {
        allow(File).to receive(:exist?).with("file path").and_return true
      }
      it "returns true" do
        expect(subject.provenance_log_entries?).to eq true
      end
    end

    context "when path_for_reference does not exist" do
      before {
        allow(File).to receive(:exist?).with("file path").and_return false
      }
      it "returns false" do
        expect(subject.provenance_log_entries?).to eq false
      end
    end
  end


  describe "#globus_download_enabled?" do
    before {
      allow(DeepBlueDocs::Application.config).to receive(:globus_enabled).and_return true
    }
    it "returns config globus_enabled" do
      expect(subject.globus_download_enabled?).to eq true
    end
  end


  describe "#globus_enabled?" do
    before {
      allow(DeepBlueDocs::Application.config).to receive(:globus_enabled).and_return true
    }
    it "returns config globus_enabled" do
      expect(subject.globus_download_enabled?).to eq true
    end
  end


  describe "#globus_external_url" do
    before {
      subject.instance_variable_set(:@solr_document, OpenStruct.new(id: 999))
      allow(::GlobusJob).to receive(:external_url).with(999).and_return "external url"
    }
    it "returns ::GlobusJob.external_url" do
      expect(subject.globus_external_url).to eq "external url"
    end
  end


  describe "#globus_files_available?" do
    before {
      subject.instance_variable_set(:@solr_document, OpenStruct.new(id: 999))
      allow(::GlobusJob).to receive(:files_available?).with(999).and_return true
    }
    it "returns ::GlobusJob.files_available?" do
      expect(subject.globus_files_available?).to eq true
    end
  end


  describe "#globus_files_prepping?" do
    before {
      subject.instance_variable_set(:@solr_document, OpenStruct.new(id: 999))
      allow(::GlobusJob).to receive(:files_prepping?).with(999).and_return true
    }
    it "returns ::GlobusJob.files_prepping?" do
      expect(subject.globus_files_prepping?).to eq true
    end
  end


  describe "#globus_last_error_msg" do
    before {
      subject.instance_variable_set(:@solr_document, OpenStruct.new(id: 999))
      allow(::GlobusJob).to receive(:error_file_contents).with(999).and_return "last message"
    }
    it "returns ::GlobusJob.error_file_contents?" do
      expect(subject.globus_last_error_msg).to eq "last message"
    end
  end


  describe "#hdl" do
    it "returns nil" do
      expect(subject.hdl).to be_blank
    end
  end


  describe "#human_readable" do
    before {
      allow(ActiveSupport::NumberHelper::NumberToHumanSizeConverter).to receive(:convert).with("value", precision: 3).and_return "human readable value"
    }
    it "returns human readable value" do
      expect(subject.human_readable "value").to eq "human readable value"
    end
  end


  describe "#label_with_total_file_size" do
    context "when total_file_size is zero" do
      before {
        allow(subject).to receive(:total_file_size).and_return 0
      }
      it "returns the value passed in" do
        expect(subject.label_with_total_file_size "label passed in").to eq "label passed in"
      end
    end

    context "when total_file_size is one" do
      before {
        allow(subject).to receive(:total_file_size).and_return 100
        allow(subject).to receive(:total_file_count).and_return 1
        allow(subject).to receive(:total_file_size_human_readable).and_return "lots of kilobytes"
      }
      it "returns the value passed in" do
        expect(subject.label_with_total_file_size "This").to eq "This (lots of kilobytes in 1 file)"
      end
    end

    context "when total_file_size is more than one" do
      before {
        allow(subject).to receive(:total_file_size).and_return 1000
        allow(subject).to receive(:total_file_count).and_return 10
        allow(subject).to receive(:total_file_size_human_readable).and_return "lots of MB"
      }
      it "returns the value passed in" do
        expect(subject.label_with_total_file_size "That").to eq "That (lots of MB in 10 files)"
      end
    end
  end


  describe "#tombstone" do
    context "when @solr_document is blank" do
      before {
        subject.instance_variable_set(:@solr_document, nil)
      }
      it "returns nil" do
        expect(subject.tombstone).to be_blank
      end
    end

    context "when @solr_document is not blank" do
      before {
        allow(Solrizer).to receive(:solr_name).with("tombstone", :symbol).and_return 0
      }
      context "when tombstone is not blank" do
        before {
          subject.instance_variable_set(:@solr_document, [["mausoleum", "crypt"], "monument", "epitaph"])
        }
        it "returns tombstone" do
          expect(subject.tombstone).to eq "mausoleum"
        end
      end

      context "when tombstone is blank" do
        before {
          subject.instance_variable_set(:@solr_document, [" ", "pyramid"])
        }
        it "returns nil" do
          expect(subject.tombstone).to be_blank
        end
      end
    end
  end


  describe "#tombstone_enabled?" do
    it "returns true" do
      expect(subject.tombstone_enabled?).to eq true
    end
  end


  describe "#total_file_count" do
    before {
      allow(Solrizer).to receive(:solr_name).with("file_set_ids", :symbol).and_return 1
    }

    context "when file set ids are blank" do
      before {
        subject.instance_variable_set(:@solr_document, ["a", "", "c"])
      }
      it "returns 0" do
        expect(subject.total_file_count).to eq 0
      end
    end

    context "when file set ids are not blank" do
      before {
        subject.instance_variable_set(:@solr_document, ["a", OpenStruct.new(size: 99), "c"])
      }
      it "returns size parameter" do
        expect(subject.total_file_count).to eq 99
      end
    end
  end


  describe "#total_file_size" do
    before {
      allow(Solrizer).to receive(:solr_name).with("total_file_size", Hyrax::FileSetIndexer::STORED_LONG).and_return 2
    }

    context "when total file size is blank" do
      before {
        subject.instance_variable_set(:@solr_document, ["a", "b", ""])
      }
      it "returns 0" do
        expect(subject.total_file_size).to eq 0
      end
    end

    context "when total file size is not blank" do
      before {
        subject.instance_variable_set(:@solr_document, ["a", "b", "total file size"])
      }
      it "returns size parameter" do
        expect(subject.total_file_size).to eq "total file size"
      end
    end
  end


  describe "#total_file_size_human_readable" do
    before {
      allow(subject).to receive(:total_file_size).and_return "total file size"
      allow(subject).to receive(:human_readable).with("total file size").and_return "total file size human readable"
    }
    it "passes total_file_size to human_readable" do
      expect(subject.total_file_size_human_readable).to eq "total file size human readable"
    end
  end


  describe "#zip_download_enabled?" do
    before {
      allow(Settings).to receive(:zip_download_enabled).and_return true
    }
    it "returns zip_download_enabled from Settings" do
      expect(subject.zip_download_enabled?).to eq true
    end
  end



  describe "#relative_url_root" do
    subject { presenter.relative_url_root }
    it { is_expected.to eq '' } # this is true for test, in dev or prod it would be equal to '/data'
  end

  describe "#model_name" do
    subject { presenter.model_name }

    it { is_expected.to be_kind_of ActiveModel::Name }
  end

  describe '#manifest_url' do
    subject { presenter.manifest_url }

    it { is_expected.to eq 'http://example.org/concern/data_sets/888888/manifest' }
  end


  #   describe '#iiif_viewer?' do
  #     let(:id_present) { false }
  #     let(:representative_presenter) { double('representative', present?: false) }
  #     let(:image_boolean) { false }
  #     let(:iiif_enabled) { false }
  #     let(:file_set_presenter) { Hyrax::FileSetPresenter.new(solr_document, ability) }
  #     let(:file_set_presenters) { [file_set_presenter] }
  #     let(:read_permission) { true }
  #
  #     before do
  #       allow(presenter).to receive(:representative_id).and_return(id_present)
  #       allow(presenter).to receive(:representative_presenter).and_return(representative_presenter)
  #       allow(presenter).to receive(:file_set_presenters).and_return(file_set_presenters)
  #       allow(file_set_presenter).to receive(:image?).and_return(true)
  #       allow(ability).to receive(:can?).with(:read, solr_document.id).and_return(read_permission)
  #       allow(representative_presenter).to receive(:image?).and_return(image_boolean)
  #       allow(Hyrax.config).to receive(:iiif_image_server?).and_return(iiif_enabled)
  #     end
  #
  #     subject { presenter.iiif_viewer? }
  #
  #     context 'with no representative_id' do
  #       it { is_expected.to be false }
  #     end
  #
  #     context 'with no representative_presenter' do
  #       let(:id_present) { true }
  #
  #       it { is_expected.to be false }
  #     end
  #
  #     context 'with non-image representative_presenter' do
  #       let(:id_present) { true }
  #       let(:representative_presenter) { double('representative', present?: true) }
  #       let(:image_boolean) { true }
  #
  #       it { is_expected.to be false }
  #     end
  #
  #     context 'with IIIF image server turned off' do
  #       let(:id_present) { true }
  #       let(:representative_presenter) { double('representative', present?: true) }
  #       let(:image_boolean) { true }
  #       let(:iiif_enabled) { false }
  #
  #       it { is_expected.to be false }
  #     end
  #
  #     context 'with representative image and IIIF turned on' do
  #       let(:id_present) { true }
  #       let(:representative_presenter) { double('representative', present?: true) }
  #       let(:image_boolean) { true }
  #       let(:iiif_enabled) { true }
  #
  #       it { is_expected.to be true }
  #
  #       context "when the user doesn't have permission to view the image" do
  #         let(:read_permission) { false }
  #
  #         it { is_expected.to be false }
  #       end
  #     end
  #   end
  #
  #   describe '#stats_path' do
  #     let(:user) { 'sarah' }
  #     let(:ability) { double "Ability" }
  #     let(:work) { build(:generic_work, id: '123abc') }
  #     let(:attributes) { work.to_solr }
  #
  #     before do
  #       # https://github.com/samvera/active_fedora/issues/1251
  #       allow(work).to receive(:persisted?).and_return(true)
  #     end
  #
  #     it { expect(presenter.stats_path).to eq Hyrax::Engine.routes.url_helpers.stats_work_path(id: work, locale: 'en') }
  #   end
  #
  #   describe '#itemtype' do
  #     let(:work) { build(:generic_work, resource_type: type) }
  #     let(:attributes) { work.to_solr }
  #     let(:ability) { double "Ability" }
  #
  #     subject { presenter.itemtype }
  #
  #     context 'when resource_type is Audio' do
  #       let(:type) { ['Audio'] }
  #
  #       it do
  #         is_expected.to eq 'http://schema.org/AudioObject'
  #       end
  #     end
  #
  #     context 'when resource_type is Conference Proceeding' do
  #       let(:type) { ['Conference Proceeding'] }
  #
  #       it { is_expected.to eq 'http://schema.org/ScholarlyArticle' }
  #     end
  #   end
  #
  #   describe 'admin users' do
  #     let(:user)    { create(:user) }
  #     let(:ability) { Ability.new(user) }
  #     let(:attributes) do
  #       {
  #           "read_access_group_ssim" => ["public"],
  #           'id' => '99999'
  #       }
  #     end
  #
  #     before { allow(user).to receive_messages(groups: ['admin', 'registered']) }
  #
  #     context 'with a new public work' do
  #       it 'can feature the work' do
  #         allow(user).to receive(:can?).with(:create, FeaturedWork).and_return(true)
  #         expect(presenter.work_featurable?).to be true
  #         expect(presenter.display_feature_link?).to be true
  #         expect(presenter.display_unfeature_link?).to be false
  #       end
  #     end
  #
  #     context 'with a featured work' do
  #       before { FeaturedWork.create(work_id: attributes.fetch('id')) }
  #       it 'can unfeature the work' do
  #         expect(presenter.work_featurable?).to be true
  #         expect(presenter.display_feature_link?).to be false
  #         expect(presenter.display_unfeature_link?).to be true
  #       end
  #     end
  #
  #     describe "#editor?" do
  #       subject { presenter.editor? }
  #
  #       it { is_expected.to be true }
  #     end
  #   end
  #
  #   describe '#tweeter' do
  #     let(:user) { instance_double(User, user_key: 'user_key') }
  #
  #     subject { presenter.tweeter }
  #
  #     it 'delegates the depositor as the user_key to TwitterPresenter.twitter_handle_for' do
  #       expect(Hyrax::TwitterPresenter).to receive(:twitter_handle_for).with(user_key: user_key)
  #       subject
  #     end
  #   end
  #
  #   describe "#permission_badge" do
  #     let(:badge) { instance_double(Hyrax::PermissionBadge) }
  #
  #     before do
  #       allow(Hyrax::PermissionBadge).to receive(:new).and_return(badge)
  #     end
  #     it "calls the PermissionBadge object" do
  #       expect(badge).to receive(:render)
  #       presenter.permission_badge
  #     end
  #   end
  #
  #   describe "#work_presenters" do
  #     let(:obj) { create(:work_with_file_and_work) }
  #     let(:attributes) { obj.to_solr }
  #
  #     it "filters out members that are file sets" do
  #       expect(presenter.work_presenters.size).to eq 1
  #       expect(presenter.work_presenters.first).to be_instance_of(described_class)
  #     end
  #   end
  #
  #   describe "#member_presenters" do
  #     let(:obj) { create(:work_with_file_and_work) }
  #     let(:attributes) { obj.to_solr }
  #
  #     it "returns appropriate classes for each" do
  #       expect(presenter.member_presenters.size).to eq 2
  #       expect(presenter.member_presenters.first).to be_instance_of(Hyrax::FileSetPresenter)
  #       expect(presenter.member_presenters.last).to be_instance_of(described_class)
  #     end
  #   end
  #
  #   describe "#file_set_presenters" do
  #     let(:obj) { create(:work_with_ordered_files) }
  #     let(:attributes) { obj.to_solr }
  #
  #     it "displays them in order" do
  #       expect(presenter.file_set_presenters.map(&:id)).to eq obj.ordered_member_ids
  #     end
  #
  #     context "solr query" do
  #       before do
  #         expect(ActiveFedora::SolrService).to receive(:query).twice.with(anything, hash_including(rows: 10_000)).and_return([])
  #       end
  #
  #       it "requests >10 rows" do
  #         presenter.file_set_presenters
  #       end
  #     end
  #
  #     context "when some of the members are not file sets" do
  #       let(:another_work) { create(:work) }
  #
  #       before do
  #         obj.ordered_members << another_work
  #         obj.save!
  #       end
  #
  #       it "filters out members that are not file sets" do
  #         expect(presenter.file_set_presenters.map(&:id)).not_to include another_work.id
  #       end
  #     end
  #   end
  #
  #   describe "#representative_presenter" do
  #     let(:obj) { create(:work_with_representative_file) }
  #     let(:attributes) { obj.to_solr }
  #
  #     it "has a representative" do
  #       expect(Hyrax::PresenterFactory).to receive(:build_for)
  #                                              .with(ids: [obj.members[0].id],
  #                                                    presenter_class: Hyrax::CompositePresenterFactory,
  #                                                    presenter_args: [ability, request])
  #                                              .and_return ["abc"]
  #       expect(presenter.representative_presenter).to eq("abc")
  #     end
  #
  #     context 'without a representative' do
  #       let(:obj) { create(:work) }
  #
  #       it 'has a nil presenter' do
  #         expect(presenter.representative_presenter).to be_nil
  #       end
  #     end
  #
  #     context 'when it is its own representative' do
  #       let(:obj) { create(:work) }
  #
  #       before do
  #         obj.representative_id = obj.id
  #         obj.save
  #       end
  #
  #       it 'has a nil presenter; avoids infinite loop' do
  #         expect(presenter.representative_presenter).to be_nil
  #       end
  #     end
  #   end
  #
  #   describe "#download_url" do
  #     subject { presenter.download_url }
  #
  #     let(:solr_document) { SolrDocument.new(work.to_solr) }
  #
  #     context "with a representative" do
  #       let(:work) { create(:work_with_representative_file) }
  #
  #       it { is_expected.to eq "http://#{request.host}/downloads/#{work.representative_id}" }
  #     end
  #
  #     context "without a representative" do
  #       let(:work) { create(:work) }
  #
  #       it { is_expected.to eq '' }
  #     end
  #   end

  describe '#page_title' do
    subject { presenter.page_title }

    it { is_expected.to eq 'Data Set | foo | ID: 888888 | DataCORE' }
  end

  #   describe "#valid_child_concerns" do
  #     subject { presenter }
  #
  #     it "delegates to the class attribute of the model" do
  #       allow(DataSet).to receive(:valid_child_concerns).and_return([DataSet])
  #
  #       expect(subject.valid_child_concerns).to eq [DataSet]
  #     end
  #   end
  #
  #   describe "#attribute_to_html" do
  #     let(:renderer) { double('renderer') }
  #
  #     context 'with an existing field' do
  #       before do
  #         allow(Hyrax::Renderers::AttributeRenderer).to receive(:new)
  #                                                           .with(:title, ['foo', 'bar'], {})
  #                                                           .and_return(renderer)
  #       end
  #
  #       it "calls the AttributeRenderer" do
  #         expect(renderer).to receive(:render)
  #         presenter.attribute_to_html(:title)
  #       end
  #     end
  #
  #     context "with a field that doesn't exist" do
  #       it "logs a warning" do
  #         expect(Rails.logger).to receive(:warn).with('Hyrax::WorkShowPresenter attempted to render restrictions, but no method exists with that name.')
  #         presenter.attribute_to_html(:restrictions)
  #       end
  #     end
  #   end
  #
  #   context "with workflow" do
  #     let(:user) { create(:user) }
  #     let(:ability) { Ability.new(user) }
  #     let(:entity) { instance_double(Sipity::Entity) }
  #
  #     describe "#workflow" do
  #       subject { presenter.workflow }
  #
  #       it { is_expected.to be_kind_of Hyrax::WorkflowPresenter }
  #     end
  #   end
  #
  #   context "with inspect_work" do
  #     let(:user) { create(:user) }
  #     let(:ability) { Ability.new(user) }
  #
  #     describe "#inspect_work" do
  #       subject { presenter.inspect_work }
  #
  #       it { is_expected.to be_kind_of Hyrax::InspectWorkPresenter }
  #     end
  #   end
  #
  #   describe "graph export methods" do
  #     let(:graph) do
  #       RDF::Graph.new.tap do |g|
  #         g << [RDF::URI('http://example.com/1'), RDF::Vocab::DC.title, 'Test title']
  #       end
  #     end
  #
  #     let(:exporter) { double }
  #
  #     before do
  #       allow(Hyrax::GraphExporter).to receive(:new).and_return(exporter)
  #       allow(exporter).to receive(:fetch).and_return(graph)
  #     end
  #
  #     describe "#export_as_nt" do
  #       subject { presenter.export_as_nt }
  #
  #       it { is_expected.to eq "<http://example.com/1> <http://purl.org/dc/terms/title> \"Test title\" .\n" }
  #     end
  #
  #     describe "#export_as_ttl" do
  #       subject { presenter.export_as_ttl }
  #
  #       it { is_expected.to eq "\n<http://example.com/1> <http://purl.org/dc/terms/title> \"Test title\" .\n" }
  #     end
  #
  #     describe "#export_as_jsonld" do
  #       subject { presenter.export_as_jsonld }
  #
  #       it do
  #         is_expected.to eq '{
  #   "@context": {
  #     "dc": "http://purl.org/dc/terms/"
  #   },
  #   "@id": "http://example.com/1",
  #   "dc:title": "Test title"
  # }'
  #       end
  #     end
  #   end
  #
  #   describe "#manifest" do
  #     let(:work) { create(:work_with_one_file) }
  #     let(:solr_document) { SolrDocument.new(work.to_solr) }
  #
  #     describe "#sequence_rendering" do
  #       subject do
  #         presenter.sequence_rendering
  #       end
  #
  #       before do
  #         Hydra::Works::AddFileToFileSet.call(work.file_sets.first,
  #                                             File.open(fixture_path + '/world.png'), :original_file)
  #       end
  #
  #       it "returns a hash containing the rendering information" do
  #         work.rendering_ids = [work.file_sets.first.id]
  #         expect(subject).to be_an Array
  #       end
  #     end
  #
  #     describe "#manifest_metadata" do
  #       subject do
  #         presenter.manifest_metadata
  #       end
  #
  #       before do
  #         work.title = ['Test title', 'Another test title']
  #       end
  #
  #       it "returns an array of metadata values" do
  #         expect(subject[0]['label']).to eq('Title')
  #         expect(subject[0]['value']).to include('Test title', 'Another test title')
  #       end
  #     end
  #   end



end
