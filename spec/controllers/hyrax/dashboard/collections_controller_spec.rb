require 'rails_helper'

RSpec.describe Hyrax::Dashboard::CollectionsController do
  let(:subject) { described_class.new }
  let(:collection) { FactoryBot.create(:collection_lw) }

  describe 'constants' do
    it do
      expect( Hyrax::Dashboard::CollectionsController::EVENT_NOTE ).to eq 'Hyrax::Dashboard::CollectionsController'
      expect( Hyrax::Dashboard::CollectionsController::PARAMS_KEY ).to eq 'collection'
    end
  end

  pending "#after_create"

  pending "#destroy"

  pending "#show"

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

  pending "#process_banner_input"

  pending "#update_existing_banner"

  pending "#add_new_banner"

  pending "#remove_banner"

end
