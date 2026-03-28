class BehaviorMock
  include Deepblue::EmbargoableBehavior
  include Deepblue::ProvenanceBehavior

  def initialize
    @visibility = nil
    @visibility_during_embargo = nil
    @visibility_after_embargo = nil
    @visibility_during_lease = nil
    @visibility_after_lease = nil
  end

  def embargo
  end

  def visibility
    "visibility"
  end

  def visibility=(text)
    @visibility = text
  end

  def visibility_during_embargo=(text)
    @visibility_during_embargo = text
  end

  def visibility_after_embargo=(text)
    @visibility_after_embargo = text
  end

  def visibility_during_lease=(text)
    @visibility_during_lease = text
  end

  def visibility_after_lease=(text)
    @visibility_after_lease = text
  end

  def visibility_during_embargo
  end

  def provenance_unembargo(current_user:, embargo_visibility:, embargo_visibility_after:)
  end

  def visibility_after_embargo
  end

  def visibility_will_change!
  end

  def lease
  end

  def visibility_after_lease
  end

  def visibility_during_lease
  end

  def embargo_release_date
  end

  def under_embargo?
    false
  end

  def lease_expiration_date
  end

  def active_lease?
    false
  end
end

class EmbargoMock

  def deactivate!
  end
end

class MockLease
  def deactivate!
  end

  def visibility
  end
end


