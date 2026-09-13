require 'rails_helper'

RSpec.describe Hyrax::EmbargoService do

  describe '#assets_with_expired_embargoes' do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "" ]
      allow(Hyrax::ExpiredEmbargoSearchBuilder).to receive(:new).with(Hyrax::EmbargoService).and_return "builder"
      allow(Hyrax::RestrictionService).to receive(:presenters).with "builder"
    }

    it "calls bold_debug and RestrictionService.presenters with new ExpiredEmbargoSearchBuilder" do
      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "" ]
      expect(Hyrax::ExpiredEmbargoSearchBuilder).to receive(:new).with(Hyrax::EmbargoService).and_return "builder"
      expect(Hyrax::RestrictionService).to receive(:presenters).with "builder"
      Hyrax::EmbargoService.assets_with_expired_embargoes
    end
  end


  describe "#assets_under_embargo" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "" ]
      allow(Hyrax::EmbargoSearchBuilder).to receive(:new).with(Hyrax::EmbargoService).and_return "builder"
      allow(Hyrax::RestrictionService).to receive(:presenters).with "builder"
    }

    it "calls bold_debug and RestrictionService.presenters with new EmbargoSearchBuilder" do
      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "" ]
      expect(Hyrax::EmbargoSearchBuilder).to receive(:new).with(Hyrax::EmbargoService).and_return "builder"
      expect(Hyrax::RestrictionService).to receive(:presenters).with "builder"
      Hyrax::EmbargoService.assets_under_embargo
    end
  end


  describe "#assets_with_deactivated_embargoes" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "" ]
      allow(Hyrax::DeactivatedEmbargoSearchBuilder).to receive(:new).with(Hyrax::EmbargoService).and_return "builder"
      allow(Hyrax::RestrictionService).to receive(:presenters).with "builder"
    }

    it "calls bold_debug and RestrictionService.presenters with new DeactivatedEmbargoSearchBuilder" do
      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "" ]
      expect(Hyrax::DeactivatedEmbargoSearchBuilder).to receive(:new).with(Hyrax::EmbargoService).and_return "builder"
      expect(Hyrax::RestrictionService).to receive(:presenters).with "builder"
      Hyrax::EmbargoService.assets_with_deactivated_embargoes
    end
  end


  describe "#my_assets_with_expired_embargoes" do
    builder = OpenStruct.new(current_user_key: "")
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "" ]
      allow(Hyrax::My::ExpiredEmbargoSearchBuilder).to receive(:new).with(Hyrax::EmbargoService).and_return builder
      allow(Hyrax::RestrictionService).to receive(:presenters).with builder
    }

    it "calls bold_debug and RestrictionService.presenters with new My::ExpiredEmbargoSearchBuilder" do
      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "" ]
      expect(Hyrax::My::ExpiredEmbargoSearchBuilder).to receive(:new).with(Hyrax::EmbargoService).and_return builder
      expect(Hyrax::RestrictionService).to receive(:presenters).with builder
      Hyrax::EmbargoService.my_assets_with_expired_embargoes("current user key")
    end
  end


  describe "#my_assets_under_embargo" do
    embargo_builder = OpenStruct.new(current_user_key: "")
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "" ]
      allow(Hyrax::My::EmbargoSearchBuilder).to receive(:new).with(Hyrax::EmbargoService).and_return embargo_builder
      allow(Hyrax::RestrictionService).to receive(:presenters).with embargo_builder
    }

    it "calls bold_debug and RestrictionService.presenters with new My::EmbargoSearchBuilder" do
      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "" ]
      expect(Hyrax::My::EmbargoSearchBuilder).to receive(:new).with(Hyrax::EmbargoService).and_return embargo_builder
      expect(Hyrax::RestrictionService).to receive(:presenters).with embargo_builder
      Hyrax::EmbargoService.my_assets_with_expired_embargoes("current user key")
    end
  end


  describe "#my_assets_with_deactivated_embargoes" do
    emb_builder = OpenStruct.new(current_user_key: "")
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "" ]
      allow(Hyrax::My::DeactivatedEmbargoSearchBuilder).to receive(:new).with(Hyrax::EmbargoService).and_return emb_builder
      allow(Hyrax::RestrictionService).to receive(:presenters).with emb_builder
    }

    it "calls bold_debug and RestrictionService.presenters with new My::DeactivatedEmbargoSearchBuilder" do
      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "" ]
      expect(Hyrax::My::DeactivatedEmbargoSearchBuilder).to receive(:new).with(Hyrax::EmbargoService).and_return emb_builder
      expect(Hyrax::RestrictionService).to receive(:presenters).with emb_builder
      Hyrax::EmbargoService.my_assets_with_deactivated_embargoes("current user key")
    end
  end


  # private method

  describe "#presenter_class" do
    it "returns Hyrax::EmbargoPresenter" do
      expect(Hyrax::EmbargoService.send(:presenter_class)).to eq Hyrax::EmbargoPresenter
    end
  end

end
