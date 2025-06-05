require 'rails_helper'

class BannerInfoMock

  def initialize local_path
    @local_path = local_path
  end

  def save (path, verify = true)
  end

  def local_path
    @local_path
  end

  def delete_all
  end
end


RSpec.describe Hyrax::Dashboard::CollectionsController do
  let(:subject) { described_class.new  }

  include Hyrax::BrandingHelper

  describe 'constants' do
    it do
      expect( Hyrax::Dashboard::CollectionsController::EVENT_NOTE ).to eq 'Hyrax::Dashboard::CollectionsController'
      expect( Hyrax::Dashboard::CollectionsController::PARAMS_KEY ).to eq 'collection'
    end
  end

  describe "#after_create" do
    before {
      allow(subject).to receive(:monkey_after_create)
      allow(subject).to receive(:workflow_create)
    }
    it "calls monkey_after_create and workflow_create" do
      expect(subject).to receive(:monkey_after_create)
      expect(subject).to receive(:workflow_create)

      subject.after_create
    end
  end

  describe "#destroy" do
    before {
      allow(subject).to receive(:workflow_destroy)
      allow(subject).to receive(:monkey_destroy)
    }
    it "calls workflow_destroy and monkey_destroy" do
      expect(subject).to receive(:workflow_destroy)
      expect(subject).to receive(:monkey_destroy)

      subject.destroy
    end
  end

  describe "#show" do
    before {
      allow(subject).to receive(:presenter)
      allow(subject).to receive(:query_collection_members)
    }

    context "when @collection.collection_type.brandable? is true" do

      context "when banner_info not empty" do
        before {
          subject.instance_variable_set(:@collection, OpenStruct.new(id: 63, collection_type: OpenStruct.new( brandable?: true ) ))
          allow(subject).to receive(:collection_banner_info).with(id: 63).and_return ["primo", "secundo"]
          allow(subject).to receive(:brand_path).with(collection_branding_info: "primo")
        }
        it "calls collection_banner_info and brand_path" do
          expect(subject).to receive(:collection_banner_info).with(id: 63)
          expect(subject).to receive(:brand_path)

          subject.show
        end
      end

      context "when banner_info empty" do
        before {
          subject.instance_variable_set(:@collection, OpenStruct.new(id: 36, collection_type: OpenStruct.new( brandable?: true ) ))
          allow(subject).to receive(:collection_banner_info).with(id: 36).and_return []
        }
        it "calls collection_banner_info" do
          expect(subject).to receive(:collection_banner_info).with(id: 36)
          expect(subject).not_to receive(:brand_path)
          subject.show
        end
      end
    end

    context "when @collection.collection_type.brandable? is false" do
      before {
        subject.instance_variable_set(:@collection, OpenStruct.new( collection_type: OpenStruct.new( brandable?: false ) ))
      }
      it "calls presenter and query_collection_members functions" do
        expect(subject).not_to receive(:collection_banner_info)
        expect(subject).not_to receive(:brand_path)
        subject.show
      end
    end

    after {
      expect(subject).to have_received(:presenter)
      expect(subject).to have_received(:query_collection_members)
    }
  end

  describe "#curation_concern" do
    before {
      parameters = { :id => "collectibles" }
      allow(subject).to receive(:params).and_return parameters
      allow(ActiveFedora::Base).to receive(:find).with("collectibles").and_return "extensive"
    }

    context "when @collection has value" do
      before {
        subject.instance_variable_set(:@collection, "collection")
      }

      it "returns @collection" do
        expect(ActiveFedora::Base).not_to receive(:find)

        expect(subject.curation_concern).to eq "collection"
      end
    end

    context "when @collection is nil or false" do
      it "calls Base.find and sets @collection to the result" do
        expect(ActiveFedora::Base).to receive(:find)

        expect(subject.curation_concern).to eq "extensive"

        subject.instance_variable_get(:@collection) == "extensive"
      end
    end
  end

  describe "#default_event_note" do
    it "returns string" do
      expect(subject.default_event_note).to eq 'Hyrax::Dashboard::CollectionsController'
    end
  end

  describe "#params_key" do
    it "returns string" do
      expect(subject.params_key).to eq 'collection'
    end
  end

  describe "#process_banner_input" do
    before {
      allow(subject).to receive(:update_existing_banner).and_return "update: existence"
      allow(subject).to receive(:remove_banner)
    }
    context "when banner_unchanged param true" do
      before {
        parameters = {"banner_unchanged" => "true"}
        allow(subject).to receive(:params).and_return parameters
      }
      it "returns update_existing_banner" do
        expect(subject).not_to receive(:remove_banner)
        expect(subject.process_banner_input).to eq "update: existence"
      end
    end

    context "when banner_unchanged param false" do
      context "when banner_files param true" do
        before {
          parameters = {"banner_unchanged" => "false", "banner_files" => true}
          allow(subject).to receive(:params).and_return parameters
          allow(subject).to receive(:add_new_banner).with(true).and_return "new banner day"
        }
        it "returns update_existing_banner" do
          expect(subject).to receive(:add_new_banner).with(true)

          expect(subject.process_banner_input).to eq "new banner day"
        end
      end

      context "when banner_files param false" do
        before {
          parameters = {"banner_unchanged" => "false", "banner_files" => false}
          allow(subject).to receive(:params).and_return parameters
        }
        it "returns update_existing_banner" do
          expect(subject).not_to receive(:add_new_banner)

          expect(subject.process_banner_input).to be_blank
        end
      end

      after {
        expect(subject).not_to have_received(:update_existing_banner)
        expect(subject).to have_received(:remove_banner)
      }
    end
  end


  describe "#update_existing_banner" do
    banner_info1 = BannerInfoMock.new("path1")
    banner_info2 = BannerInfoMock.new("path2")

    before {
      subject.instance_variable_set(:@collection, OpenStruct.new( id: 3000 ))
      allow(subject).to receive(:collection_banner_info).with(id: 3000).and_return [banner_info1, banner_info2]
    }
    it do
      expect(subject).to receive(:collection_banner_info).with( id: 3000 )
      expect(banner_info1).to receive(:save).with("path1", false)

      subject.update_existing_banner
    end
  end


  describe "#add_new_banner" do
    bannerInfo = BannerInfoMock.new "kawaii"
    before {
      subject.instance_variable_set(:@collection, OpenStruct.new( id: 4000 ))

      allow(subject).to receive(:uploaded_files).with("uploaded file ids").and_return [OpenStruct.new(file_url: "kawaii"), OpenStruct.new(file_url: "banzai")]
      allow(File).to receive(:split).with("kawaii").and_return ["konnichiwa", "sayonara"]
      allow(CollectionBrandingInfo).to receive(:new).with(collection_id: 4000, filename: "sayonara", role: "banner", alt_txt: "", target_url: "")
                                                    .and_return bannerInfo

      allow(bannerInfo).to receive(:save).with("kawaii")
    }
    it do
      expect(subject).to receive(:uploaded_files).with("uploaded file ids")
      expect(CollectionBrandingInfo).to receive(:new).with(collection_id: 4000, filename: "sayonara", role: "banner", alt_txt: "", target_url: "")
      expect(bannerInfo).to receive(:save).with("kawaii")

      subject.add_new_banner("uploaded file ids")
    end
  end


  describe "#remove_banner" do
    bannerInfo = BannerInfoMock.new "a to z"

    before {
      subject.instance_variable_set(:@collection, OpenStruct.new( id: 5000 ))

      allow(subject).to receive(:collection_banner_info).with(id: 5000).and_return bannerInfo
      allow(bannerInfo).to receive(:delete_all)
    }
    it do
      expect(subject).to receive(:collection_banner_info).with(id: 5000)
      expect(bannerInfo).to receive(:delete_all)

      subject.remove_banner
    end
  end

end
