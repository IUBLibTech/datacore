require 'rails_helper'

# class AgentMock
#   def initialize(workflow_responsibilities)
#     @workflow_responsibilities = workflow_responsibilities
#   end
#
#   def workflow_responsibilities
#     @workflow_responsibilities if @workflow_responsibilities
#   end
# end
#
# class WorkflowResponsibilityMock
#   def initialize(workflow_role)
#     @workflow_role = workflow_role
#   end
#
#   def workflow_role
#     @workflow_role if @workflow_role
#   end
# end

class WorkflowRoleMock
   def workflow
     OpenStruct.new(permission_template: OpenStruct.new(source_id: "X"))
   end

   def role
   end
end

RSpec.describe Hyrax::Admin::WorkflowRolesPresenter::AgentPresenter do

  describe '#responsibilities_present?' do

    context "when there are workflow responsibilities" do
      let(:agent) { double(workflow_responsibilities: [1,2])  }
      subject{ described_class.new(agent) }

      it "returns true" do
        expect(subject.responsibilities_present?).to eq true
      end
    end

    context "when there are no workflow responsibilities" do
      let(:agent) { double(workflow_responsibilities: [])  }
      subject{ described_class.new(agent) }

      it "returns false" do
        expect(subject.responsibilities_present?).to eq false
      end
    end
  end


  describe "#responsibilities" do

    context "when there are workflow responsibilities" do

      it "returns ResponsibilityPresenters" do
        skip "Add a test"
      end
    end
  end


end
