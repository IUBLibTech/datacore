require 'rails_helper'

class MockCollection
  def provenance_log_update_after(current_user:, event_note:, update_attr_key_values:)
  end

  def provenance_log_update_before(form_params:)
  end

  def private?
  end

  def public?
  end
end

class MockCollectionsControllerBehavior
  include Deepblue::CollectionsControllerBehavior
  def current_user  # supplied by controller that includes Deepblue::CollectionsControllerBehavior
    "current_user"
  end

  # from app/controllers/hyrax/dashboard/collections_controller.rb
  def curation_concern
  end
  def default_event_note
    'Hyrax::Dashboard::CollectionsController'
  end
  def params
    { "collection" => "collected" }
  end
end

class MockCollectionsControllerParams
  include Deepblue::CollectionsControllerBehavior

  def curation_concern
  end

  def params
  end
end





RSpec.describe Deepblue::CollectionsControllerBehavior do

  subject { MockCollectionsControllerBehavior.new }

  describe "#provenance_log_update_after" do
    mock_collection = MockCollection.new
    before {
      subject.instance_variable_set :@update_attr_key_values, "update"
      allow(subject).to receive(:curation_concern).and_return mock_collection
    }
    it "calls curation_concern.provenance_log_update_after" do
      expect(mock_collection).to receive(:provenance_log_update_after).with(current_user: "current_user",
                                                                                    event_note: "Hyrax::Dashboard::CollectionsController",
                                                                                    update_attr_key_values: "update")
      subject.provenance_log_update_after
    end
  end


  describe "#provenance_log_update_before" do
    context "when instance variable is nil" do
      mock_collection = MockCollection.new
      before {
        allow(subject).to receive(:curation_concern).and_return mock_collection
        allow(mock_collection).to receive(:provenance_log_update_before).with(form_params: "collected").and_return "before then"
      }
      it "calls curation_concern.provenance_log_update_before, sets instance variable and returns value" do
        expect(mock_collection).to receive(:provenance_log_update_before).with(form_params: "collected")
        expect(subject.provenance_log_update_before).to eq "before then"
        expect(subject.instance_variable_get :@update_attr_key_values).to eq "before then"
      end
    end

    context "when instance variable has a value" do
      before {
        subject.instance_variable_set :@update_attr_key_values, "update"
      }
      it "returns nil" do
        expect(subject.provenance_log_update_before).to be_blank
      end
    end
  end


  describe "#visibility_changed" do
    before {
      collection_mock = MockCollection.new
      allow(subject).to receive(:curation_concern).and_return collection_mock
      allow(collection_mock).to receive(:provenance_log_update_before).with(form_params: "collected").and_return "the before times"
    }

    context "when visibility_to_private? is true" do
      before {
        allow(subject).to receive(:visibility_to_private?).and_return true
        allow(subject).to receive(:mark_as_set_to_private)
      }
      it "sets instance variable, calls mark_as_set_to_private" do
        expect(subject).to receive(:mark_as_set_to_private)
        expect(subject).not_to receive(:mark_as_set_to_public)
        subject.visibility_changed
        expect(subject.instance_variable_get :@update_attr_key_values).to eq "the before times"
      end
    end

    context "when visibility_to_private? is false" do
      before {
        allow(subject).to receive(:visibility_to_private?).and_return false
      }

      context "when visibility_to_public? is true" do
        before {
          allow(subject).to receive(:visibility_to_public?).and_return true
          allow(subject).to receive(:mark_as_set_to_public)
        }
        it "sets instance variable, calls mark_as_set_to_public" do
          expect(subject).not_to receive(:mark_as_set_to_private)
          expect(subject).to receive(:mark_as_set_to_public)
          subject.visibility_changed
          expect(subject.instance_variable_get :@update_attr_key_values).to eq "the before times"
        end
      end

      context "when visibility_to_private? and visibility_to_public? are both false" do
        before {
          allow(subject).to receive(:visibility_to_public?).and_return false
        }
        it "sets instance variable" do
          expect(subject).not_to receive(:mark_as_set_to_private)
          expect(subject).not_to receive(:mark_as_set_to_public)
          subject.visibility_changed
          expect(subject.instance_variable_get :@update_attr_key_values).to eq "the before times"
        end
      end
    end
  end


  describe "#visibility_changed_update" do
    c_mock = MockCollection.new
    before {
      allow(subject).to receive(:curation_concern).and_return c_mock
    }
    context "when concern is private" do
      before {
        allow(c_mock).to receive(:private?).and_return true
      }
      context "when @visibility_changed_to_private evaluates positive" do
        before {
          subject.instance_variable_set :@visibility_changed_to_private, true
          allow(subject).to receive(:workflow_unpublish)
        }
        it "calls workflow_unpublish" do
          expect(subject).to receive(:workflow_unpublish)
          expect(subject).not_to receive(:workflow_publish)
          subject.visibility_changed_update
        end
      end

      context "when @visibility_changed_to_private evaluates negative" do
        before {
          subject.instance_variable_set :@visibility_changed_to_private, false
        }
        it "does not call workflow_unpublish" do
          expect(subject).not_to receive(:workflow_unpublish)
          expect(subject).not_to receive(:workflow_publish)
          subject.visibility_changed_update
        end
      end
    end

    context "when concern is not private" do
      before {
        allow(c_mock).to receive(:private?).and_return false
      }
      context "when concern is public" do
        before {
          allow(c_mock).to receive(:public?).and_return true
        }
        context "when @visibility_changed_to_public evaluates positive" do
          before {
            subject.instance_variable_set :@visibility_changed_to_public, true
            allow(subject).to receive(:workflow_publish)
          }
          it "calls workflow_publish" do
            expect(subject).to receive(:workflow_publish)
            expect(subject).not_to receive(:workflow_unpublish)
            subject.visibility_changed_update
          end
        end

        context "when @visibility_changed_to_public evaluates negative" do
          before {
            subject.instance_variable_set :@visibility_changed_to_public, false
          }
          it "does not call workflow_publish" do
            expect(subject).not_to receive(:workflow_publish)
            expect(subject).not_to receive(:workflow_unpublish)
            subject.visibility_changed_update
          end
        end
      end

      context "when concern is not public" do
        before {
          allow(c_mock).to receive(:public?).and_return false
        }
        it "does not call workflow_publish or workflow_unpublish" do
          expect(subject).not_to receive(:workflow_publish)
          expect(subject).not_to receive(:workflow_unpublish)
          subject.visibility_changed_update
        end
      end
    end
  end


  describe "#visibility_to_private?" do
    subject { MockCollectionsControllerParams.new }

    mock_c = MockCollection.new
    before {
      allow(subject).to receive(:curation_concern).and_return mock_c
    }
    context "when concern is private" do
      before {
        allow(mock_c).to receive(:private?).and_return true
      }
      it "returns false" do
        expect(subject.visibility_to_private?).to eq false
      end
    end

    context "when concern is not private" do
      before {
        allow(mock_c).to receive(:private?).and_return false
        allow(subject).to receive(:params).and_return "collection" => { "visibility" => "restricted" }
      }
      it "compares params visibility to 'restricted' and returns result" do
        expect(subject.visibility_to_private?).to eq true
      end
    end
  end


  describe "#visibility_to_public?" do
    subject { MockCollectionsControllerParams.new }

    mock_c = MockCollection.new
    before {
      allow(subject).to receive(:curation_concern).and_return mock_c
    }
    context "when concern is public" do
      before {
        allow(mock_c).to receive(:public?).and_return true
      }
      it "returns false" do
        expect(subject.visibility_to_public?).to eq false
      end
    end

    context "when concern is not public" do
      before {
        allow(mock_c).to receive(:public?).and_return false
        allow(subject).to receive(:params).and_return "collection" => { "visibility" => "open" }
      }
      it "compares params visibility to 'open' and returns result" do
        expect(subject.visibility_to_public?).to eq true
      end
    end
  end


  describe "#mark_as_set_to_private" do
    it "sets instance variables to private" do
      subject.mark_as_set_to_private

      expect(subject.instance_variable_get :@visibility_changed_to_public).to eq false
      expect(subject.instance_variable_get :@visibility_changed_to_private).to eq true
    end
  end


  describe "#mark_as_set_to_public" do
    it "sets instance variables to public" do
      subject.mark_as_set_to_public

      expect(subject.instance_variable_get :@visibility_changed_to_public).to eq true
      expect(subject.instance_variable_get :@visibility_changed_to_private).to eq false
    end
  end

end
