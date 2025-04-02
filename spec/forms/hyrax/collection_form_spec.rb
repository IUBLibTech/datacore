# frozen_string_literal: true

require 'rails_helper'

describe Hyrax::Forms::CollectionForm do

  let(:model) { Collection.new }
  let(:user) { create(:user) }
  let(:ability) { Ability.new(user) }
  let(:config) { Blacklight::Solr::Configuration.new }
  let(:repository) { Blacklight::Solr::Repository.new(:config) }
  let(:subject) { described_class.new(model, ability, repository) }

  it "delegates" do
    is_expected.to delegate_method(:id).to(:model)
    is_expected.to delegate_method(:depositor).to(:model)
    is_expected.to delegate_method(:permissions).to(:model)
    is_expected.to delegate_method(:human_readable_type).to(:model)
    is_expected.to delegate_method(:member_ids).to(:model)
    is_expected.to delegate_method(:nestable?).to(:model)
  end

  describe "#terms" do
    subject { described_class.terms }

    it { is_expected.to eq %i[
      authoremail
      based_near
      collection_type_gid
      contributor
      creator
      date_coverage
      date_created
      description
      fundedby
      grantnumber
      identifier
      keyword
      language
      license
      methodology
      publisher
      referenced_by
      related_url
      representative_id
      resource_type
      rights_license
      subject
      subject_discipline
      thumbnail_id
      title
      visibility
    ] }
  end

end
