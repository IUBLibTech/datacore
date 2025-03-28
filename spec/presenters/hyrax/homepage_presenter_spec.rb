require 'rails_helper'

RSpec.describe Hyrax::HomepagePresenter do
  let(:user) { FactoryBot.create :user }
  let(:current_ability) { instance_double(Ability, current_user: user ) }
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:collections) { Hyrax::CollectionSearchBuilder.new(self).rows(1) }
  subject{ described_class.new(current_ability, collections) }


  describe "#create_work_presenter" do
    it 'is a SelectTypeListPresenter' do

      expect(subject.create_work_presenter).to be_kind_of Hyrax::SelectTypeListPresenter
    end
  end

end
