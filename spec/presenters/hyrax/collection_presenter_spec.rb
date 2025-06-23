require 'rails_helper'

class ViewableItemMock
  def initialize(items)
    @items = items
  end
  def accessible_by(current_ability)
    @items
  end
end

class ItemMock
  def initialize(can)
    @can = can
  end
  def can?(*args)
    @can
  end
end

RSpec.describe Hyrax::CollectionPresenter do
  let(:user) { FactoryBot.create :user }
  let(:solr_document) { SolrDocument.new }
  let(:current_ability) { instance_double(Ability, current_user: user ) }
  let(:request) { double(host: 'example.org', base_url: 'http://example.org') }

  subject{ described_class.new(solr_document, current_ability, request) }

  describe '#create_work_presenter_class' do
    it do
      expect(Hyrax::HomepagePresenter.create_work_presenter_class).instance_of?(Hyrax::SelectTypeListPresenter)
    end
  end

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

  describe "#initialize" do
    it "sets instance variables" do
      subject.instance_variable_get(:@solr_document) == "solr"
      subject.instance_variable_get(:@current_ability) == "current"
      subject.instance_variable_get(:@request) == "request"
      subject.instance_variable_get(:@subcollection_count) == 0
    end
  end


  pending "#delegate collection_type_settings_methods"


  describe "#collection_type" do
    before {
      allow(Hyrax::CollectionType).to receive(:find_by_gid!).with("collection type gid").and_return "collection type"
    }

    context "@collection_type has a value" do
      before {
        subject.instance_variable_set(:@collection_type, "assemblage")
      }
      it "returns @collection_type" do
        expect(subject.collection_type).to eq "assemblage"

        expect(Hyrax::CollectionType).not_to have_received(:find_by_gid!)
      end
    end

    context "@collection_type has no value" do
      before {
        subject.instance_variable_set(:@collection_type, nil)
        allow(subject).to receive(:collection_type_gid).and_return "collection type gid"
      }
      it "returns Hyrax::CollectionType.find_by_gid!" do
        expect(Hyrax::CollectionType).to receive(:find_by_gid!).with("collection type gid")

        expect(subject.collection_type).to eq "collection type"
      end
    end
  end


  pending "#self.terms"
  pending "#terms_with_values"


  describe "#[]" do
    context "when key is :size" do
      before {
        allow(subject).to receive(:size).and_return "sizing"
      }
      it "returns result of size" do
        expect(subject[:size]).to eq "sizing"
      end
    end

    context "when key is :total_items" do
      before {
        allow(subject).to receive(:total_items).and_return "totality"
      }
      it "result of total_items" do
        expect(subject[:total_items]).to eq "totality"
      end
    end

    context "when key is not :size or :total_items" do
      before {
        allow(subject.solr_document).to receive(:send).with(:other).and_return "sending"
      }
      it "calls solr_document.send" do
        expect(subject[:other]).to eq "sending"
      end
    end
  end

  describe "#display_provenance_log_enabled?" do
    it "returns true" do
      expect(subject.display_provenance_log_enabled?).to eq true
    end
  end

  # NOTE:  provenance_log_entries? function exactly the same in ds_file_set_presenter
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

  # NOTE:  relative_url_root function exactly the same in ds_file_set_presenter, work_show_presenter
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

  describe "#size" do
    before {
      subject.instance_variable_set(:@solr_document, {'bytes_lts' => 123})
      allow(subject).to receive(:number_to_human_size).with(123).and_return "123 KB"
    }
    it "calls number_to_human_size" do
      expect(subject).to receive(:number_to_human_size)
      expect(subject.size).to eq "123 KB"
    end
  end

  describe "#total_items" do
    before {
      allow(subject).to receive(:id).and_return "XY-101"
      allow(ActiveFedora::Base).to receive(:where).with( "member_of_collection_ids_ssim:XY-101" ).and_return ["mallard", "wood duck", "Canada goose"]
    }
    it "calls ActiveFedora::Base.where" do
      expect(ActiveFedora::Base).to receive(:where)
      expect(subject.total_items).to eq 3
    end
  end

  describe "#total_viewable_items" do
    before {
      allow(subject).to receive(:id).and_return "XY-102"
      allow(subject).to receive(:current_ability).and_return "current ability"
      allow(ActiveFedora::Base).to receive(:where).with( "member_of_collection_ids_ssim:XY-102" )
                                                  .and_return ViewableItemMock.new ['watermelon', 'honeydew', 'cantaloupe', 'muskmelon']
    }
    it "calls ActiveFedora::Base.where" do
      expect(ActiveFedora::Base).to receive(:where)
      expect(subject.total_viewable_items).to eq 4
    end
  end

  describe "#total_viewable_works" do
    before {
      allow(subject).to receive(:id).and_return "XY-103"
      allow(subject).to receive(:current_ability).and_return "current ability"

      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "from"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                    "from",
                                                                    "id=XY-103",
                                                                    "current_ability=current ability",
                                                                    ""]
      allow(ActiveFedora::Base).to receive(:where).with( "member_of_collection_ids_ssim:XY-103 AND generic_type_sim:Work" )
                                                  .and_return ViewableItemMock.new ['a', 'b', 'c', 'd', 'e', 'f']
    }
    it "calls Deepblue::LoggingHelper.bold_debug and ActiveFedora::Base.where" do
      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                    "from",
                                                                    "id=XY-103",
                                                                    "current_ability=current ability",
                                                                    ""]
      expect(ActiveFedora::Base).to receive(:where)

      expect(subject.total_viewable_works).to eq 6
    end
  end

  describe "#total_viewable_collections" do
    before {
      allow(subject).to receive(:id).and_return "XY-104"
      allow(subject).to receive(:current_ability).and_return "current ability"

      allow(ActiveFedora::Base).to receive(:where).with( "member_of_collection_ids_ssim:XY-104 AND generic_type_sim:Collection" )
                                                  .and_return ViewableItemMock.new ['latte', 'mocha', 'affogatto']
    }
    it "calls ActiveFedora::Base.where" do
      expect(ActiveFedora::Base).to receive(:where).with( "member_of_collection_ids_ssim:XY-104 AND generic_type_sim:Collection" )

      expect(subject.total_viewable_collections).to eq 3
    end
  end

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

  describe "#user_can_nest_collection?" do
    before {
      allow(subject).to receive(:solr_document).and_return( "solr" )      
      allow(subject).to receive(:current_ability).and_return ItemMock.new true
    }
    it "calls current_ability.can?" do
      expect(subject.user_can_nest_collection?).to eq true
    end
  end

  describe "#user_can_create_new_nest_collection?" do
    before {
      allow(subject).to receive(:collection_type).and_return( "color" )
      allow(subject).to receive(:current_ability).and_return ItemMock.new true
    }
    it "calls current_ability.can?" do
      expect(subject.user_can_create_new_nest_collection?).to eq true
    end
  end

  describe "#show_path" do
    before {
      allow(subject).to receive(:id).and_return( "Z-50" )
      # Could not stub Hyrax::Engine.routes.url_helpers.dashboard_collection_path -- actually calling it
    }
    it "calls Hyrax::Engine.routes.url_helpers.dashboard_collection_path" do
      expect(subject.show_path).to eq "/dashboard/collections/Z-50"
    end
  end

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
        allow(subject).to receive(:branding_logo_record).with(id: 12).and_return( "logo record" )
      }
      it "returns branding_logo_record(id)" do
        expect(subject.logo_record).to eq "logo record"
      end
    end
  end

  describe "#create_work_presenter" do

    context "when @create_work_presenter has a value" do
      before {
        subject.instance_variable_set(:@create_work_presenter, "instance variable")
      }
      it "returns value" do
        expect(subject.create_work_presenter_class).not_to receive(:new)
        expect(subject.create_work_presenter).to eq "instance variable"
      end
    end

    context "when @create_work_presenter has no value" do
      before {
        allow(subject.create_work_presenter_class).to receive(:new).with(user).and_return "new method"
      }
      it "calls create_work_presenter_class.new and sets instance variable" do
        expect(subject.create_work_presenter_class).to receive(:new)
        expect(subject.create_work_presenter).to eq "new method"

        subject.instance_variable_get(:@create_work_presenter) == "new method"
      end
    end
  end

  describe "#create_many_work_types?" do
    context "when Flipflop.only_use_data_set_work_type? returns true" do
      before {
        allow(Flipflop).to receive(:only_use_data_set_work_type?).and_return true
      }
      it "returns false" do
        expect(Flipflop).to receive(:only_use_data_set_work_type?)
        expect(subject.create_work_presenter).not_to receive(:many?)

        expect(subject.create_many_work_types?).to eq false
      end
    end

    context "when Flipflop.only_use_data_set_work_type? returns false" do
      before {
        allow(Flipflop).to receive(:only_use_data_set_work_type?).and_return false
        allow(subject.create_work_presenter).to receive(:many?).and_return true
      }
      it "returns create_work_presenter.many?" do
        expect(Flipflop).to receive(:only_use_data_set_work_type?)
        expect(subject.create_work_presenter).to receive(:many?)

        expect(subject.create_many_work_types?).to eq true
      end
    end
  end

  describe "#draw_select_work_modal?" do
    before {
      allow(subject).to receive(:create_many_work_types?).and_return(true)
    }
    it "calls create_many_work_types?" do
      expect(subject).to receive(:create_many_work_types?)

      expect(subject.draw_select_work_modal?).to eq true
    end
  end

  describe "#first_work_type" do
    context "when create_work_presenter calls first_model" do
      before {
        allow(subject.create_work_presenter).to receive(:first_model).and_return "Alpha"
      }
      it "returns first_model" do
        expect(subject.create_work_presenter).to receive(:first_model)

        expect(subject.first_work_type).to eq "Alpha"
      end
    end
  end

  describe "#available_parent_collections" do
    context "when @available_parents present" do
      before {
        subject.instance_variable_set(:@available_parents, "presentation")
      }
      it "returns @available_parents" do
        expect(subject.available_parent_collections scope: "").to eq "presentation"
      end
    end

    context "when @available_parents not present" do
      before {
        allow(subject).to receive(:id).and_return 707
        allow(Collection).to receive(:find).with(707).and_return "la collection"
        allow(Hyrax::Collections::NestedCollectionQueryService).to receive(:available_parent_collections).with(child: "la collection", scope: "scope", limit_to_id: nil).
          and_return [OpenStruct.new(id: 1, title: ["pancake", "flapjack"]), OpenStruct.new(id: 2, title: ["crepe", "tortilla"])]
      }
      it "sets @available_parents and return as json" do
        expect(Collection).to receive(:find)
        expect(Hyrax::Collections::NestedCollectionQueryService).to receive(:available_parent_collections).with(child: "la collection", scope: "scope", limit_to_id: nil)

        expect(subject.available_parent_collections scope: "scope").to eq "[{\"id\":1,\"title_first\":\"pancake\"},{\"id\":2,\"title_first\":\"crepe\"}]"
        subject.instance_variable_get(:@available_parents) == [{"id" => 1, "title_first" => "pancake"}, {"id" => 2, "title_first" => "crepe"}]
      end
    end
  end

  describe "#subcollection_count=" do
    context "when total is nil" do
      it "returns nil" do
        expect(subject.subcollection_count = nil).to be_nil

        subject.instance_variable_get(:@subcollection_count) == 0
      end
    end

    context "when total has a value" do
      it "returns total value and sets instance variable" do
        expect(subject.subcollection_count = 99).to eq 99

        subject.instance_variable_get(:@subcollection_count) == 99
      end
    end
  end

  describe "#managed_access" do
    before {
      allow(I18n).to receive(:t).with('hyrax.dashboard.my.collection_list.managed_access.manage').and_return "managed"
      allow(I18n).to receive(:t).with('hyrax.dashboard.my.collection_list.managed_access.deposit').and_return "deposited"
      allow(I18n).to receive(:t).with('hyrax.dashboard.my.collection_list.managed_access.view').and_return "viewed"
    }

    context "when can edit" do
      before {
        allow(subject.current_ability).to receive(:can?).with(:edit, solr_document).and_return true
      }
      it "return manage access" do
        expect(I18n).to receive(:t).with('hyrax.dashboard.my.collection_list.managed_access.manage')
        expect(I18n).not_to receive(:t).with('hyrax.dashboard.my.collection_list.managed_access.deposit')
        expect(I18n).not_to receive(:t).with('hyrax.dashboard.my.collection_list.managed_access.view')

        expect(subject.managed_access).to eq "managed"
      end
    end

    context "when can deposit but not edit" do
      before {
        allow(subject.current_ability).to receive(:can?).with(:edit, solr_document).and_return false
        allow(subject.current_ability).to receive(:can?).with(:deposit, solr_document).and_return true
      }
      it "return deposit access" do
        expect(I18n).not_to receive(:t).with('hyrax.dashboard.my.collection_list.managed_access.manage')
        expect(I18n).to receive(:t).with('hyrax.dashboard.my.collection_list.managed_access.deposit')
        expect(I18n).not_to receive(:t).with('hyrax.dashboard.my.collection_list.managed_access.view')

        expect(subject.managed_access).to eq "deposited"
      end
    end

    context "when can read but not edit or deposit" do
      before {
        allow(subject.current_ability).to receive(:can?).with(:edit, solr_document).and_return false
        allow(subject.current_ability).to receive(:can?).with(:deposit, solr_document).and_return false
        allow(subject.current_ability).to receive(:can?).with(:read, solr_document).and_return true
      }
      it "return view access" do
        expect(I18n).not_to receive(:t).with('hyrax.dashboard.my.collection_list.managed_access.manage')
        expect(I18n).not_to receive(:t).with('hyrax.dashboard.my.collection_list.managed_access.deposit')
        expect(I18n).to receive(:t).with('hyrax.dashboard.my.collection_list.managed_access.view')

        expect(subject.managed_access).to eq "viewed"
      end
    end

    context "when no access" do
      before {
        allow(subject.current_ability).to receive(:can?).with(:edit, solr_document).and_return false
        allow(subject.current_ability).to receive(:can?).with(:deposit, solr_document).and_return false
        allow(subject.current_ability).to receive(:can?).with(:read, solr_document).and_return false
      }
      it "return empty string" do
        expect(I18n).not_to receive(:t).with('hyrax.dashboard.my.collection_list.managed_access.manage')
        expect(I18n).not_to receive(:t).with('hyrax.dashboard.my.collection_list.managed_access.deposit')
        expect(I18n).not_to receive(:t).with('hyrax.dashboard.my.collection_list.managed_access.view')

        expect(subject.managed_access).to be_blank
      end
    end
  end

  describe "#allow_batch?" do
    context "when current_ability.can? returns true" do
      before {
        allow(subject).to receive(:current_ability).and_return ItemMock.new true
      }
      it "return true" do
        expect(subject.allow_batch?).to eq true
      end
    end

    context "when current_ability.can? returns false" do
      before {
        allow(subject).to receive(:current_ability).and_return ItemMock.new false
      }
      it "return false" do
        expect(subject.allow_batch?).to eq false
      end
    end
  end
end
