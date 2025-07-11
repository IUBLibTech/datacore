require 'rails_helper'

RSpec.describe Hyrax::DataSetsController do
  render_views
  let(:main_app) { Rails.application.routes.url_helpers }
  let(:hyrax) { Hyrax::Engine.routes.url_helpers }
  let(:user) { FactoryBot.create(:admin) } # FIXME: enable access for depositor?
  let(:pending_doi) { Deepblue::DoiBehavior::DOI_PENDING }
  let(:minted_doi) { 'doi:10.82028/18sn-h641' }
  let(:data_set) { FactoryBot.create(:data_set, user: user, doi: nil) }
  let(:data_set_with_one_file) { FactoryBot.create(:data_set_with_one_file, user: user, doi: nil) }

  before do
    sign_in user
  end

  describe "#show" do
    it "renders show page" do
      get :show, params: { id: data_set.id }
      expect(response).to render_template(:show)
    end
  end

  shared_examples "doi_mint! behavior" do |flash_type, flash_match|
    it "redirects to the work" do
      expect(response).to redirect_to(main_app.hyrax_data_set_path(data_set, locale: :en))
    end
    it "flashes :#{flash_type} message matching #{flash_match}" do
      expect(flash[flash_type]).to be_a String
      expect(flash[flash_type]).to match flash_match
    end
  end

  describe "#doi" do
    before(:each) do
      allow(Datacore::DoiMintingService).to receive(:enabled?).and_return(true)
    end
    context "when minting is disabled" do
      before(:each) do
        allow(Datacore::DoiMintingService).to receive(:enabled?).and_return(false)
        post :doi, params: { id: data_set.id }
      end
      include_examples "doi_mint! behavior", :alert, /disabled/
    end
    context "when minting is in progress" do
      before(:each) do
        data_set.doi = pending_doi; data_set.save!
        post :doi, params: { id: data_set.id }
      end
      include_examples "doi_mint! behavior", :notice, /currently/
    end
    context "when minting is already done" do
      before(:each) do
        data_set.doi = minted_doi; data_set.save!
        post :doi, params: { id: data_set.id }
      end
      include_examples "doi_mint! behavior", :alert, /already/
    end
    context "when missing files" do
      before(:each) do
        expect(data_set.file_sets.count).to eq 0
        post :doi, params: { id: data_set.id }
      end
      include_examples "doi_mint! behavior", :alert, /files/
    end
    context "when invalid metadata" do
      let(:data_set) { data_set_with_one_file }
      before(:each) do
        data_set.title = nil; data_set.save(validate: false)
        post :doi, params: { id: data_set.id }
      end
      include_examples "doi_mint! behavior", :alert, /metadata/
    end
    context "when user lacks rights", skip: 'authorization check prevents condition from arising' do
      let(:data_set) { data_set_with_one_file }
      before(:each) do
        allow_any_instance_of(Ability).to receive(:admin?).and_return(false)
        post :doi, params: { id: data_set.id }
      end
      include_examples "doi_mint! behavior", :alert, /access/
    end
    context "when user has rights" do
      let(:data_set) { data_set_with_one_file }
      context "and minting succeeds" do
        before(:each) do
          allow_any_instance_of(data_set.class).to receive(:doi_mint).and_return(true)
          post :doi, params: { id: data_set.id }
        end
        include_examples "doi_mint! behavior", :notice, /started/
      end
      context "and minting fails" do
        before(:each) do
          allow_any_instance_of(data_set.class).to receive(:doi_mint).and_return(false)
          post :doi, params: { id: data_set.id }
        end
        include_examples "doi_mint! behavior", :error, /error/
      end
    end
  end
end