RSpec.describe Deepblue::EmbargoableBehavior do
  subject { BehaviorMock.new }

  describe "#deactivate_embargo!" do
    context "when embargo is nil" do
      before {
        allow(subject).to receive(:embargo).and_return nil
      }
      it "returns nil" do
        expect(subject.deactivate_embargo!).to be_blank
      end
    end

    context "when embargo has a value" do
      embargo = EmbargoMock.new
      before {
        allow(subject).to receive(:visibility_after_embargo_default).and_return "embargo after default"
        allow(subject).to receive(:provenance_unembargo).with(current_user: "Deepblue", embargo_visibility: "visibility", embargo_visibility_after: "embargo after default")

        allow(subject).to receive(:embargo).and_return embargo
        allow(embargo).to receive(:deactivate!)
      }

      context "when visibility_after_embargo returns nil" do
        before {
          allow(subject).to receive(:visibility_after_embargo).and_return nil
        }
        it "calls visibility_after_embargo_default and visibility_will_change!" do
          expect(subject).to receive(:visibility_after_embargo_default)
          expect(subject).to receive(:provenance_unembargo).with(current_user: "Deepblue", embargo_visibility: "visibility", embargo_visibility_after: "embargo after default")
          expect(subject).to receive(:visibility_will_change!)

          subject.deactivate_embargo!
          subject.instance_variable_get(:@visibility) == "embargo after default"
        end
      end

      context "when visibility_after_embargo returns a value" do
        before {
          allow(subject).to receive(:visibility_after_embargo).and_return "visibility after embargo"
        }
        it "calls visibility_will_change!" do
          expect(subject).not_to receive(:visibility_after_embargo_default)
          expect(subject).to receive(:provenance_unembargo).with(current_user: "Deepblue", embargo_visibility: "visibility", embargo_visibility_after: "visibility after embargo")
          expect(subject).to receive(:visibility_will_change!)

          subject.deactivate_embargo!
          subject.instance_variable_get(:@visibility) == "visibility after embargo"
        end
      end

      after {
        expect(subject).to have_received(:visibility_after_embargo)
        expect(embargo).to have_received(:deactivate!)
      }
    end
  end


  describe "#deactivate_lease!" do
    context "when lease is nil" do
      before {
        allow(subject).to receive(:lease).and_return nil
      }
      it "returns nil" do
        expect(subject.deactivate_lease!).to be_blank
      end
    end

    context "when lease has a value" do
      lease = MockLease.new
      before {
        allow(subject).to receive(:lease).and_return lease
        allow(subject).to receive(:visibility_after_lease_default).and_return "lease default"
        allow(lease).to receive(:deactivate!)
        allow(subject).to receive(:visibility_will_change!)
      }

      context "when visibility_after_lease returns nil" do
        before {
          allow(subject).to receive(:visibility_after_lease).and_return nil
        }
        it "calls visibility_after_lease_default and visibility_will_change!" do
          expect(subject).to receive(:visibility_after_lease)
          expect(subject).to receive(:visibility_after_lease_default)
          expect(lease).to receive(:deactivate!)
          expect(subject).to receive(:visibility_will_change!)

          subject.deactivate_lease!

          subject.instance_variable_get(:@visibility) == "visibility after lease"
        end
      end

      context "when visibility_after_lease returns a value" do
        before {
          allow(subject).to receive(:visibility_after_lease).and_return "visibility after lease"
        }
        it "calls visibility_will_change!" do
          expect(subject).to receive(:visibility_after_lease)
          expect(subject).not_to receive(:visibility_after_lease_default)
          expect(lease).to receive(:deactivate!)
          expect(subject).to receive(:visibility_will_change!)

          subject.deactivate_lease!

          subject.instance_variable_get(:@visibility) == "lease default"
        end
      end
    end
  end

  describe "#embargo_visibility" do
    context "when embargo_release_date has no value" do
      it "returns nil" do
        expect(subject.embargo_visibility!).to be_blank
      end
    end

    context "when embargo_release_date has a value" do
      before {
        allow(subject).to receive(:embargo_release_date).and_return "embargo release date"
      }

      context "when under_embargo? is true" do
        before {
          allow(subject).to receive(:under_embargo?).and_return true
        }

        context "when visibility_during_embargo has value" do
          before {
            allow(subject).to receive(:visibility_during_embargo).and_return "embargo during"
          }

          it "sets @visibility_during_embargo to visibility_during_embargo" do
            subject.embargo_visibility!
            subject.instance_variable_get(:@visibility_during_embargo) == "embargo during"
          end

          it "sets @visibility to visibility_during_embargo" do
            subject.embargo_visibility!
            subject.instance_variable_get(:@visibility) == "embargo during"
          end
        end

        context "when visibility_during_embargo has no value" do
          before {
            allow(subject).to receive(:visibility_during_embargo_default).and_return "embargo during default"
          }
          it "sets @visibility_during_embargo to visibility_during_embargo_default" do
            subject.embargo_visibility!
            subject.instance_variable_get(:@visibility_during_embargo) == "embargo during default"
          end

          it "sets @visibility to nil" do
            subject.embargo_visibility!
            subject.instance_variable_get(:@visibility).blank? == true
          end
        end


        context "when visibility_after_embargo has a value" do
          before {
            allow(subject).to receive(:visibility_after_embargo).and_return "embargo after"
          }
          it "sets @visibility_after_embargo to visibility_after_embargo" do
            subject.embargo_visibility!
            subject.instance_variable_get(:@visibility_after_embargo) == "embargo after"
          end
        end

        context "when visibility_after_embargo has no value" do
          before {
            allow(subject).to receive(:visibility_after_embargo_default).and_return "embargo after default"
          }
          it "sets @visibility_after_embargo to visibility_after_embargo_default" do
            subject.embargo_visibility!
            subject.instance_variable_get(:@visibility_after_embargo) == "embargo after default"
          end
         end
      end


      context "when under_embargo? is false" do
        context "when visibility_after_embargo has no value" do
          before {
            allow(subject).to receive(:visibility_after_embargo_default).and_return "embargo after default"
          }
          it "sets @visibility to visibility_after_embargo_default" do
            subject.embargo_visibility!
            subject.instance_variable_get(:@visibility) == "embargo after default"
          end
        end

        context "when visibility_after_embargo has a value" do
          before {
            allow(subject).to receive(:visibility_after_embargo).and_return "prohibition restriction interdiction"
          }
          it "sets @visibility to visibility_after_embargo" do
            subject.embargo_visibility!
            subject.instance_variable_get(:@visibility) == "prohibition restriction interdiction"
          end
        end

      end
    end
  end


  describe "#lease_visibility!" do
    context "when lease_expiration_date has no value" do
      it "returns nil" do
        expect(subject.lease_visibility!).to be_blank
      end
    end

    context "when lease_expiration_date has a value" do
      before {
        allow(subject).to receive(:lease_expiration_date).and_return "lease expiration date"
      }

      context "when active lease" do
        before {
          allow(subject).to receive(:active_lease?).and_return true
          allow(subject).to receive(:visibility_during_lease_default).and_return "visibility during lease default"
          allow(subject).to receive(:visibility_after_lease_default).and_return "visibility after lease default"
        }

        context "when visibility_during_lease has a value" do
          before {
            allow(subject).to receive(:visibility_during_lease).and_return "visibility during lease"
          }

          it "sets @visibility to visibility_during_lease" do
            subject.lease_visibility!
            subject.instance_variable_get(:@visibility) == "visibility during lease"
          end

          it "sets @visibility_during_lease to visibility_during_lease" do
            subject.lease_visibility!
            subject.instance_variable_get(:@visibility_during_lease) == "visibility during lease"
          end
        end

        context "when visibility_during_lease does not have a value" do
          it "sets @visibility to nil" do
            subject.lease_visibility!
            subject.instance_variable_get(:@visibility).blank? == true
          end

          it "sets @visibility_during_lease to visibility_during_lease_default" do
            subject.lease_visibility!
            subject.instance_variable_get(:@visibility_during_lease) == "visibility during lease default"
          end
        end

        context "when visibility_after_lease has a value" do
          before {
            allow(subject).to receive(:visibility_after_lease).and_return "visibility after lease"
          }

          it "sets @visibility to visibility_after_lease" do
            subject.lease_visibility!
            subject.instance_variable_get(:@visibility_after_lease) == "visibility after lease"
          end
        end

        context "when visibility_after_lease has no value" do
          it "sets @visibility to visibility_after_lease_default" do
            subject.lease_visibility!
            subject.instance_variable_get(:@visibility_after_lease) == "visibility after lease default"
          end
        end
      end

      context "when no active lease" do
        context "when visibility_after_lease has a value" do
          before {
            allow(subject).to receive(:visibility_after_lease).and_return "visibility after lease"
          }
          it "sets @visibility to visibility_after_lease" do
            subject.lease_visibility!
            subject.instance_variable_get(:@visibility) == "visibility after lease"
          end
        end

        context "when visibility_after_lease has no value" do
          before {
            allow(subject).to receive(:visibility_after_lease_default).and_return "visibility after lease default"
          }
          it "sets @visibility to visibility_after_lease_default" do
            subject.lease_visibility!
            subject.instance_variable_get(:@visibility) == "visibility after lease default"
          end
        end
      end
    end
  end


  describe "#visibility_after_embargo_default" do
    before {
      allow(::DeepBlueDocs::Application.config).to receive(:embargo_visibility_after_default_status).and_return "status"
    }
    it "calls DeepBlueDocs::Application.config.embargo_visibility_after_default_status" do
      expect(subject.visibility_after_embargo_default).to eq "status"
    end
  end

  describe "#visibility_after_lease_default" do
    it "calls ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE" do
      expect(subject.visibility_after_lease_default).to eq "restricted"
    end
  end

  describe "#visibility_during_embargo_default" do
    it "calls ::DeepBlueDocs::Application.config.embargo_visibility_during_default_status" do
      expect(subject.visibility_during_embargo_default).to eq "restricted"
    end
  end

  describe "#visibility_during_lease_default" do
    it "calls ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED" do
      expect(subject.visibility_during_embargo_default).to eq "restricted"
    end
  end

end
