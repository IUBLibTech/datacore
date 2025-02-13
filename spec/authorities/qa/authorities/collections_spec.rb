require 'rails_helper'

RSpec.describe Qa::Authorities::Collections do
  subject(:service) { described_class.new }
  let(:controller) { Qa::TermsController.new }
  let(:user1) { FactoryBot.build(:user) }

  let!(:collection1) do
    FactoryBot.build(:collection_lw,
                     title: ['foo bar'],
                     user: user1,
                     with_solr_document: true)
  end

  let!(:collection2) do
    FactoryBot.build(:collection_lw,
                     title: ['foo'],
                     user: user1,
                     with_solr_document: true)
  end

  before do
    allow(controller).to receive(:params).and_return(params)
    allow(controller).to receive(:current_user).and_return(user1)
  end

  describe '#search' do
    context 'with partial starting term' do
      let(:params) { ActionController::Parameters.new(q: 'fo') }

      it 'lists collection' do
        expect(service.search(nil, controller))
          .to contain_exactly(include(id: collection1.id), include(id: collection2.id))
      end
    end

    context 'with partial middle term' do
      let(:params) { ActionController::Parameters.new(q: 'ba') }

      it 'lists collection' do
        expect(service.search(nil, controller))
          .to contain_exactly(include(id: collection1.id))
      end
    end

    context 'with full term' do
      let(:params) { ActionController::Parameters.new(q: 'foo bar') }

      it 'lists collection' do
        expect(service.search(nil, controller))
          .to contain_exactly(include(id: collection1.id))
      end
    end

    context 'with unmatched term' do
      let(:params) { ActionController::Parameters.new(q: 'deadbeef') }

      it 'lists nothing' do
        expect(service.search(nil, controller))
          .to match_array ([])
      end
    end

    context 'with too short term' do
      let(:params) { ActionController::Parameters.new(q: 'f') }

      it 'lists nothing' do
        expect(service.search(nil, controller))
          .to match_array ([])
      end
    end

    context 'with no term' do
      let(:params) { ActionController::Parameters.new() }

      it 'lists everything' do
        expect(service.search(nil, controller))
          .to include(include(id: collection1.id), include(id: collection2.id))
      end
    end
  end
end
