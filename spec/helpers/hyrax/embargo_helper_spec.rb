class EmbargoHelperMock
  include ::Hyrax::EmbargoHelper

end

class ConcernMockery

  def initialize(embargo)
    @embargo = embargo
    @visibility = "open"
  end

  def visibility()
    @visibility
  end

  def visibility=(value)
    @visibility = value
  end

  def embargo_visibility!()
  end

  def deactivate_embargo!(current_user:)
  end

  def embargo()
    @embargo
  end

  def save!
  end

  def copy_visibility_to_files()
  end

  def id
    "CCID"
  end

  def provenance_unembargo(current_user:, embargo_visibility:, embargo_visibility_after:)
  end
end

class EmbargoMockery

  def save!
  end
end


RSpec.describe Hyrax::EmbargoHelper, type: :helper do

  subject { EmbargoHelperMock.new }

  before {
    allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
    allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
  }

  describe "#asset_embargo_release_date" do
    before {
      allow(Time).to receive(:zone).and_return "UTC"
    }
    it "returns parsed DateTime" do
      expect(subject.asset_embargo_release_date asset: OpenStruct.new(embargo_release_date: "2025-10-15 11:00:00+00:00")).to eq DateTime.new(2025, 10, 15, 11, 00)
    end
  end


  describe "#assets_with_expired_embargoes" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", ""]
    }

    context "when @assets_with_expired_embargoes does NOT have a value" do
      before {
        allow(Hyrax::EmbargoService).to receive(:assets_with_expired_embargoes).and_return "expired embargoed assets"
      }
      it "calls EmbargoService.assets_with_expired_embargoes and sets instance variable" do
        expect(Hyrax::EmbargoService).to receive(:assets_with_expired_embargoes)
        expect(subject.assets_with_expired_embargoes).to eq "expired embargoed assets"
        expect(subject.instance_variable_get(:@assets_with_expired_embargoes)).to eq "expired embargoed assets"
      end
    end

    context "when @assets_with_expired_embargoes has a value" do
      before {
        subject.instance_variable_set(:@assets_with_expired_embargoes, "embargo this asset it's expired")
      }
      it "returns value of instance variable" do
        expect(Hyrax::EmbargoService).not_to receive(:assets_with_expired_embargoes)

        expect(subject.assets_with_expired_embargoes).to eq "embargo this asset it's expired"
      end
    end

    after {
      expect(Deepblue::LoggingHelper).to have_received(:bold_debug).with ["here", "called from", ""]
    }
  end


  describe "#assets_under_embargo" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", ""]
    }

    context "when @assets_under_embargo does NOT have a value" do
      before {
        allow(Hyrax::EmbargoService).to receive(:assets_under_embargo).and_return "under embargo"
      }
      it "calls EmbargoService.assets_under_embargo and sets instance variable" do
        expect(Hyrax::EmbargoService).to receive(:assets_under_embargo)

        expect(subject.assets_under_embargo).to eq "under embargo"
        expect(subject.instance_variable_get(:@assets_under_embargo)).to eq "under embargo"
      end
    end

    context "when @assets_under_embargo has a value" do
      before {
        subject.instance_variable_set(:@assets_under_embargo, "embargoed for now")
      }
      it "returns value of instance variable" do
        expect(Hyrax::EmbargoService).not_to receive(:assets_under_embargo)

        expect(subject.assets_under_embargo).to eq "embargoed for now"
      end
    end

    after {
      expect(Deepblue::LoggingHelper).to have_received(:bold_debug).with ["here", "called from", ""]
    }
  end


  describe "#assets_with_deactivated_embargoes" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", ""]
    }

    context "when @assets_with_deactivated_embargoes does NOT have a value" do
      before {
        allow(Hyrax::EmbargoService).to receive(:assets_with_deactivated_embargoes).and_return "de-activated"
      }
      it "calls EmbargoService.assets_with_deactivated_embargoes and sets instance variable" do
        expect(Hyrax::EmbargoService).to receive(:assets_with_deactivated_embargoes)

        expect(subject.assets_with_deactivated_embargoes).to eq "de-activated"
        expect(subject.instance_variable_get(:@assets_with_deactivated_embargoes)).to eq "de-activated"
      end
    end

    context "when @assets_with_deactivated_embargoes has a value" do
      before {
        subject.instance_variable_set(:@assets_with_deactivated_embargoes, "embargoed no more")
      }
      it "returns value of instance variable" do
        expect(Hyrax::EmbargoService).not_to receive(:assets_with_deactivated_embargoes)

        expect(subject.assets_with_deactivated_embargoes).to eq "embargoed no more"
      end
    end

    after {
      expect(Deepblue::LoggingHelper).to have_received(:bold_debug).with ["here", "called from", ""]
    }
  end


  describe "#about_to_expire_embargo_email" do
    generic = OpenStruct.new(id: 'W222', embargo_release_date: "embargo release date")
    concern = OpenStruct.new(id: "AZ555", title: ["Heading", "SubHeading"], authoremail: "authorexamplecom")
    before {
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with("asset", generic).and_return "object class"
      allow(ActiveFedora::Base).to receive(:find).with("W222").and_return concern
      allow(Deepblue::EmailHelper).to receive(:t).with("hyrax.email.about_to_expire_embargo.subject", expiration_days: 25, title: "HeadingSubHeading" ).and_return "subject"
      allow(subject).to receive(:visibility_on_embargo_deactivation).with(curation_concern: concern).and_return "visibility_on_embargo"
      allow(Deepblue::EmailHelper).to receive(:curation_concern_url).with(curation_concern: concern).and_return "curation concern url"

      allow(Deepblue::EmailHelper).to receive(:t).with("hyrax.email.about_to_expire_embargo.for",
                                                       expiration_days: 25,
                                                       embargo_release_date: "embargo release date",
                                                       title: "HeadingSubHeading",
                                                       id: "AZ555" ).and_return 'body1 '
      allow(Deepblue::EmailHelper).to receive(:t).with("hyrax.email.about_to_expire_embargo.visibility", visibility: "visibility_on_embargo" ).and_return 'body2 '
      allow(Deepblue::EmailHelper).to receive(:t).with("hyrax.email.about_to_expire_embargo.visit", url: "curation concern url" ).and_return 'body3'

      allow(Deepblue::EmailHelper).to receive(:log).with(class_name: "EmbargoHelperMock",
                                                         current_user: nil,
                                                         event: "Embargo expiration notification",
                                                         event_note: "25 days",
                                                         id: "AZ555",
                                                         to: "authorexamplecom",
                                                         from: "authorexamplecom",
                                                         subject: "subject",
                                                         body: "body1 body2 body3" )
      allow(Deepblue::EmailHelper).to receive(:send_email).with( to: "authorexamplecom", from: "authorexamplecom", subject: "subject", body: "body1 body2 body3")
    }

    context "when DeepBlueDocs::Application.config.embargo_about_to_expire_email_rds evaluates to negative" do
      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).and_return ["here", "called from", "object class", "asset=#<OpenStruct>id:'W222'>",
                                                                           "expiration_days=25", "email_owner=true", "test_mode=false", "verbose=false", ""]
        allow(DeepBlueDocs::Application.config).to receive(:embargo_about_to_expire_email_rds).and_return false
      }
      it "returns nil" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).and_return ["here", "called from", "object class", "asset=#<OpenStruct>id:'W222'>",
                                                                           "expiration_days=25", "email_owner=true", "test_mode=false", "verbose=false", ""]
        expect(Deepblue::LoggingHelper).not_to receive(:debug)
        expect(Deepblue::EmailHelper).to receive(:log).with(class_name: "EmbargoHelperMock",
                                                            current_user: nil,
                                                            event: "Embargo expiration notification",
                                                            event_note: "25 days",
                                                            id: "AZ555",
                                                            to: "authorexamplecom",
                                                            from: "authorexamplecom",
                                                            subject: "subject",
                                                            body: "body1 body2 body3" )
        expect(Deepblue::EmailHelper).to receive(:send_email).with( to: "authorexamplecom", from: "authorexamplecom", subject: "subject", body: "body1 body2 body3")
        expect(subject.about_to_expire_embargo_email(asset: generic, expiration_days: 25, verbose: false)).to be_nil
      end
    end

    context "when DeepBlueDocs::Application.config.embargo_about_to_expire_email_rds evaluates to positive" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:embargo_about_to_expire_email_rds).and_return true
        allow(Deepblue::EmailHelper).to receive(:notification_email).and_return "notify email"
        allow(Deepblue::EmailHelper).to receive(:send_email).with(to: "notify email", from: "notify email", subject: "subject", body: "body1 body2 body3" )
      }

      context "when test_mode is false" do
        it "logs and sends two emails" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).and_return ["here", "called from", "object class", "asset=#<OpenStruct>id:'W222'>",
                                                                              "expiration_days=25", "email_owner=true", "test_mode=false", "verbose=false", ""]
          expect(Deepblue::LoggingHelper).not_to receive(:debug).with("about_to_expire_embargo_email: curation concern id: AZ555 email: authorexamplecom expiration_days: 25")
          expect(Deepblue::EmailHelper).to receive(:log).with(class_name: "EmbargoHelperMock",
                                                              current_user: nil,
                                                              event: "Embargo expiration notification",
                                                              event_note: "25 days",
                                                              id: "AZ555",
                                                              to: "authorexamplecom",
                                                              from: "authorexamplecom",
                                                              subject: "subject",
                                                              body: "body1 body2 body3" )
          expect(Deepblue::EmailHelper).to receive(:send_email).with( to: "authorexamplecom", from: "authorexamplecom", subject: "subject", body: "body1 body2 body3")
          expect(Deepblue::EmailHelper).to receive(:log).with(class_name: "EmbargoHelperMock",
                                                             current_user: nil,
                                                             event: "Embargo expiration notification",
                                                             event_note: "25 days",
                                                             id: "AZ555",
                                                             to: "notify email",
                                                             from: "notify email",
                                                             subject: "subject",
                                                             body: "body1 body2 body3" )
          expect(Deepblue::EmailHelper).to receive(:send_email).with(to: "notify email", from: "notify email", subject: "subject", body: "body1 body2 body3")

          subject.about_to_expire_embargo_email(asset: generic, expiration_days: 25, verbose: false)
        end
      end

      context "when test_mode is true and verbose is true" do
        it "logs and doesn't send emails" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).and_return ["here", "called from", "object class", "asset=#<OpenStruct>id:'W222'>",
                                                                              "expiration_days=25", "email_owner=true", "test_mode=true", "verbose=true", ""]
          expect(Deepblue::LoggingHelper).to receive(:debug).with("about_to_expire_embargo_email: curation concern id: AZ555 email: authorexamplecom expiration_days: 25")
          expect(Deepblue::EmailHelper).to receive(:log).with(class_name: "EmbargoHelperMock",
                                                              current_user: nil,
                                                              event: "Embargo expiration notification",
                                                              event_note: "25 days test_mode",
                                                              id: "AZ555",
                                                              to: "authorexamplecom",
                                                              from: "authorexamplecom",
                                                              subject: "subject",
                                                              body: "body1 body2 body3" )
          expect(Deepblue::EmailHelper).not_to receive(:send_email)
          expect(Deepblue::EmailHelper).to receive(:log).with(class_name: "EmbargoHelperMock",
                                                              current_user: nil,
                                                              event: "Embargo expiration notification",
                                                              event_note: "25 days test_mode",
                                                              id: "AZ555",
                                                              to: "notify email",
                                                              from: "notify email",
                                                              subject: "subject",
                                                              body: "body1 body2 body3" )

          subject.about_to_expire_embargo_email(asset: generic, expiration_days: 25, test_mode: true, verbose: true)
        end
      end
    end
  end


  describe "#days_to_embargo_release_date" do
    before {
      allow(Time).to receive(:zone).and_return "UTC"
      subject.instance_variable_set(:@start_of_day, DateTime.new(2025, 10, 1))
    }

    context "when embargo_release_date is a String" do
      it "parses embargo_release_date to a DateTime and returns difference in days between @start_of_day and embargo_release_date parameter" do
        expect(subject.days_to_embargo_release_date(embargo_release_date: "2025-10-10 UTC")).to eq 9
      end
    end

    context "when embargo_release_date is NOT a String" do
      it "returns difference in days between @start_of_day and embargo_release_date parameter" do
        expect(subject.days_to_embargo_release_date(embargo_release_date: DateTime.new(2025, 9, 20))).to eq -10
      end
    end
  end


  describe "#deactivate_embargo" do
    before {
      allow(Deepblue::ProvenanceHelper).to receive(:system_as_current_user).and_return "system as"
    }

    context "when curation_concern parameter is not a FileSet" do
      embargo = EmbargoMockery.new
      curation = ConcernMockery.new(embargo)
      before {
        allow(Deepblue::LoggingHelper).to receive(:obj_class).with("curation_concern", curation).and_return "object class"
        allow(curation).to receive(:is_a?).with(Hyrax::FileSet).and_return false
      }
      context "when test_mode parameter is true" do
        before {
          allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "object class", "copy_visibility_to_files=false",
                                                                       "email_owner=true",
                                                                       "test_mode=true",
                                                                       "verbose=false",
                                                                       "" ]
          allow(subject).to receive(:deactivate_embargo_email).with(curation_concern: curation, test_mode: true)
        }
        it "returns false" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "object class", "copy_visibility_to_files=false",
                                                                        "email_owner=true",
                                                                        "test_mode=true",
                                                                        "verbose=false",
                                                                        "" ]
          expect(curation).not_to receive(:embargo_visibility!)
          expect(curation).not_to receive(:deactivate_embargo!)
          expect(embargo).not_to receive(:save!)
          expect(curation).not_to receive(:save!)
          expect(curation).not_to receive(:copy_visibility_to_files)
          expect(subject).to receive(:deactivate_embargo_email).with(curation_concern: curation, test_mode: true)

          expect(subject.deactivate_embargo(curation_concern: curation, copy_visibility_to_files: false, current_user: "current user", test_mode: true)).to eq false
        end
      end

       context "when test_mode parameter is false" do
         before {
          allow(subject).to receive(:deactivate_embargo_email).with(curation_concern: curation, test_mode: false)
        }

        context "when email_owner parameter is true" do
          it "returns value of curation_concern.save!" do
            expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "object class", "copy_visibility_to_files=true",
                                                                          "email_owner=true",
                                                                          "test_mode=false",
                                                                          "verbose=false",
                                                                          "" ]
            expect(curation).to receive(:embargo_visibility!)
            expect(curation).to receive(:deactivate_embargo!).with( current_user: "system as" )
            expect(embargo).to receive(:save!)
            expect(curation).to receive(:save!)
            expect(curation).to receive(:copy_visibility_to_files)
            expect(subject).to receive(:deactivate_embargo_email).with(curation_concern: curation, test_mode: false)

            subject.deactivate_embargo(curation_concern: curation, copy_visibility_to_files: true, current_user: "current user", test_mode: false)
          end
        end

        context "when email_owner parameter is false" do
          it "returns value of curation_concern.save!" do
            expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "object class", "copy_visibility_to_files=true",
                                                                          "email_owner=false",
                                                                          "test_mode=false",
                                                                          "verbose=false",
                                                                          "" ]
            expect(curation).to receive(:embargo_visibility!)
            expect(curation).to receive(:deactivate_embargo!).with( current_user: "system as" )
            expect(embargo).to receive(:save!)
            expect(curation).to receive(:save!)
            expect(curation).to receive(:copy_visibility_to_files)
            expect(subject).not_to receive(:deactivate_embargo_email)

            subject.deactivate_embargo(curation_concern: curation, copy_visibility_to_files: true, current_user: "current user", email_owner: false, test_mode: false)
          end
        end
      end
    end

    context "when curation_concern parameter is a FileSet, current_user parameter is nil, and verbose is true" do
      concerning = ConcernMockery.new(EmbargoMockery.new)
      before {
        allow(concerning).to receive(:is_a?).with(Hyrax::FileSet).and_return true
        allow(Deepblue::LoggingHelper).to receive(:debug).with "deactivate_embargo for file_set: curation concern id: CCID"
        allow(subject).to receive(:visibility_on_embargo_deactivation).with(curation_concern: concerning).and_return "restricted"
      }
      it "calls visibility_on_embargo_deactivation and provenance_unembargo" do
        expect(Deepblue::ProvenanceHelper).to receive(:system_as_current_user)
        expect(Deepblue::LoggingHelper).to receive(:debug).with "deactivate_embargo for file_set: curation concern id: CCID"
        expect(concerning).to receive(:provenance_unembargo).with(current_user: "system as", embargo_visibility: "open",
                                                                  embargo_visibility_after: "restricted")
        expect(concerning).to receive(:save!)

        subject.deactivate_embargo(curation_concern: concerning, copy_visibility_to_files: true, current_user: nil, test_mode: false, verbose: true)
      end
    end
  end


  describe "#deactivate_embargo_email" do
    cc = OpenStruct.new(id: "CC-1000", title: ["Big Title ", "Small Title"], visibility: "restricted", authoremail: "authorexamplecom")
    before {
      allow(Deepblue::EmailHelper).to receive(:t).with( "hyrax.email.deactivate_embargo.subject", title: "Big Title Small Title" ).and_return "subject"
      allow(Deepblue::EmailHelper).to receive(:curation_concern_url).with(curation_concern: cc).and_return "cc_url"
      allow(Deepblue::EmailHelper).to receive(:t).with( "hyrax.email.deactivate_embargo.for",
                                                         title: "Big Title Small Title",
                                                         id: "CC-1000",
                                                         visibility: "restricted").and_return "body 1 "
      allow(Deepblue::EmailHelper).to receive(:t).with( "hyrax.email.deactivate_embargo.visit", url: "cc_url" ).and_return "body 2"
      allow(Deepblue::LoggingHelper).to receive(:debug).with("deactivate_embargo_email: curation concern id: CC-1000 email: authorexamplecom")
      allow(Deepblue::EmailHelper).to receive(:log).with( class_name: "EmbargoHelperMock",
                                                          current_user: nil,
                                                          event: "Deactivate embargo",
                                                          event_note: "",
                                                          id: "CC-1000",
                                                          to: "authorexamplecom",
                                                          from: "authorexamplecom",
                                                          subject: "subject",
                                                          body: "body 1 body 2" )
      allow(Deepblue::EmailHelper).to receive(:send_email).with( to: "authorexamplecom", from: "authorexamplecom", subject: "subject", body: "body 1 body 2" )
    }

    context "when embargo_deactivate_email_rds is false" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:embargo_deactivate_email_rds).and_return false
      }
      context "when test_mode parameter is false and verbose is false" do
        it "logs and sends email to author" do
          expect(Deepblue::LoggingHelper).not_to receive(:debug)
          expect(Deepblue::EmailHelper).to receive(:log).with( class_name: "EmbargoHelperMock",
                                                               current_user: nil,
                                                               event: "Deactivate embargo",
                                                               event_note: "",
                                                               id: "CC-1000",
                                                               to: "authorexamplecom",
                                                               from: "authorexamplecom",
                                                               subject: "subject",
                                                               body: "body 1 body 2" )
          expect(Deepblue::EmailHelper).to receive(:send_email).with( to: "authorexamplecom", from: "authorexamplecom", subject: "subject", body: "body 1 body 2" )

          subject.deactivate_embargo_email(curation_concern: cc, test_mode: false)
        end
      end

      context "when test_mode parameter is true and verbose is true" do
        it "logs and debugs but does NOT send email to author" do
          expect(Deepblue::LoggingHelper).to receive(:debug).with("deactivate_embargo_email: curation concern id: CC-1000 email: authorexamplecom")
          expect(Deepblue::EmailHelper).to receive(:log).with( class_name: "EmbargoHelperMock",
                                                               current_user: nil,
                                                               event: "Deactivate embargo",
                                                               event_note: "test_mode",
                                                               id: "CC-1000",
                                                               to: "authorexamplecom",
                                                               from: "authorexamplecom",
                                                               subject: "subject",
                                                               body: "body 1 body 2" )
          expect(Deepblue::EmailHelper).not_to receive(:send_email)
          subject.deactivate_embargo_email(curation_concern: cc, test_mode: true, verbose: true)
        end
      end
    end

    context "when embargo_deactivate_email_rds is true" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:embargo_deactivate_email_rds).and_return true
        allow(Deepblue::EmailHelper).to receive(:notification_email).and_return "notify email"
        allow(Deepblue::EmailHelper).to receive(:log).with( class_name: "EmbargoHelperMock",
                                                            current_user: nil,
                                                            event: "Deactivate embargo",
                                                            event_note: "",
                                                            id: "CC-1000",
                                                            to: "notify email",
                                                            from: "notify email",
                                                            subject: "subject",
                                                            body: "body 1 body 2" )
        allow(Deepblue::EmailHelper).to receive(:send_email).with( to: "notify email", from: "notify email", subject: "subject", body: "body 1 body 2" )
      }

      context "when test_mode parameter is false and verbose is false" do
        it "logs and sends email to author and notification_email" do
          expect(Deepblue::LoggingHelper).not_to receive(:debug)
          expect(Deepblue::EmailHelper).to receive(:log).with( class_name: "EmbargoHelperMock",
                                                               current_user: nil,
                                                               event: "Deactivate embargo",
                                                               event_note: "",
                                                               id: "CC-1000",
                                                               to: "authorexamplecom",
                                                               from: "authorexamplecom",
                                                               subject: "subject",
                                                               body: "body 1 body 2" )
          expect(Deepblue::EmailHelper).to receive(:send_email).with( to: "authorexamplecom", from: "authorexamplecom", subject: "subject", body: "body 1 body 2" )

          expect(Deepblue::EmailHelper).to receive(:log).with( class_name: "EmbargoHelperMock",
                                                              current_user: nil,
                                                              event: "Deactivate embargo",
                                                              event_note: "",
                                                              id: "CC-1000",
                                                              to: "notify email",
                                                              from: "notify email",
                                                              subject: "subject",
                                                              body: "body 1 body 2" )
          expect(Deepblue::EmailHelper).to receive(:send_email).with( to: "notify email", from: "notify email", subject: "subject", body: "body 1 body 2" )

          subject.deactivate_embargo_email(curation_concern: cc, test_mode: false)
        end
      end

      context "when test_mode parameter is true and verbose is true" do
        it "logs and debugs but does NOT send email to author or notification_email" do
          expect(Deepblue::EmailHelper).not_to receive(:send_email)

          expect(Deepblue::LoggingHelper).to receive(:debug).with("deactivate_embargo_email: curation concern id: CC-1000 email: authorexamplecom")
          expect(Deepblue::EmailHelper).to receive(:log).with( class_name: "EmbargoHelperMock",
                                                               current_user: nil,
                                                               event: "Deactivate embargo",
                                                               event_note: "test_mode",
                                                               id: "CC-1000",
                                                               to: "authorexamplecom",
                                                               from: "authorexamplecom",
                                                               subject: "subject",
                                                               body: "body 1 body 2" )

          expect(Deepblue::LoggingHelper).to receive(:debug).with("deactivate_embargo_email: curation concern id: CC-1000 email: notify email")
          expect(Deepblue::EmailHelper).to receive(:log).with( class_name: "EmbargoHelperMock",
                                                               current_user: nil,
                                                               event: "Deactivate embargo",
                                                               event_note: "test_mode",
                                                               id: "CC-1000",
                                                               to: "notify email",
                                                               from: "notify email",
                                                               subject: "subject",
                                                               body: "body 1 body 2" )

          subject.deactivate_embargo_email(curation_concern: cc, test_mode: true, verbose: true)
        end
      end
    end
  end


  describe "#embargo_added" do
    cured = OpenStruct.new(id: "W800")
    before {
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with("curation_concern", cured).and_return "object class"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "object class", "curation_concern.id=W800",
                                                                   "update_attr_key_values=key value attrs", "" ]
    }
    it "calls bold_debug with parameters" do
      expect(subject.embargo_added curation_concern: cured, update_attr_key_values: "key value attrs").to eq false
    end
  end


  describe "#have_assets_under_embargo?" do
    context "when embargoes blank" do
      before {
        allow(subject).to receive(:my_assets_under_embargo).with("current user key").and_return ""
      }
      it "returns false" do
        expect(subject).to receive(:my_assets_under_embargo).with("current user key")
        expect(subject.have_assets_under_embargo? "current user key").to eq false
      end
    end

    context "when embargoes NOT blank" do
      context "when embargo_manage_hide_files is false" do
        before {
          allow(subject).to receive(:my_assets_under_embargo).with("current user key").and_return "embargoes"

          allow(DeepBlueDocs::Application.config).to receive(:embargo_manage_hide_files).and_return false
        }
        it "returns true" do
          expect(subject.have_assets_under_embargo? "current user key").to eq true
        end
      end

      context "when embargo_manage_hide_files is true" do
        before {
          allow(DeepBlueDocs::Application.config).to receive(:embargo_manage_hide_files).and_return true
        }

        context "when at least one embargoed asset is NOT a FileSet" do
          before {
            allow(subject).to receive(:my_assets_under_embargo).with("current user key").and_return [OpenStruct.new(human_readable_type: "File"),
                                                                                                     OpenStruct.new(human_readable_type: "Asset")]
          }
          it "returns true" do
            expect(subject).to receive(:my_assets_under_embargo).with("current user key")
            expect(subject.have_assets_under_embargo? "current user key").to eq true
          end
        end

        context "when all embargoed assets are FileSets" do
          before {
            allow(subject).to receive(:my_assets_under_embargo).with("current user key").and_return [OpenStruct.new(human_readable_type: "File")]
          }
          it "returns false" do
            expect(subject).to receive(:my_assets_under_embargo).with("current user key")
            expect(subject.have_assets_under_embargo? "current user key").to eq false
          end
        end
      end
    end
  end


  describe '#my_assets_with_expired_embargoes' do
    context "when instance variable has a value" do
      before {
        subject.instance_variable_set(:@my_assets_with_expired_embargoes, "my deactivated assets")
      }
      it "returns value of instance variable" do
        expect(Hyrax::EmbargoService).not_to receive(:my_assets_with_expired_embargoes)
        expect(subject.my_assets_with_expired_embargoes nil).to eq "my deactivated assets"
      end
    end

    context "when instance variable does not have a value" do
      before {
        allow(Hyrax::EmbargoService).to receive(:my_assets_with_expired_embargoes).with("user key").and_return "with user key"
      }
      it "sets value of instance variable and returns it" do
        expect(subject.my_assets_with_expired_embargoes "user key").to eq "with user key"
        expect(subject.instance_variable_get(:@my_assets_with_expired_embargoes)).to eq "with user key"
      end
    end
  end


  describe '#my_assets_under_embargo' do
    context "when instance variable has a value" do
      before {
        subject.instance_variable_set(:@my_assets_under_embargo, "my assets")
      }
      it "returns value of instance variable" do
        expect(Hyrax::EmbargoService).not_to receive(:my_assets_under_embargo)
        expect(subject.my_assets_under_embargo nil).to eq "my assets"
      end
    end

    context "when instance variable does not have a value" do
      before {
        allow(Hyrax::EmbargoService).to receive(:my_assets_under_embargo).with("user key").and_return "with user key"
      }
      it "sets value of instance variable and returns it" do
        expect(subject.my_assets_under_embargo "user key").to eq "with user key"
        expect(subject.instance_variable_get(:@my_assets_under_embargo)).to eq "with user key"
      end
    end
  end


  describe '#my_assets_with_deactivated_embargoes' do
    context "when instance variable has a value" do
      before {
        subject.instance_variable_set(:@my_assets_with_deactivated_embargoes, "my deactivated assets")
      }
      it "returns value of instance variable" do
        expect(Hyrax::EmbargoService).not_to receive(:my_assets_with_deactivated_embargoes)
        expect(subject.my_assets_with_deactivated_embargoes nil).to eq "my deactivated assets"
      end
    end

    context "when instance variable does not have a value" do
      before {
        allow(Hyrax::EmbargoService).to receive(:my_assets_with_deactivated_embargoes).with("user key").and_return "with user key"
      }
      it "sets value of instance variable and returns it" do
        expect(Hyrax::EmbargoService).to receive(:my_assets_with_deactivated_embargoes)
        expect(subject.my_assets_with_deactivated_embargoes "user key").to eq "with user key"
        expect(subject.instance_variable_get(:@my_assets_with_deactivated_embargoes)).to eq "with user key"
      end
    end
  end


  describe "#visibility_on_embargo_deactivation" do
    cure = OpenStruct.new(to_solr: {"visibility_after_embargo_ssim" => "after embargo"})
    it "returns value of 'visibility_after_embargo_ssim' key from to_solr on curation concern" do
      expect(subject.visibility_on_embargo_deactivation curation_concern: cure).to eq "after embargo"
    end
  end

end
