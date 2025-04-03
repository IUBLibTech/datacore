require 'rails_helper'

RSpec.describe Hyrax::WorkflowPresenter do
  let(:user) { FactoryBot.create :user }
  let(:attributes) do {} end
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:current_ability) { instance_double(Ability, current_user: user ) }

  subject { described_class.new(solr_document, current_ability) }

  it "has tests" do
    skip "Add your tests here"
  end

end