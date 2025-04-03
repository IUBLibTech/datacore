require 'rails_helper'

describe Hyrax::Forms::Admin::CollectionTypeParticipantForm do

  let(:collection_type_participant) { instance_double(Hyrax::CollectionTypeParticipant) }


  describe "delegates methods to collection_type_participant:" do
    [:agent_id, :agent_type, :access, :hyrax_collection_type_id].each do
    |method|
      it "#{method}" do
        expect(subject).to delegate_method(method).to(:collection_type_participant)
      end
    end
  end

end
