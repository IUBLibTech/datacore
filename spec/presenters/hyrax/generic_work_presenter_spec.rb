# Generated via
#  `rails generate hyrax:work GenericWork`
require 'rails_helper'

RSpec.describe Hyrax::GenericWorkPresenter do
  let(:user) { FactoryBot.create :user }
  let(:attributes) do {} end
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:current_ability) { instance_double(Ability, current_user: user ) }

  subject{ described_class.new(solr_document, current_ability) }

  it { is_expected.to delegate_method(:identifier_orcid).to(:solr_document) }
  it { is_expected.to delegate_method(:academic_affiliation).to(:solr_document) }
  it { is_expected.to delegate_method(:other_affiliation).to(:solr_document) }
  it { is_expected.to delegate_method(:contributor_affiliationumcampus).to(:solr_document) }
  it { is_expected.to delegate_method(:alt_title).to(:solr_document) }
  it { is_expected.to delegate_method(:date_issued).to(:solr_document) }
  it { is_expected.to delegate_method(:identifier_source).to(:solr_document) }
  it { is_expected.to delegate_method(:peerreviewed).to(:solr_document) }
  it { is_expected.to delegate_method(:bibliographic_citation).to(:solr_document) }
  it { is_expected.to delegate_method(:relation_ispartofseries).to(:solr_document) }
  it { is_expected.to delegate_method(:rights_statement).to(:solr_document) }
  it { is_expected.to delegate_method(:type_none).to(:solr_document) }
  it { is_expected.to delegate_method(:language_none).to(:solr_document) }
  it { is_expected.to delegate_method(:description_mapping).to(:solr_document) }
  it { is_expected.to delegate_method(:description_abstract).to(:solr_document) }
  it { is_expected.to delegate_method(:description_sponsorship).to(:solr_document) }
  it { is_expected.to delegate_method(:description).to(:solr_document) }

end
