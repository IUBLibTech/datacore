require 'rails_helper'

RSpec.describe Hyrax::WorkflowPresenter do
  let(:user) { FactoryBot.create :user }
  let(:attributes) do {} end
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:current_ability) { instance_double(Ability, current_user: user ) }

  subject { described_class.new(solr_document, current_ability) }

  pending "#initialize"
  pending "#state"

  describe "#state_label" do
    context "state is nil" do
      before {
        allow(subject).to receive(:state).and_return( nil )
      }
      it "returns nil" do
        expect(subject.state_label).blank?
      end
    end

    context "state returns a value" do
      it "returns state label" do
        skip "Add a test"
      end
    end
  end


  describe "#actions" do
    context "sipity_entity && current_ability are nil" do
      before {
        allow(subject).to receive(:sipity_entity).and_return( nil )
        allow(subject).to receive(:current_ability).and_return( nil )
      }
      it "returns an empty array" do
        expect(subject.actions).to be_empty
      end
    end

    context "sipity_entity && current_ability have values" do
      it "returns actions" do
        skip "Add a test"
      end
    end
  end


  describe "#comments" do
    context "sipity_entity is nil" do
      before {
        allow(subject).to receive(:sipity_entity).and_return( nil )
      }
      it "returns an empty array" do
        expect(subject.comments).to be_empty
      end
    end

    context "sipity_entity has value" do
      before {
        allow(subject).to receive(:sipity_entity).and_return( OpenStruct.new(comments: "Some comments") )
      }
      it "returns comments" do
        expect(subject.comments).to eq "Some comments"
      end
    end
  end


  describe "#badge" do
    context "state is nil" do
      before {
        allow(subject).to receive(:state).and_return( nil )
      }
      it "returns nil" do
        expect(subject.badge).to be_nil
      end
    end

    context "state has value" do
      before {
        allow(subject).to receive(:state).and_return( "changeable" )
        allow(subject).to receive(:state_label).and_return( "Good Label:" )
      }
      it "returns HTML span tag" do
        expect(subject.badge).to eq "<span class=\"state state-changeable label label-primary\">Good Label:</span>"
      end
    end
  end

end
