require 'rails_helper'

RSpec.describe Hyrax::AdminSetPresenter do
  let(:user) { FactoryBot.create :user }

  let(:user_key) { 'a_user_key' }
  let(:attributes) do {} end

  let(:solr_document) { SolrDocument.new(attributes) }
  let(:current_ability) { instance_double(Ability, current_user: user ) }
  let(:request) { double(host: 'example.org', base_url: 'http://example.org') }

  subject{ described_class.new(solr_document, current_ability, request) }

  describe "#any_items?" do
    context "when items exist" do
      before {
        allow(subject).to receive(:total_items).and_return(5)
      }
      it 'returns true' do
        expect(subject.any_items?).to eq true
      end
    end

    context "when items do not exist" do
      before {
        allow(subject).to receive(:total_items).and_return(0)
      }
      it 'returns false' do
        expect(subject.any_items?).to eq false
      end
    end
  end

  pending "#total_items"
  pending "#total_viewable_items"
  pending "#disable_delete?"
  pending "#disabled_message"
  pending "#collection_type"
  pending "#show_path"

  describe "#available_parent_collections" do
    it 'returns empty array' do
      expect(subject.available_parent_collections).to be_empty
    end
  end

  pending "#managed_access"
  pending "#allow_batch?"

end
