require 'rails_helper'

class MockCurationConcern
  def initialize(started, depositor)
    @started = started
    @depositor = depositor
  end

  def doi_mint(current_user:, event_note:)
    @started
  end

  def depositor()
    @depositor
  end

  def doi_pending?
    false
  end

  def doi_minted?
    false
  end

  def doi_minimum_files?
    true
  end

  def valid?
    true
  end
end



RSpec.describe Hyrax::DataSetsController do

  describe "#doi_minting_enabled?" do
    before {
      allow(Datacore::DoiMintingService).to receive(:enabled?).and_return true
    }
    it "returns result of Datacore::DoiMintingService.enabled?" do
      expect(subject.doi_minting_enabled?).to eq true
    end
  end


  describe "#doi" do
    before {
      allow(subject).to receive(:doi_mint!)
      allow(subject).to receive(:main_app).and_return "main app"
      allow(subject).to receive(:curation_concern).and_return "curation concern"
    }

    context "when it wants to respond to html" do
      before {
        allow(subject).to receive(:doi_mint!)
        allow(subject).to receive(:respond_to).and_return OpenStruct.new(html: true, json: false)
        allow(subject).to receive(:redirect_to).with(["main app", "curation concern"])
      }
      it "calls doi_mint! and redirects" do
        subject.doi
        skip "Add a test for redirect"
      end
    end

    context "when it wants to respond to json" do
      before {
        allow(subject).to receive(:doi_mint!)
        allow(subject).to receive(:respond_to).and_return OpenStruct.new(html: false, json: true)
        allow(subject).to receive(:polymorphic_path).with(["main_app", "curation_concern"]).and_return "poly path"
        allow(subject).to receive(:render).with(:show, status: :ok, location: "poly path")
      }
      it "calls doi_mint! and renders show page" do
        subject.doi
        skip "Add a test for rendering show page"
      end
    end

    after {
      expect(subject).to have_received(:doi_mint!)
      expect(subject).to have_received(:respond_to)
    }
  end




 # private methods

  describe "#doi_mint!" do
    before {
      allow(MsgHelper).to receive(:t).with('data_set.doi_minting_disabled').and_return "disabled message"
      allow(MsgHelper).to receive(:t).with('data_set.doi_is_being_minted').and_return "pending message"
      allow(MsgHelper).to receive(:t).with('data_set.doi_already_exists').and_return "already exists message"
      allow(MsgHelper).to receive(:t).with('data_set.doi_requires_work_with_files').and_return "minimum files required message"
      allow(MsgHelper).to receive(:t).with('data_set.doi_requires_valid_work').and_return "valid work message"
      allow(MsgHelper).to receive(:t).with('data_set.doi_user_without_access').and_return "user access message"
      allow(MsgHelper).to receive(:t).with('data_set.doi_minting_started').and_return "minting started message"
      allow(MsgHelper).to receive(:t).with('data_set.doi_minting_error').and_return "minting error message"
    }

    context "when doi minting disabled" do
      before {
        allow(subject).to receive(:doi_minting_enabled?).and_return false
      }
      it "shows flash alert with disabled message" do
        subject.send(:doi_mint!)
        expect(subject.flash[:alert]).to eq "disabled message"
      end
    end

    context "when doi minting enabled" do
      before {
        allow(subject).to receive(:doi_minting_enabled?).and_return true
      }

      context "when doi pending" do
        before {
          allow(subject).to receive(:curation_concern).and_return OpenStruct.new(doi_pending?: true)
        }
        it "shows flash notice with pending message" do
          subject.send(:doi_mint!)
          expect(subject.flash[:notice]).to eq "pending message"
        end
      end

      context "when doi NOT pending" do
        before {
          allow(subject).to receive(:curation_concern).and_return OpenStruct.new(doi_pending?: false)
        }

        context "when doi minted" do
          before {
            allow(subject).to receive(:curation_concern).and_return OpenStruct.new(doi_minted?: true)
          }
          it "shows alert notice when already exists message" do
            subject.send(:doi_mint!)
            expect(subject.flash[:alert]).to eq "already exists message"
          end
        end

        context "when doi NOT minted" do
          before {
            allow(subject).to receive(:curation_concern).and_return OpenStruct.new(doi_minted?: false)
          }

          context "when minimum files required NOT present" do
            before {
              allow(subject).to receive(:curation_concern).and_return OpenStruct.new(doi_minimum_files?: false)
            }
            it "shows alert with minimum files message" do
              subject.send(:doi_mint!)
              expect(subject.flash[:alert]).to eq "minimum files required message"
            end
          end

          context "when minimum files required are present" do
            before {
              allow(subject).to receive(:curation_concern).and_return OpenStruct.new(doi_minimum_files?: true)
            }

            context "when work is NOT valid" do
              before {
                allow(subject).to receive(:curation_concern).and_return OpenStruct.new(doi_minimum_files?: true, valid?: false)
              }
              it "shows alert with valid work message" do
                subject.send(:doi_mint!)
                expect(subject.flash[:alert]).to eq "valid work message"
              end
            end

            context "when work is valid" do
              current_user = OpenStruct.new(email: "user_email")
              before {
                allow(subject).to receive(:current_user).and_return current_user
              }

              context "when depositor does NOT have user email and user is NOT admin" do
                before {
                  allow(subject).to receive(:curation_concern).and_return OpenStruct.new(doi_minimum_files?: true, valid?: true, depositor: "other_email")
                  allow(subject).to receive(:current_ability).and_return OpenStruct.new(admin?: false)
                }
                it "shows alert with user access message" do
                  subject.send(:doi_mint!)
                  expect(subject.flash[:alert]).to eq "user access message"
                end
              end

              users = [ {:depositor => true, :admin => true},
                        {:depositor => true, :admin => false},
                        {:depositor => false, :admin => true} ]
              users.each do |user|
                context "when depositor #{user[:depositor] ? "has" : "does NOT have"} user email and user is #{user[:admin] ? "" : "NOT"} admin" do
                  before {
                    allow(subject).to receive(:current_ability).and_return OpenStruct.new(admin?: user[:admin])
                  }

                  context "when doi minting started" do
                    before {
                      allow(subject).to receive(:curation_concern).and_return MockCurationConcern.new(true, user[:depositor] ? "user_email" : "other_email")
                    }
                    it "shows notice with minting started message" do
                      subject.send(:doi_mint!)
                      expect(subject.flash[:notice]).to eq "minting started message"
                    end
                  end

                  context "when doi minting NOT started" do
                    before {
                      allow(subject).to receive(:curation_concern).and_return MockCurationConcern.new(false, user[:depositor] ? "user_email" : "other_email")
                    }
                    it "shows error with minting error message" do
                      subject.send(:doi_mint!)
                      expect(subject.flash[:error]).to eq "minting error message"
                    end
                  end
                end
              end
            end
          end
        end
      end

      after {
        expect(subject).to have_received(:curation_concern).at_least(2).at_most(6).times
      }
    end

    after {
      expect(subject).to have_received(:doi_minting_enabled?)
    }
  end

end
