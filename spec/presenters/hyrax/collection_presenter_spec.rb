require 'rails_helper'

RSpec.describe Hyrax::CollectionPresenter do
  let(:user) { FactoryBot.create :user }

  let(:attributes) do
    { "bytes_lts" => '123' }
  end
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:current_ability) { instance_double(Ability, current_user: user ) }
  let(:request) { double(host: 'example.org', base_url: 'http://example.org') }

  subject{ described_class.new(solr_document, current_ability, request) }

  it { is_expected.to delegate_method(:stringify_keys).to(:solr_document) }
  it { is_expected.to delegate_method(:human_readable_type).to(:solr_document) }
  it { is_expected.to delegate_method(:collection?).to(:solr_document) }
  it { is_expected.to delegate_method(:representative_id).to(:solr_document) }
  it { is_expected.to delegate_method(:to_s).to(:solr_document) }

  it { is_expected.to delegate_method(:title).to(:solr_document) }
  it { is_expected.to delegate_method(:description).to(:solr_document) }
  it { is_expected.to delegate_method(:creator).to(:solr_document) }
  it { is_expected.to delegate_method(:contributor).to(:solr_document) }
  it { is_expected.to delegate_method(:subject).to(:solr_document) }
  it { is_expected.to delegate_method(:publisher).to(:solr_document) }
  it { is_expected.to delegate_method(:keyword).to(:solr_document) }
  it { is_expected.to delegate_method(:contributor).to(:solr_document) }
  it { is_expected.to delegate_method(:language).to(:solr_document) }
  it { is_expected.to delegate_method(:embargo_release_date).to(:solr_document) }
  it { is_expected.to delegate_method(:lease_expiration_date).to(:solr_document) }
  it { is_expected.to delegate_method(:license).to(:solr_document) }
  it { is_expected.to delegate_method(:date_created).to(:solr_document) }
  it { is_expected.to delegate_method(:resource_type).to(:solr_document) }
  it { is_expected.to delegate_method(:based_near).to(:solr_document) }
  it { is_expected.to delegate_method(:related_url).to(:solr_document) }
  it { is_expected.to delegate_method(:identifier).to(:solr_document) }
  it { is_expected.to delegate_method(:thumbnail_path).to(:solr_document) }
  it { is_expected.to delegate_method(:title_or_label).to(:solr_document) }
  it { is_expected.to delegate_method(:collection_type_gid).to(:solr_document) }
  it { is_expected.to delegate_method(:create_date).to(:solr_document) }
  it { is_expected.to delegate_method(:modified_date).to(:solr_document) }
  it { is_expected.to delegate_method(:visibility).to(:solr_document) }
  it { is_expected.to delegate_method(:edit_groups).to(:solr_document) }
  it { is_expected.to delegate_method(:edit_people).to(:solr_document) }

  describe "#size" do
    it "returns bytes as descriptive string" do
      expect(subject.size).to eq "123 Bytes"
    end
  end

  describe "#collection_type_badge" do
    it "returns collection_type.title" do

      allow(subject).to receive(:collection_type).and_return( double(title: 'Example of Grandiosity') )
      expect(subject.collection_type_badge).to eq 'Example of Grandiosity'
    end
  end

  describe "#total_parent_collections" do
    it "returns parent_collections response numFound" do

      allow(subject).to receive(:parent_collections).and_return( double( response: {"numFound" => 7} ) )
      expect(subject.total_parent_collections).to eq 7
    end
  end

  describe "#parent_collection_count" do
    it "returns parent_collections documents size" do

      allow(subject).to receive(:parent_collections).and_return( double(documents: ['1', '2', '3', '4', '5']) )
      expect(subject.parent_collection_count).to eq 5
    end
  end



  describe "#create_work_presenter" do
    it "returns SelectTypeListPresenter" do
      expect(subject.create_work_presenter).to be_kind_of Hyrax::SelectTypeListPresenter
    end
  end

  describe "#draw_select_work_modal?" do

    it "returns true" do
      allow(subject).to receive(:create_many_work_types?).and_return(true)
      expect(subject.draw_select_work_modal?).to eq true
    end

    it "returns false" do
      allow(subject).to receive(:create_many_work_types?).and_return(false)
      expect(subject.draw_select_work_modal?).to eq false
    end
  end

  describe "#first_work_type" do
    it "returns first string in list" do

      allow(subject.create_work_presenter).to receive(:authorized_models).and_return(["Alpha", "Beta"])
      expect(subject.first_work_type).to eq "Alpha"
    end
  end




end
