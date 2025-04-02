require 'rails_helper'

describe Hyrax::Forms::Admin::CollectionTypeParticipantForm do

  let(:collection_type_participant) { instance_double(Hyrax::CollectionTypeParticipant) }

  it "delegates" do

    is_expected.to delegate_method(:agent_id).to(:collection_type_participant)

  end




end
