require 'rails_helper'

RSpec.describe Hyrax::GenericWorkPresenter do
  let(:user) { FactoryBot.create :user }
  let(:attributes) do {} end
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:current_ability) { instance_double(Ability, current_user: user ) }

  subject { described_class.new(solr_document, current_ability) }

  describe "delegates methods to solr_document:" do
    [:identifier_orcid, :academic_affiliation, :other_affiliation, :contributor_affiliationumcampus, :alt_title, :date_issued,
     :identifier_source, :peerreviewed, :bibliographic_citation, :relation_ispartofseries, :rights_statement, :type_none,
     :language_none, :description_mapping, :description_abstract, :description_sponsorship, :description].each do
    |method|
      it "#{method}" do
        expect(subject).to delegate_method(method).to(:solr_document)
      end
    end
  end

end
