require 'rails_helper'

class MockAdminSetService
  def initialize(admin_sets)
    @admin_sets = admin_sets
  end

  def search_results(deposit)
    @admin_sets
  end
end

class MockCurationConcern
  def id
    "work id"
  end

  def file_sets
    "file sets"
  end

  def initialize(success = true)
    @success = success
  end

  def provenance_log_update_after(current_user:, update_attr_key_values:)
  end

  def provenance_log_update_before(form_params:)
    "key values"
  end

  def entomb!(epitaph, current_user)
    @success
  end

  def metadata_report(dir:)
    OpenStruct.new(basename: "basename")
  end

  def title
    ["Title 1", "Title 2"]
  end
end

class MockZipFile
  def add(basename, filename)
  end
end



RSpec.describe Hyrax::DataSetsController do
  render_views
  let(:main_app) { Rails.application.routes.url_helpers }
  let(:hyrax) { Hyrax::Engine.routes.url_helpers }
  let(:user) { FactoryBot.create(:admin) } # FIXME: enable access for depositor?
  let(:pending_doi) { Deepblue::DoiBehavior::DOI_PENDING }
  let(:minted_doi) { 'doi:10.82028/18sn-h641' }
  let(:data_set) { FactoryBot.create(:data_set, user: user, doi: nil) }
  let(:data_set_with_one_file) { FactoryBot.create(:data_set_with_one_file, user: user, doi: nil) }
  let(:curation_concern) { OpenStruct.new(id: "work id") }

  before do
    sign_in user
    allow(subject).to receive(:curation_concern).and_return curation_concern
    allow(subject).to receive(:root_url).and_return "root url"
  end

  describe "constants" do
    it do
      expect(Hyrax::DataSetsController::PARAMS_KEY).to eq "data_set"
    end
  end


  describe "#self.curation_concern_type" do
    it "returns ::DataSet" do
      expect(Hyrax::DataSetsController.curation_concern_type).to eq ::DataSet
    end
  end

  describe "#self.show_presenter" do
    it "returns Hyrax::DataSetPresenter" do
      expect(Hyrax::DataSetsController.show_presenter).to eq Hyrax::DataSetPresenter
    end
  end


  # NOTE:  The BoxHelper class is in the three.js 3D graphics library.  We need a javaScript test for it, not an rspec test.

  describe "#box_create_dir_and_add_collaborator" do
    context "when box integration disabled" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:box_integration_enabled).and_return false
      }
      it "returns nil" do
        expect(subject.box_create_dir_and_add_collaborator).to be_nil
      end
    end

    context "when box integration enabled" do
      skip "add a test"
    end
  end


  describe "#box_link" do
    context "when box integration disabled" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:box_integration_enabled).and_return false
      }
      it "returns nil" do
        expect(subject.box_link).to be_nil
      end
    end

    context "when box integration enabled" do
      skip "add a test"
    end

    after {
      expect(DeepBlueDocs::Application.config).to have_received(:box_integration_enabled)
    }
  end


  describe "#box_work_created" do
    before {
      allow(subject).to receive(:box_create_dir_and_add_collaborator)
    }
    it "calls box_create_dir_and_add_collaborator" do
      expect(subject).to receive(:box_create_dir_and_add_collaborator)

      subject.box_work_created
    end
  end


  describe "#assign_date_coverage" do
    before {
      allow(subject).to receive(:params).and_return "data_set" => {"date_coverage" => "2025"}
    }

    context "when DateCoverageService.params_to_interval returns nil" do
      before {
        allow(Dataset::DateCoverageService).to receive(:params_to_interval).with("data_set" => {"date_coverage" => "2025"}).and_return nil
      }
      it "sets params[PARAMS_KEY]['date_coverage'] to empty string" do
        expect(Dataset::DateCoverageService).to receive(:params_to_interval).with("data_set" => {"date_coverage" => "2025"})
        subject.assign_date_coverage
        expect(subject.params["data_set"]["date_coverage"]).to be_blank
      end
    end

    context "when DateCoverageService.params_to_interval does NOT return nil" do
      before {
        allow(Dataset::DateCoverageService).to receive(:params_to_interval).with("data_set" => {"date_coverage" => "2025"})
                                                                           .and_return OpenStruct.new(edtf: "2026")
      }
      it "sets params[PARAMS_KEY]['date_coverage'] to the form parameter interval" do
        expect(Dataset::DateCoverageService).to receive(:params_to_interval).with("data_set" => {"date_coverage" => "2025"})
        subject.assign_date_coverage
        expect(subject.params["data_set"]["date_coverage"]).to eq "2026"
      end
    end
  end


  describe "#globus_add_email" do
    context "when user is signed in" do
      before {
        allow(subject).to receive(:user_signed_in?).and_return true
        allow(Deepblue::EmailHelper).to receive(:user_email_from).with( user ).and_return "useratexampledotcom"
        allow(subject).to receive(:globus_copy_job).with( user_email: "useratexampledotcom", delay_per_file_seconds: 0 )
        allow(subject).to receive(:globus_files_prepping_msg).with( user_email: "useratexampledotcom" ).and_return "prep msg"
        allow(subject).to receive(:flash_and_go_back).with "prep msg"
      }
      it "calls globus_copy_job, flashes the files prepping message, and goes back" do
        expect(Deepblue::EmailHelper).to receive(:user_email_from).with( user )
        expect(subject).to receive(:globus_copy_job).with( user_email: "useratexampledotcom", delay_per_file_seconds: 0 )
        expect(subject).to receive(:globus_files_prepping_msg).with( user_email: "useratexampledotcom" )
        expect(subject).to receive(:flash_and_go_back).with "prep msg"
        subject.globus_add_email
      end
    end

    context "when user is NOT signed in" do
      before {
        allow(subject).to receive(:user_signed_in?).and_return false
      }

      context "when user email one and two are present and equal" do
        before {
          allow(subject).to receive(:params).and_return :user_email_one => " useratexampledotcom", :user_email_two => "useratexampledotcom "
          allow(subject).to receive(:globus_copy_job).with( user_email: "useratexampledotcom", delay_per_file_seconds: 0 )
          allow(subject).to receive(:globus_files_prepping_msg).with( user_email: "useratexampledotcom" ).and_return "prepping msg"
          allow(subject).to receive(:flash_and_redirect_to_main_cc).with "prepping msg"
        }
        it "calls globus_copy_job, flashes the files prepping message, and redirects to main" do
          expect(subject).to receive(:globus_copy_job).with( user_email: "useratexampledotcom", delay_per_file_seconds: 0 )
          expect(subject).to receive(:globus_files_prepping_msg).with( user_email: "useratexampledotcom" )
          expect(subject).to receive(:flash_and_redirect_to_main_cc).with "prepping msg"
          subject.globus_add_email
        end
      end

      context "when user email one or two are present and NOT equal" do
        user_emails = [{ :one => "useroneatexampledotcom", :two => "usertwoatexampledotcom", :description => "equal" },
                       { :one => "useroneatexampledotcom", :two => "", :description => "not equal and two is blank" },
                       { :one => "", :two => "usertwoatexampledotcom", :description => "not equal and one is blank" }]
        user_emails.each do |user_email|
          context "when user emails are #{user_email[:description]}" do
            before {
              allow(subject).to receive(:params).and_return :user_email_one => user_email[:one], :user_email_two => user_email[:two]
              allow(subject).to receive(:emails_did_not_match_msg).and_return "no match"
              allow(subject).to receive(:render).with 'globus_download_add_email_form'
            }
            it "renders the add email form and flashes an error message" do
              expect(subject).to receive(:emails_did_not_match_msg)
              expect(subject).to receive(:render).with 'globus_download_add_email_form'
              subject.globus_add_email
              expect(flash.now[:error]).to eq "no match"
            end
          end
        end
      end

      context "when user email one and two are NOT present" do
        before {
          allow(subject).to receive(:params).and_return :user_email_one => "", :user_email_two => ""
          allow(subject).to receive(:globus_status_msg).and_return "status msg"
          allow(subject).to receive(:flash_and_redirect_to_main_cc).with "status msg"
        }
        it "redirects to main and flashes a status message" do
          expect(subject).to receive(:globus_status_msg)
          expect(subject).to receive(:flash_and_redirect_to_main_cc).with "status msg"
          subject.globus_add_email
        end
      end
    end

    after {
      expect(subject).to have_received(:user_signed_in?)
    }
  end


  describe "#globus_clean_download" do
    before {
      allow(GlobusCleanJob).to receive(:perform_later).with( "work id", clean_download: true )
      allow(subject).to receive(:globus_ui_delay)
      allow(GlobusJob).to receive(:target_download_dir).with( "work id" ).and_return "download dir"
      allow(GlobusJob).to receive(:target_prep_dir).with( "work id", prefix: nil ).and_return "prep dir"
      allow(GlobusJob).to receive(:target_prep_tmp_dir).with( "work id", prefix: nil ).and_return "prep tmp dir"
      allow(subject).to receive(:globus_clean_msg).with( ["download dir", "prep dir", "prep tmp dir"] ).and_return "clean message"
      allow(subject).to receive(:flash_and_redirect_to_main_cc).with("clean message")
    }
    it "redirects to main and flashes globus clean message" do
      expect(GlobusCleanJob).to receive(:perform_later).with( "work id", clean_download: true )
      expect(subject).to receive(:globus_ui_delay)
      expect(GlobusJob).to receive(:target_download_dir).with( "work id" ).and_return "download dir"
      expect(GlobusJob).to receive(:target_prep_dir).with( "work id", prefix: nil )
      expect(GlobusJob).to receive(:target_prep_tmp_dir).with( "work id", prefix: nil )
      expect(subject).to receive(:globus_clean_msg).with( ["download dir", "prep dir", "prep tmp dir"] )
      expect(subject).to receive(:flash_and_redirect_to_main_cc).with("clean message")

      subject.globus_clean_download
    end
  end


  describe "#globus_clean_prep" do
    before {
      allow(GlobusCleanJob).to receive(:perform_later).with( "work id", clean_download: false )
      allow(subject).to receive(:globus_ui_delay)
    }
    it "calls GlobusCleanJob.perform_later and globus_ui_delay" do
      expect(GlobusCleanJob).to receive(:perform_later).with( "work id", clean_download: false )
      expect(subject).to receive(:globus_ui_delay)

      subject.globus_clean_prep
    end
  end


  describe "#globus_complete?" do
    before {
      allow(GlobusJob).to receive(:copy_complete?).with "work id"
    }
    it "calls GlobusJob.copy_complete?" do
      expect(GlobusJob).to receive(:copy_complete?).with "work id"

      subject.globus_complete?
    end
  end


  describe "#globus_copy_job" do
    before {
      allow(DeepBlueDocs::Application.config).to receive(:globus_debug_delay_per_file_copy_job_seconds).and_return 123
      allow(GlobusCopyJob).to receive(:perform_later).with( "work id",
                                                            user_email: "useratsomewheredotcom",
                                                            delay_per_file_seconds: 123 )
      allow(subject).to receive(:globus_ui_delay)
    }
    it "calls GlobusCleanJob.perform_later with function parameters and calls globus_ui_delay" do
      expect(DeepBlueDocs::Application.config).to receive(:globus_debug_delay_per_file_copy_job_seconds)
      expect(GlobusCopyJob).to receive(:perform_later).with( "work id",
                                                             user_email: "useratsomewheredotcom",
                                                             delay_per_file_seconds: 123 )
      expect(subject).to receive(:globus_ui_delay)
      subject.globus_copy_job(user_email: "useratsomewheredotcom")
    end
  end


  describe "#globus_download" do
    context "when globus is complete" do
      before {
        allow(subject).to receive(:globus_complete?).and_return true
        allow(subject).to receive(:globus_files_available_here).and_return "files"
        allow(subject).to receive(:flash_and_redirect_to_main_cc).with "files"
      }
      it "redirects to main and flashes files available message" do
        expect(subject).to receive(:globus_files_available_here).and_return "files"
        expect(subject).to receive(:flash_and_redirect_to_main_cc).with "files"
        subject.globus_download
      end
    end

    context "when globus is NOT complete" do
      before {
        allow(subject).to receive(:globus_complete?).and_return false
        allow(subject).to receive(:globus_download_msg).with(user_email: "useratsomewheredotcom").and_return "download message"
      }

      context "when user is signed in" do
        before {
          allow(subject).to receive(:user_signed_in?).and_return true
          allow(Deepblue::EmailHelper).to receive(:user_email_from).with( user, user_signed_in: true).and_return "useratsomewheredotcom"
          allow(subject).to receive(:globus_copy_job).with( user_email: "useratsomewheredotcom" )
          allow(subject).to receive(:flash_and_redirect_to_main_cc).with "download message"
        }
        it "calls globus_copy_job, redirects to main and flashes download message" do
          expect(Deepblue::EmailHelper).to receive(:user_email_from).with( user, user_signed_in: true)
          expect(subject).to receive(:globus_copy_job).with( user_email: "useratsomewheredotcom" )
          expect(subject).to receive(:flash_and_redirect_to_main_cc).with "download message"

          subject.globus_download
        end
      end

      context "when user is NOT signed in" do
        before {
          allow(subject).to receive(:user_signed_in?).and_return false
          allow(Deepblue::EmailHelper).to receive(:user_email_from).with( user, user_signed_in: false).and_return "useratsomewheredotcom"
          allow(subject).to receive(:render).with 'globus_download_notify_me_form'
        }
        it "renders globus_download_notify_me_form" do
          expect(Deepblue::EmailHelper).to receive(:user_email_from).with( user, user_signed_in: false)
          expect(subject).to receive(:render).with 'globus_download_notify_me_form'

          subject.globus_download
        end
      end

      after {
        expect(subject).to have_received(:user_signed_in?).twice
        expect(subject).to have_received(:globus_download_msg).with(user_email: "useratsomewheredotcom")
      }
    end

    after {
      expect(subject).to have_received(:globus_complete?)
    }
  end


  describe "#globus_download_msg" do
    context "when globus_prepping? returns true" do
      before {
        allow(subject).to receive(:globus_prepping?).and_return true
        allow(subject).to receive(:globus_files_prepping_msg).with( user_email: "user email" )
      }
      it "calls globus_files_prepping_msg function with user email parameter" do
        expect(subject).to receive(:globus_files_prepping_msg).with( user_email: "user email" )

        subject.globus_download_msg(user_email: "user email")
      end
    end

    context "when globus_prepping? returns true" do
      before {
        allow(subject).to receive(:globus_prepping?).and_return false
        allow(subject).to receive(:globus_file_prep_started_msg).with( user_email: "user email" )
      }
      it "calls globus_file_prep_started_msg function with user email parameter" do
        expect(subject).to receive(:globus_file_prep_started_msg).with( user_email: "user email" )

        subject.globus_download_msg(user_email: "user email")
      end
    end

    after {
      expect(subject).to have_received(:globus_prepping?)
    }
  end


  describe "#globus_download_add_email" do
    context "when user is signed in" do
      before {
        allow(subject).to receive(:user_signed_in?).and_return true
        allow(subject).to receive(:globus_add_email)
      }
      it "it calls globus_add_email" do
        expect(subject).to receive(:globus_add_email)

        subject.globus_download_add_email
      end
    end

    context "when user is NOT signed in" do
      before {
        allow(subject).to receive(:user_signed_in?).and_return false
        allow(subject).to receive(:render).with 'globus_download_add_email_form'
      }
      it "renders globus_download_add_email_form" do
        expect(subject).to receive(:render).with 'globus_download_add_email_form'

        subject.globus_download_add_email
      end
    end

    after {
      expect(subject).to have_received(:user_signed_in?)
    }
  end


  describe "#globus_download_enabled?" do
    before {
      allow(DeepBlueDocs::Application.config).to receive(:globus_enabled).and_return "enabled"
    }
    it "calls DeepBlueDocs::Application.config.globus_enabled and returns the result" do
      expect(subject.globus_download_enabled?).to eq "enabled"
    end
  end


  describe "#globus_download_notify_me" do
    context "when user is signed in" do
      before {
        allow(subject).to receive(:user_signed_in?).and_return true
        allow(Deepblue::EmailHelper).to receive(:user_email_from).with( user ).and_return "useratexampledotcom"
        allow(subject).to receive(:globus_copy_job).with( user_email: "useratexampledotcom" )
        allow(subject).to receive(:globus_file_prep_started_msg).with( user_email: "useratexampledotcom" ).and_return "prep started msg"
        allow(subject).to receive(:flash_and_go_back).with "prep started msg"
      }
      it "calls globus_copy_job, flashes the files prep started message, and goes back" do
        expect(Deepblue::EmailHelper).to receive(:user_email_from).with( user )
        expect(subject).to receive(:globus_copy_job).with( user_email: "useratexampledotcom")
        expect(subject).to receive(:globus_file_prep_started_msg).with( user_email: "useratexampledotcom" )
        expect(subject).to receive(:flash_and_go_back).with "prep started msg"
        subject.globus_download_notify_me
      end
    end

    context "when user is NOT signed in" do
      before {
        allow(subject).to receive(:user_signed_in?).and_return false
      }

      context "when user email one and two are present and equal" do
        before {
          allow(subject).to receive(:params).and_return :user_email_one => " useratexampledotcom", :user_email_two => "useratexampledotcom "
          allow(subject).to receive(:globus_copy_job).with( user_email: "useratexampledotcom")
          allow(subject).to receive(:globus_file_prep_started_msg).with( user_email: "useratexampledotcom" ).and_return "prep started msg"
          allow(subject).to receive(:flash_and_redirect_to_main_cc).with "prepping msg"
        }
        it "calls globus_copy_job, flashes the file prep started message, and redirects to main" do
          expect(subject).to receive(:globus_copy_job).with( user_email: "useratexampledotcom")
          expect(subject).to receive(:globus_file_prep_started_msg).with( user_email: "useratexampledotcom" )
          expect(subject).to receive(:flash_and_redirect_to_main_cc).with "prep started msg"
          subject.globus_download_notify_me
        end
      end

      context "when user email one or two are present and NOT equal" do
        user_emails = [{ :one => "useroneatexampledotcom", :two => "usertwoatexampledotcom", :description => "equal" },
                       { :one => "useroneatexampledotcom", :two => "", :description => "not equal and two is blank" },
                       { :one => "", :two => "usertwoatexampledotcom", :description => "not equal and one is blank" }]
        user_emails.each do |user_email|
          context "when user emails are #{user_email[:description]}" do
            before {
              allow(subject).to receive(:params).and_return :user_email_one => user_email[:one], :user_email_two => user_email[:two]
              allow(subject).to receive(:emails_did_not_match_msg).and_return "no match"
              allow(subject).to receive(:render).with 'globus_download_notify_me_form'
            }
            it "renders the notify me form and flashes an error message" do
              expect(subject).to receive(:emails_did_not_match_msg)
              expect(subject).to receive(:render).with 'globus_download_notify_me_form'
              subject.globus_download_notify_me
              expect(flash.now[:error]).to eq "no match"
            end
          end
        end
      end

      context "when user email one and two are NOT present" do
        before {
          allow(subject).to receive(:params).and_return :user_email_one => "", :user_email_two => ""
          allow(subject).to receive(:globus_status_msg).and_return "status msg"
          allow(subject).to receive(:flash_and_redirect_to_main_cc).with "status msg"
        }
        it "redirects to main and flashes a status message" do
          expect(subject).to receive(:globus_status_msg)
          expect(subject).to receive(:flash_and_redirect_to_main_cc).with "status msg"
          subject.globus_add_email
        end
      end
    end

    after {
      expect(subject).to have_received(:user_signed_in?)
    }
  end


  describe "#globus_enabled?" do
    before {
      allow(DeepBlueDocs::Application.config).to receive(:globus_enabled).and_return true
    }
    it "returns the result of DeepBlueDocs::Application.config.globus_enabled" do
      expect(subject.globus_enabled?).to eq true
    end
  end


  describe "#globus_last_error_msg" do
    before {
      allow(GlobusJob).to receive(:error_file_contents).with("work id").and_return "contents"
    }
    it "returns the result of GlobusJob.error_file_contents" do
      expect(subject.globus_last_error_msg).to eq "contents"
    end
  end


  describe "#globus_prepping?" do
    before {
      allow(GlobusJob).to receive(:files_prepping?).with("work id").and_return "prepping"
    }
    it "returns the result of GlobusJob.files_prepping?" do
      expect(subject.globus_prepping?).to eq "prepping"
    end
  end


  describe "#globus_ui_delay" do
    context "when called with a positive number (using the result of globus_after_copy_job_ui_delay_seconds)" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:globus_after_copy_job_ui_delay_seconds).and_return 42
      }
      it "calls sleep for positive number of seconds" do
        expect(subject).to receive(:sleep).with(42)
        subject.globus_ui_delay
      end
    end

    context "when called with a negative number (passing in a parameter)" do
      it "returns nil" do
        expect(DeepBlueDocs::Application.config).not_to receive(:globus_after_copy_job_ui_delay_seconds)
        expect(subject).not_to receive(:sleep)
        expect(subject.globus_ui_delay delay_seconds: -55).to be_nil
      end
    end
  end


  describe "#globus_url" do
    before {
      allow(GlobusJob).to receive(:external_url).with("work id").and_return "url"
    }
    it "returns the result of GlobusJob.external_url" do
      expect(GlobusJob).to receive(:external_url).with("work id")

      expect(subject.globus_url).to eq "url"
    end
  end


  describe "#provenance_log_update_after" do
    concern = MockCurationConcern.new
    before {
      allow(subject).to receive(:curation_concern).and_return concern
      subject.instance_variable_set(:@update_attr_key_values, 1001)
    }
    it "returns the result of provenance_log_update_after" do
      expect(concern).to receive(:provenance_log_update_after).with( current_user: user,
                                                                     update_attr_key_values: 1001)
      subject.provenance_log_update_after
    end
  end


  describe "#provenance_log_update_before" do
    concern = MockCurationConcern.new
    before {
      allow(subject).to receive(:curation_concern).and_return concern
      allow(subject).to receive(:params).and_return "data_set" => "form params"
    }
    it "sets @update_attr_key_values to the result of provenance_log_update_before" do
      expect(concern).to receive(:provenance_log_update_before).with( form_params: "form params" ).and_return "key values"
      subject.provenance_log_update_before

      expect(subject.instance_variable_get(:@update_attr_key_values)).to eq "key values"
    end
  end


  describe "#display_provenance_log" do
    before {
      allow(Deepblue::ProvenancePath).to receive(:path_for_reference).with( "work id" ).and_return "file path"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "DataSetsController", "display_provenance_log", "file path" ]
      allow(Deepblue::ProvenanceLogService).to receive(:entries).with( "work id", refresh: true )
      allow(subject).to receive(:main_app).and_return "main app"
      allow(subject).to receive(:polymorphic_url).with(["main app", curation_concern], anchor: "prov_log").and_return "polymorph url"
      allow(subject).to receive(:redirect_to).with "polymorph url"
    }
    it "loads the provenance log for the work" do
      expect(Deepblue::ProvenancePath).to receive(:path_for_reference).with( "work id" )
      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "DataSetsController", "display_provenance_log", "file path" ]
      expect(Deepblue::ProvenanceLogService).to receive(:entries).with( "work id", refresh: true )
      expect(subject).to receive(:polymorphic_url).with(["main app", curation_concern], anchor: "prov_log")
      expect(subject).to receive(:redirect_to).with "polymorph url"

      subject.display_provenance_log
    end
  end


  describe "#display_provenance_log_enabled?" do
    it "returns true" do
      expect(subject.display_provenance_log_enabled?).to eq true
    end
  end


  describe "#provenance_log_entries_present?" do
    before {
      allow(subject).to receive(:provenance_log_entries).and_return "entries"
    }
    it "returns whether provenance_log_entries is present or not" do
      expect(subject.provenance_log_entries_present?).to eq true
    end
  end


  describe "#tombstone" do
    before {
      allow(subject).to receive(:params).and_return :tombstone => "epitaph"
      allow(subject).to receive(:dashboard_works_path).and_return "dashboard_works_path"
    }

    context "when tombstone is successful" do
      before {
        allow(subject).to receive(:curation_concern).and_return MockCurationConcern.new(true)
        allow(MsgHelper).to receive(:t).with( 'data_set.tombstone_notice', title: "Title 1", reason: "epitaph" ).and_return "tombstone notice"
        allow(subject).to receive(:redirect_to).with "dashboard_works_path", notice: "tombstone notice"
      }
      it "redirects to dashboard works path and shows tombstone notice" do
        expect(MsgHelper).to receive(:t).with( 'data_set.tombstone_notice', title: "Title 1", reason: "epitaph" )
        expect(subject).to receive(:redirect_to).with "dashboard_works_path", notice: "tombstone notice"

        subject.tombstone
      end
    end

    context "when tombstone is NOT successful" do
      before {
        allow(subject).to receive(:curation_concern).and_return MockCurationConcern.new(false)
        allow(subject).to receive(:redirect_to).with "dashboard_works_path", notice: "Title 1 is already tombstoned."
      }
      it "redirects to dashboard works path and shows already tombstoned message" do
        expect(subject).to receive(:redirect_to).with "dashboard_works_path", notice: "Title 1 is already tombstoned."

        subject.tombstone
      end
    end

    after {
      expect(subject).to have_received(:params)
      expect(subject).to have_received(:curation_concern).twice
      expect(subject).to have_received(:dashboard_works_path)
    }
  end


  describe "#tombstone_enabled?" do
    it "returns true" do
      expect(subject.tombstone_enabled?).to eq true
    end
  end


  describe "#visibility_changed" do
    context "when visibility_to_private? returns true" do
      before {
        allow(subject).to receive(:visibility_to_private?).and_return true
        allow(subject).to receive(:mark_as_set_to_private)
      }
      it "calls mark_as_set_to_private" do
        expect(subject).to receive(:mark_as_set_to_private)
        expect(subject).not_to receive(:mark_as_set_to_public)

        subject.visibility_changed
      end
    end

    context "when visibility_to_private? returns false" do
      before {
        allow(subject).to receive(:visibility_to_private?).and_return false
      }

      context "when visibility_to_public? returns true" do
        before {
          allow(subject).to receive(:visibility_to_public?).and_return true
          allow(subject).to receive(:mark_as_set_to_public)
        }
        it "calls mark_as_set_to_public" do
          expect(subject).to receive(:mark_as_set_to_public)
          expect(subject).not_to receive(:mark_as_set_to_private)

          subject.visibility_changed
        end
      end

      context "when visibility_to_public? returns false" do
        before {
          allow(subject).to receive(:visibility_to_public?).and_return false
        }
        it "returns nil" do
          expect(subject).not_to receive(:mark_as_set_to_public)
          expect(subject).not_to receive(:mark_as_set_to_private)

          expect(subject.visibility_changed).to be_nil
        end
      end

      after {
        expect(subject).to have_received(:visibility_to_public?)
      }
    end

    after {
      expect(subject).to have_received(:visibility_to_private?)
    }
  end


  describe "#visibility_changed_update" do
    context "when curation_concern is private and @visibility_changed_to_private is true" do
      before {
        allow(subject).to receive(:curation_concern).and_return OpenStruct.new(private?: true)
        subject.instance_variable_set(:@visibility_changed_to_private, true)
        allow(subject).to receive(:workflow_unpublish)
      }
      it "calls workflow_unpublish" do
        expect(subject).to receive(:curation_concern)
        expect(subject).to receive(:workflow_unpublish)

        subject.visibility_changed_update
      end
    end

    concerns = [{:private => true, :changed_to_private => false},
                {:private => false, :changed_to_private => true},
                {:private => false, :changed_to_private => false}]
    concerns.each do |concern|
      context "when curation_concern is #{concern[:private] ? "" : "NOT"} private and @visibility_changed_to_private is #{concern[:changed_to_private]}" do
        before {
          allow(subject).to receive(:curation_concern).and_return OpenStruct.new(private?: concern[:private])
          subject.instance_variable_set(:@visibility_changed_to_private, concern[:changed_to_private])
        }
        publicity = [{:public => true, :changed_to_public => false},
                     {:public => false, :changed_to_public => true},
                     {:public => false, :changed_to_public => false},
                     {:public => true, :changed_to_public => false} ]
        publicity.each do |publishing|
          context "when curation_concern is #{publishing[:public] ? "" : "NOT"} public and @visibility_changed_to_public is #{publishing[:changed_to_public]}" do
            before {
              allow(subject).to receive(:curation_concern).and_return OpenStruct.new(public?: publishing[:public])
              subject.instance_variable_set(:@visibility_changed_to_public, publishing[:changed_to_public])
              allow(subject).to receive(:workflow_publish)
            }
            it "#{publishing[:publish] ? "calls workflow_publish" : "returns nil"}" do
              expect(subject).to receive(:curation_concern).twice
              expect(subject).not_to receive(:workflow_unpublish)

              if publishing[:publish] && publishing[:changed_to_public]
                expect(subject).to receive(:workflow_publish)
              else
                expect(subject).not_to receive(:workflow_publish)
              end

              subject.visibility_changed_update
            end
          end
        end
      end
    end
  end


  describe "#visibility_to_private?" do
    before {
      allow(subject).to receive(:params).and_return "data_set" => {"visibility" => "restricted"}
    }

    context "when curation_concern is private" do
      before {
        allow(subject).to receive(:curation_concern).and_return OpenStruct.new(private?: true)
      }
      it "returns false" do
        expect(subject.visibility_to_private?).to eq false
      end
    end

    context "when curation_concern is NOT private" do
      before {
        allow(subject).to receive(:curation_concern).and_return OpenStruct.new(private?: false)
      }
      it "returns whether visibility param is set to VISIBILITY_TEXT_VALUE_PRIVATE" do
        expect(subject.visibility_to_private?).to eq true
      end
    end
  end


  describe "#visibility_to_public?" do
    before {
      allow(subject).to receive(:params).and_return "data_set" => {"visibility" => "open"}
    }

    context "when curation_concern is public" do
      before {
        allow(subject).to receive(:curation_concern).and_return OpenStruct.new(public?: true)
      }
      it "returns false" do
        expect(subject.visibility_to_public?).to eq false
      end
    end

    context "when curation_concern is NOT public" do
      before {
        allow(subject).to receive(:curation_concern).and_return OpenStruct.new(public?: false)
      }
      it "returns whether visibility param is set to VISIBILITY_TEXT_VALUE_PUBLIC" do
        expect(subject.visibility_to_public?).to eq true
      end
    end
  end


  describe "#mark_as_set_to_private" do
    before {
      subject.instance_variable_set(:@visibility_changed_to_public, nil)
      subject.instance_variable_set(:@visibility_changed_to_private, nil)
    }
    it "sets instance variables values to private" do
      subject.mark_as_set_to_private

      expect(subject.instance_variable_get(:@visibility_changed_to_public)).to eq false
      expect(subject.instance_variable_get(:@visibility_changed_to_private)).to eq true
    end
  end


  describe "#mark_as_set_to_public" do
    before {
      subject.instance_variable_set(:@visibility_changed_to_public, nil)
      subject.instance_variable_set(:@visibility_changed_to_private, nil)
    }
    it "sets instance variables values to public" do
      subject.mark_as_set_to_public

      expect(subject.instance_variable_get(:@visibility_changed_to_public)).to eq true
      expect(subject.instance_variable_get(:@visibility_changed_to_private)).to eq false
    end
  end


  describe "#zip_download" do
    before {
      allow(Settings).to receive(:zip_download_dir).and_return "zip "
      allow(Rails).to receive(:root).and_return ["rails ", "root"]
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "zip_download begin", "tmp_dir=rails zip root" ]
      allow(subject).to receive(:target_dir_name_id).with( "rails zip root", "work id").and_return ["target", "dir"]
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "zip_download", "target_dir=[\"target\", \"dir\"]" ]

      allow(Dir).to receive(:mkdir).with( ["target", "dir"] )
      allow(subject).to receive(:target_dir_name_id).with( ["target", "dir"], "work id", ".zip" ).and_return "zipper"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "zip_download", "target_zipfile=zipper" ]

      allow(File).to receive("delete").with "zipper"
      allow(Dir).to receive(:glob).with("target*dir").and_return ["file1", "file2"]
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with(["file1", "file2"], label: "zip_download files to delete:")
      allow(File).to receive(:exist?).with("file1").and_return false
      allow(File).to receive(:exist?).with("file2").and_return true
      allow(File).to receive(:delete).with("file2")
      allow(Deepblue::LoggingHelper).to receive(:debug).with("Download Zip begin copy to folder [\"target\", \"dir\"]")
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with([ "zip_download", "begin copy target_dir=[\"target\", \"dir\"]" ])

      concern = MockCurationConcern.new
      zipfile = MockZipFile.new
      allow(Zip::File).to receive(:open).with("zipper", Zip::File::CREATE).and_return zipfile
      allow(subject).to receive(:curation_concern).and_return concern
      allow(subject).to receive(:export_file_sets_to).with(target_dir: ["target", "dir"], log_prefix: "Zip: ").and_return ["target file name", "target file"]

      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with([ "zip_download", "download complete target_dir=[\"target\", \"dir\"]" ])
      allow(subject).to receive(:send_file).with "zipper"
    }

    context "when target directory already exists and file already exists" do
      before {
        allow(Dir).to receive(:exist?).with( ["target", "dir"] ).and_return true
        allow(File).to receive(:exist?).with("zipper").and_return true
      }
      it "do NOT make target directory, delete target file, send zipfile" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "zip_download begin", "tmp_dir=rails zip root" ]
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "zip_download", "target_dir=[\"target\", \"dir\"]" ]
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "zip_download", "target_zipfile=zipper" ]
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with(["file1", "file2"], label: "zip_download files to delete:")
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with([ "zip_download", "download complete target_dir=[\"target\", \"dir\"]" ])

        expect(Dir).not_to receive(:mkdir).with( ["target", "dir"] )
        expect(File).to receive("delete").with "zipper"
        expect(File).to receive(:delete).with("file2")

        subject.zip_download
      end
    end

    context "when target directory does NOT exist and file does NOT exist" do
      before {
        allow(Dir).to receive(:exist?).with( ["target", "dir"] ).and_return false
        allow(File).to receive(:exist?).with("zipper").and_return false

      }
      it "make target directory, do NOT target delete file, send zipfile" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "zip_download begin", "tmp_dir=rails zip root" ]
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "zip_download", "target_dir=[\"target\", \"dir\"]" ]
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "zip_download", "target_zipfile=zipper" ]
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with(["file1", "file2"], label: "zip_download files to delete:")
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with([ "zip_download", "download complete target_dir=[\"target\", \"dir\"]" ])

        expect(Dir).to receive(:mkdir).with( ["target", "dir"] )
        expect(File).not_to receive("delete").with "zipper"
        expect(File).to receive(:delete).with("file2")

        subject.zip_download
      end
    end

    skip "add tests for inside of Zip::File.open do"

    after {
      expect(Settings).to have_received(:zip_download_dir)
      expect(Rails).to have_received(:root)
      expect(subject).to have_received(:target_dir_name_id).with( "rails zip root", "work id")
      expect(subject).to have_received(:target_dir_name_id).with( ["target", "dir"], "work id", ".zip" )
      expect(Dir).to have_received(:glob).with("target*dir")
      expect(File).to have_received(:exist?).with("file1")
      expect(File).to have_received(:exist?).with("file2")
      expect(Zip::File).to have_received(:open).with("zipper", Zip::File::CREATE)
      expect(subject).to have_received(:send_file).with "zipper"
    }
  end


  describe "#zip_download_enabled?" do
    before {
      allow(Settings).to receive(:zip_download_enabled).and_return true
    }
    it "returns the result of calling Settings.zip_download_enabled" do
      expect(Settings).to receive(:zip_download_enabled)

      expect(subject.zip_download_enabled?).to eq true
    end
  end


  # protected methods

  describe "#emails_did_not_match_msg" do
    it "returns hard-coded string message" do
      expect(subject.send(:emails_did_not_match_msg)).to eq "Emails did not match"
    end
  end


  describe "#export_file_sets_to" do
    predicate = ->(_target_file_name, _target_file) { true }

    before {
      allow(subject).to receive(:curation_concern).and_return MockCurationConcern.new
      allow(Deepblue::ExportFilesHelper).to receive(:export_file_sets).with(target_dir: "target dir",
                                                                            file_sets: "file sets",
                                                                            log_prefix: "",
                                                                            do_export_predicate: predicate,
                                                                            quiet: false)
        }
    it "calls Deepblue::ExportFilesHelper.export_file_sets with parameters" do
      expect(Deepblue::ExportFilesHelper).to receive(:export_file_sets).with(target_dir: "target dir",
                                                                             file_sets: "file sets",
                                                                             log_prefix: "",
                                                                             do_export_predicate: predicate,
                                                                             quiet: false)

      subject.send(:export_file_sets_to, do_export_predicate: predicate, target_dir: "target dir")
    end
  end


  describe "#flash_and_go_back" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:debug).with "flash message"
      allow(subject).to receive(:redirect_back).with(fallback_location: "root url", notice: "flash message")
    }
    it "redirects to root url with notice message parameter" do
      expect(Deepblue::LoggingHelper).to receive(:debug).with "flash message"
      expect(subject).to receive(:redirect_back).with(fallback_location: "root url", notice: "flash message")

      subject.send(:flash_and_go_back, "flash message")
    end
  end


  describe "#flash_error_and_go_back" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:debug).with "error message"
      allow(subject).to receive(:redirect_back).with(fallback_location: "root url", alert: "error message")
    }
    it "redirects to root url with alert message parameter" do
      expect(Deepblue::LoggingHelper).to receive(:debug).with "error message"
      expect(subject).to receive(:redirect_back).with(fallback_location: "root url", alert: "error message")

      subject.send(:flash_error_and_go_back, "error message")
    end
  end


  describe "#flash_and_redirect_to_main_cc" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:debug).with "redirect message"
      allow(subject).to receive(:main_app).and_return "main app"
      allow(subject).to receive(:curation_concern).and_return "curation concern"
      allow(subject).to receive(:redirect_to).with(["main app", "curation concern"], notice: "redirect message")
    }
    it "redirects to main url with notice message parameter" do
      expect(Deepblue::LoggingHelper).to receive(:debug).with "redirect message"
      expect(subject).to receive(:redirect_to).with(["main app", "curation concern"], notice: "redirect message")

      subject.send(:flash_and_redirect_to_main_cc, "redirect message")
    end
  end


  describe "#globus_clean_msg" do
    before {
      allow(MsgHelper).to receive(:t).with( 'data_set.globus_clean_join_html' ).and_return " and "
      allow(MsgHelper).to receive(:t).with( 'data_set.globus_clean', dirs: "dir1 and dir2" ).and_return "The directories are dir1 and dir2."
    }
    it "returns message including director(ies)" do
      expect(subject.send(:globus_clean_msg, ["dir1", "dir2"])).to eq "The directories are dir1 and dir2."
    end
  end


  describe "#globus_file_prep_started_msg" do
    before {
      allow(subject).to receive(:globus_files_when_available).with( user_email: "user email" ).and_return "availability"
      allow(MsgHelper).to receive(:t).with( 'data_set.globus_file_prep_started', when_available: "availability" ).and_return "prep started message"
    }
    it "calls globus_files_when_available with email parameter and returns prep started message" do
      expect(subject).to receive(:globus_files_when_available).with( user_email: "user email" )
      expect(MsgHelper).to receive(:t).with( 'data_set.globus_file_prep_started', when_available: "availability" ).and_return "prep started"

      expect(subject.send(:globus_file_prep_started_msg, user_email: "user email")).to eq "prep started"
    end
  end


  describe "#globus_files_prepping_msg" do
    before {
      allow(subject).to receive(:globus_files_when_available).with( user_email: "user email" ).and_return "availability"
      allow(MsgHelper).to receive(:t).with( 'data_set.globus_files_prepping', when_available: "availability" ).and_return "prepping message"
    }
    it "calls globus_files_when_available with email parameter and returns prepping message" do
      expect(subject).to receive(:globus_files_when_available).with( user_email: "user email" )
      expect(MsgHelper).to receive(:t).with( 'data_set.globus_files_prepping', when_available: "availability" )

      expect(subject.send(:globus_files_prepping_msg, user_email: "user email")).to eq "prepping message"
    end
  end


  describe "#globus_files_when_available" do
    context "when user_email parameter is nil" do
      before {
        allow(MsgHelper).to receive(:t).with( 'data_set.globus_files_when_available' )
      }
      it "returns files when available message" do
        expect(MsgHelper).to receive(:t).with( 'data_set.globus_files_when_available' )

        subject.send(:globus_files_when_available, user_email: nil)
      end
    end

    context "when user_email parameter is NOT nil" do
      before {
        allow(MsgHelper).to receive(:t).with( 'data_set.globus_files_when_available_email', user_email: "useratsomewheredotorg" )
      }
      it "returns files when available message with user email parameter" do
        expect(MsgHelper).to receive(:t).with( 'data_set.globus_files_when_available_email', user_email: "useratsomewheredotorg" )

        subject.send(:globus_files_when_available, user_email: "useratsomewheredotorg")
      end
    end
  end


  describe "#globus_files_available_here" do
    before {
      allow(subject).to receive(:globus_url).and_return "globus_url"
      allow(MsgHelper).to receive(:t).with( 'data_set.globus_files_available_here', globus_url: "globus_url" ).and_return "files available url"
    }
    it "returns files available here message" do
      expect(subject.send(:globus_files_available_here)).to eq "files available url"
    end
  end


  describe "#globus_status_msg" do
    context "when globus_complete? returns true" do
      before {
        allow(subject).to receive(:globus_complete?).and_return true
        allow(subject).to receive(:globus_files_available_here).and_return "files available here"
      }
      it "returns result of globus_files_available_here" do
        expect(subject).to receive(:globus_files_available_here)
        expect(subject).not_to receive(:globus_files_prepping_msg)
        expect(subject).not_to receive(:globus_file_prep_started_msg).with( user_email: "user email" )

        expect(subject.send(:globus_status_msg, user_email: nil)).to eq "files available here"
      end
    end

    context "when globus_complete? returns false" do
      before {
        allow(subject).to receive(:globus_complete?).and_return false
      }
      context "when globus_prepping? returns true" do
        before {
          allow(subject).to receive(:globus_prepping?).and_return true
          allow(subject).to receive(:globus_files_prepping_msg).with( user_email: "user email" ).and_return "files prepping"
        }
        it "returns result of globus_files_prepping_msg with user_email parameter" do
          expect(subject).to receive(:globus_files_prepping_msg).with( user_email: "user email" )
          expect(subject).not_to receive(:globus_files_available_here)
          expect(subject).not_to receive(:globus_file_prep_started_msg).with( user_email: "user email" )

          expect(subject.send(:globus_status_msg, user_email: "user email")).to eq "files prepping"
        end
      end

      context "when globus_prepping? returns false" do
        before {
          allow(subject).to receive(:globus_prepping?).and_return false
          allow(subject).to receive(:globus_file_prep_started_msg).with( user_email: "user email" ).and_return "files prep started"
        }
        it "returns result of globus_file_prep_started_msg with user_email parameter" do
          expect(subject).to receive(:globus_file_prep_started_msg).with( user_email: "user email" )
          expect(subject).not_to receive(:globus_files_prepping_msg).with( user_email: "user email" )
          expect(subject).not_to receive(:globus_files_available_here)

          expect(subject.send(:globus_status_msg, user_email: "user email")).to eq "files prep started"
        end
      end

      after {
        expect(subject).to have_received(:globus_prepping?)
      }
    end

    after {
      expect(subject).to have_received(:globus_complete?)
    }
  end


  describe "#show_presenter" do
    it "returns Hyrax::DataSetPresenter" do
      expect(subject.send(:show_presenter)).to eq Hyrax::DataSetPresenter
    end
  end


  # private methods

  describe "#get_date_uploaded_from_solr" do
    before {
      allow(Solrizer).to receive(:solr_name).with('date_uploaded', :stored_sortable, type: :date).and_return "solr_date_uploaded"
    }

    context "when date uploaded field is blank" do
      it "returns nil" do
        expect(subject.send(:get_date_uploaded_from_solr, OpenStruct.new(solr_document: {"solr_date_uploaded" => ""}))).to be_nil
      end
    end

    context "when date uploaded field is present" do
      context "when date uploaded field is a valid Time" do
        before {
          allow(Time).to receive(:parse).with("date").and_return "uploaded from solr"
        }
        it "returns Time object" do
          expect(Time).to receive(:parse).with("date")

          subject.send(:get_date_uploaded_from_solr, OpenStruct.new(solr_document: {"solr_date_uploaded" => "date"}))
        end
      end

      context "when date uploaded field is NOT a valid time" do
        before {
          allow(Time).to receive(:parse).with("invalid date").and_raise(StandardError)
          allow(subject).to receive(:params).and_return "id" => "ID"
          allow(Rails.logger).to receive(:info).with "Unable to parse date: \"i\" for ID"
        }
        it "calls Rails.logger.info with error message" do
          expect(Time).to receive(:parse).with("invalid date")
          expect(Rails.logger).to receive(:info).with "Unable to parse date: \"i\" for ID"

          subject.send(:get_date_uploaded_from_solr, OpenStruct.new(solr_document: {"solr_date_uploaded" => "invalid date"}))
        end
      end
    end

    after {
      expect(Solrizer).to have_received(:solr_name).with('date_uploaded', :stored_sortable, type: :date)
    }
  end


  describe "#target_dir_name_id" do
    before {
      allow(DeepBlueDocs::Application.config).to receive(:base_file_name).and_return "basename "
    }
    it "" do
      expect(DeepBlueDocs::Application.config).to receive(:base_file_name)

      expect(subject.send(:target_dir_name_id, ["dirA ", "dirB"], "ID ", "extension ")).to eq "dirA basename ID extension dirB"
    end
  end


  describe "#show" do
    it "renders show page" do
      get :show, params: { id: data_set.id }
      expect(response).to render_template(:show)
    end
  end

end
