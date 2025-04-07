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

  describe "delegates methods to solr_document:" do
    [:stringify_keys, :human_readable_type, :collection?, :representative_id, :to_s, :title, :description, :creator, :contributor,
     :subject, :publisher, :keyword, :language, :embargo_release_date, :lease_expiration_date, :license, :date_created, :resource_type,
     :based_near, :related_url, :identifier, :thumbnail_path, :title_or_label, :collection_type_gid, :create_date, :modified_date,
     :visibility, :edit_groups, :edit_people].each do
    |method|
      it "#{method}" do
        expect(subject).to delegate_method(method).to(:solr_document)
      end
    end
  end

  pending "#delegate collection_type_settings_methods"
  pending "#collection_type"
  pending "#self.terms"
  pending "#terms_with_values"
  pending "#[]"


  describe "#display_provenance_log_enabled?" do
    it "returns true" do
      expect(subject.display_provenance_log_enabled?).to eq true
    end
  end

  pending "#provenance_log_entries?"
  pending "#relative_url_root"


  describe "#size" do
    it "returns bytes as descriptive string" do
      expect(subject.size).to eq "123 Bytes"
    end
  end

  pending "#total_items"
  pending "#total_viewable_items"
  pending "#total_viewable_works"
  pending "#total_viewable_collections"


  describe "#collection_type_badge" do
    before {
      allow(subject).to receive(:collection_type).and_return( double(title: 'Example of Grandiosity') )
    }
    it "returns collection_type.title" do
      expect(subject.collection_type_badge).to eq 'Example of Grandiosity'
    end
  end

  describe "#total_parent_collections" do
    context "when parent_collections is nil" do
      before {
        allow(subject).to receive(:parent_collections).and_return( nil )
      }
      it "returns 0" do
        expect(subject.total_parent_collections).to eq 0
      end
    end

    context "when parent_collections exists" do
      before {
        allow(subject).to receive(:parent_collections).and_return( double( response: {"numFound" => 7} ) )
      }
      it "returns parent_collections response numFound" do
        expect(subject.total_parent_collections).to eq 7
      end
    end
  end

  describe "#parent_collection_count" do
    context "when parent_collections is nil" do
      before {
        allow(subject).to receive(:parent_collections).and_return( nil )
      }
      it "returns 0" do
        expect(subject.parent_collection_count).to eq 0
      end
    end

    context "when parent_collections exists" do
      before {
        allow(subject).to receive(:parent_collections).and_return( double(documents: ['1', '2', '3', '4', '5']) )
      }
      it "returns parent_collections documents size" do
        expect(subject.parent_collection_count).to eq 5
      end
    end
  end

  pending "#user_can_nest_collection?"
  pending "#user_can_create_new_nest_collection?"
  pending "#show_path"


  describe "#banner_file" do
    context "when id has a value" do
      before {
        allow(subject).to receive(:id).and_return( 5 )
        allow(subject).to receive(:branding_banner_file).with(id: 5).and_return( "method result" )
      }
      it "returns branding_banner_file(id)" do
        expect(subject.banner_file).to eq "method result"
      end
    end
  end

  describe "#logo_record" do
    context "when id has a value" do
      before {
        allow(subject).to receive(:id).and_return( 12 )
        allow(subject).to receive(:branding_logo_record).with(id: 12).and_return( "method result" )
      }
      it "returns branding_logo_record(id)" do
        expect(subject.logo_record).to eq "method result"
      end
    end
  end

  describe "#create_work_presenter" do
    it "returns SelectTypeListPresenter" do
      expect(subject.create_work_presenter).to be_kind_of Hyrax::SelectTypeListPresenter
    end
  end

  describe "#create_many_work_types" do
    context "when Flipflop.only_use_data_set_work_type? returns true" do
      it "returns false" do
        skip "Add test here"
      end
    end

    context "when Flipflop.only_use_data_set_work_type? returns false" do
      it "returns create_work_presenter.many?" do
        skip "Add test here"
      end
    end
  end

  describe "#draw_select_work_modal?" do
    context "when create_many_work_types? returns true" do
      before {
        allow(subject).to receive(:create_many_work_types?).and_return(true)
      }
      it "returns true" do
        expect(subject.draw_select_work_modal?).to eq true
      end
    end

    context "when create_many_work_types? returns false" do
      before {
        allow(subject).to receive(:create_many_work_types?).and_return(false)
      }
      it "returns false" do
        expect(subject.draw_select_work_modal?).to eq false
      end
    end
  end

  describe "#first_work_type" do
    context "when create_work_presenter has authorized models" do
      before {
        allow(subject.create_work_presenter).to receive(:authorized_models).and_return(["Alpha", "Beta"])
      }
      it "returns first authorized model" do
        expect(subject.first_work_type).to eq "Alpha"
      end
    end
  end

  pending "#available_parent_collections"


  describe "#subcollection_count=" do
    context "when total is nil" do
      it "returns 0" do
        expect(subject.subcollection_count).to eq 0
      end
    end

    context "when total has a value" do
      it "returns total value" do
        expect(subject.subcollection_count = 99).to eq 99
      end
    end
  end

  pending "#managed_access"
  pending "#allow_batch?"

end
