class MockActorIntention

  def initialize(wants_embargo)
    @wants_embargo = wants_embargo
  end
  def wants_embargo?
    @wants_embargo
  end
end

class MockCurationErrors

  def initialize()
    @errors = { }
  end

  def add(key, value)
    @errors[key] = value
  end

  def [](key)
    @errors[key]
  end
end



RSpec.describe Hyrax::Actors::InterpretVisibilityActor do

  subject { described_class.new("next actor") }


  describe "#validate_embargo" do

    context "when intention parameter wants_embargo? function returns false" do
      it "returns true" do
        expect(subject.send(:validate_embargo, "env", MockActorIntention.new(false), "attributes", "template")).to eq true
      end
    end

    possibilities = [{"parse_date" => "",                     "release_date" => true,  "embargo_date" => true,  "after_embargo" => true,  "result" => true },
                     {"parse_date" => "date release embargo", "release_date" => true,  "embargo_date" => true,  "after_embargo" => false, "result" => false},
                     {"parse_date" => "",                     "release_date" => true,  "embargo_date" => false, "after_embargo" => true,  "result" => false},
                     {"parse_date" => "date release embargo", "release_date" => false, "embargo_date" => true,  "after_embargo" => true,  "result" => false},
                     {"parse_date" => " ",                    "release_date" => false, "embargo_date" => false, "after_embargo" => false, "result" => false}]

    context "when intention parameter wants_embargo? function returns true" do

      curation_concern_set = OpenStruct.new(curation_concern: OpenStruct.new(errors: MockCurationErrors.new))
      possibilities.each do |possibility|
        context "when valid_embargo_release_date is #{possibility["release_date"]}, valid_template_embargo_date? is #{possibility["embargo_date"]} and valid_template_visibility_after_embargo? is #{possibility["after_embargo"]}" do
          before {
            allow(subject).to receive(:parse_date).with("embargo release date").and_return possibility["parse_date"]

            allow(subject).to receive(:validate_embargo_release_date).with(curation_concern_set, possibility["parse_date"]).and_return possibility["release_date"]
            allow(subject).to receive(:valid_template_embargo_date?).with(curation_concern_set, possibility["parse_date"], "template").and_return possibility["embargo_date"]
            allow(subject).to receive(:valid_template_visibility_after_embargo?).with(curation_concern_set, {:embargo_release_date => "embargo release date" }, "template").and_return possibility["after_embargo"]
          }
          it "returns #{possibility["result"]}" do
            expect(subject).to receive(:parse_date).with("embargo release date").and_return possibility["parse_date"]
            expect(subject).to receive(:validate_embargo_release_date).with(curation_concern_set, possibility["parse_date"])

            if possibility["release_date"]
              expect(subject).to receive(:valid_template_embargo_date?).with(curation_concern_set, possibility["parse_date"], "template")

              if possibility["embargo_date"]
                expect(subject).to receive(:valid_template_visibility_after_embargo?).with(curation_concern_set, {:embargo_release_date => "embargo release date" }, "template")
              else
                expect(subject).not_to receive(:valid_template_visibility_after_embargo?).with(curation_concern_set, {:embargo_release_date => "embargo release date" }, "template")
              end
            else
              expect(subject).not_to receive(:valid_template_embargo_date?).with(curation_concern_set, "date release embargo", "template")
            end

            expect(subject.send(:validate_embargo, curation_concern_set, MockActorIntention.new(true),
                                {:embargo_release_date => "embargo release date" }, "template")).to eq possibility["result"]

            if possibility["result"] == false && possibility["parse_date"].blank?
              expect(curation_concern_set.curation_concern.errors[:visibility]).to eq 'When setting visibility to "embargo" you must also specify embargo release date.'
            end
          end

        end
      end
    end
  end


  describe "#validate_embargo_release_date" do
    context "when embargo_enforce_future_release_date is true" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:embargo_enforce_future_release_date).and_return true
      }

      context "when valid_future_date? returns true" do
        before {
          allow(subject).to receive(:valid_future_date?).with("env", "embargo release date").and_return true
        }
        it "returns true" do
          expect(subject.send(:validate_embargo_release_date, "env", "embargo release date")).to eq true
        end
      end

      context "when valid_future_date? returns false" do
        before {
          allow(subject).to receive(:valid_future_date?).with("env", "embargo release date").and_return false
        }
        it "returns false" do
          expect(subject.send(:validate_embargo_release_date, "env", "embargo release date")).to eq false
        end
      end

      after {
        expect(subject).to have_received(:valid_future_date?).with("env", "embargo release date")
      }
    end

    context "when embargo_enforce_future_release_date is false" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:embargo_enforce_future_release_date).and_return false
      }
      it "returns true" do
        expect(subject).not_to receive(:valid_future_date?).with("env", "embargo release date")

        expect(subject.send(:validate_embargo_release_date, "env", "embargo release date")).to eq true
      end
    end

    after {
      expect(DeepBlueDocs::Application.config).to have_received(:embargo_enforce_future_release_date)
    }
  end


end
