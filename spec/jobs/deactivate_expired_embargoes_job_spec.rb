require 'rails_helper'

class DeactivateExpiredEmbargoesServiceMock

  def run
  end
end





RSpec.describe DeactivateExpiredEmbargoesJob do

  describe "#perform" do
    deepblue_service = DeactivateExpiredEmbargoesServiceMock.new

    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with('class', DeactivateExpiredEmbargoesJob).and_return "class.class=Job"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with('args', ["opaque"]).and_return "class.class=Args"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "class.class=Job",
                                                                    "args=[\"opaque\"]", "class.class=Args", "" ]

      allow(Deepblue::SchedulerHelper).to receive(:log).with( class_name: "DeactivateExpiredEmbargoesJob", event: "deactivate_expired_embargoes" )
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with("options", "opaque" => nil).and_return "optional"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "options={\"opaque\"=>nil}", "optional", ""]

      allow(subject).to receive(:job_options_value).with({"opaque"=>nil}, key: 'email_owner', default_value: true ).and_return "email owner"
      allow(subject).to receive(:job_options_value).with({"opaque"=>nil}, key: 'skip_file_sets', default_value: true ).and_return "skip file sets"
      allow(subject).to receive(:job_options_value).with({"opaque"=>nil}, key: 'test_mode', default_value: false ).and_return "test mode"
    }

    context "when verbose is false" do
      before {
        allow(subject).to receive(:job_options_value).with({"opaque"=>nil}, key: 'verbose', default_value: false ).and_return false
        allow(Deepblue::DeactivateExpiredEmbargoesService).to receive(:new).with( email_owner: "email owner", skip_file_sets: "skip file sets",
                                                                                  test_mode: "test mode", verbose: false ).and_return deepblue_service
      }
      it "calls LoggingHelper.bold_debug and DeactivateExpiredEmbargoesService.new" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "class.class=Job",
                                                                        "args=[\"opaque\"]", "class.class=Args", "" ]

        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "options={\"opaque\"=>nil}", "optional", ""]

        expect(Deepblue::DeactivateExpiredEmbargoesService).to receive(:new).with( email_owner: "email owner", skip_file_sets: "skip file sets",
                                                                                   test_mode: "test mode", verbose: false )
        expect(deepblue_service).to receive(:run)

        subject.perform("opaque")
      end
    end


    context "when verbose is true" do
      before {
        allow(subject).to receive(:job_options_value).with({"opaque"=>nil}, key: 'verbose', default_value: false ).and_return true
        allow(Deepblue::DeactivateExpiredEmbargoesService).to receive(:new).with( email_owner: "email owner", skip_file_sets: "skip file sets",
                                                                                  test_mode: "test mode", verbose: true ).and_return deepblue_service

        allow(Deepblue::LoggingHelper).to receive(:debug).with "verbose=true"
        allow(Deepblue::LoggingHelper).to receive(:debug).with "email_owner=email owner"
        allow(Deepblue::LoggingHelper).to receive(:debug).with "@skip_file_sets=skip file sets"
        allow(Deepblue::LoggingHelper).to receive(:debug).with "test_mode=test mode"

      }
      it "calls LoggingHelper.bold_debug and DeactivateExpiredEmbargoesService.new, and LoggingHelper.debug four times" do
        expect(Deepblue::LoggingHelper).to receive(:obj_class).with('class', DeactivateExpiredEmbargoesJob)
        expect(Deepblue::LoggingHelper).to receive(:obj_class).with('args', ["opaque"])
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "class.class=Job",
                                                                        "args=[\"opaque\"]", "class.class=Args", "" ]
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "options={\"opaque\"=>nil}", "optional", ""]

        expect(Deepblue::LoggingHelper).to receive(:debug).with "verbose=true"
        expect(Deepblue::LoggingHelper).to receive(:debug).with "email_owner=email owner"
        expect(Deepblue::LoggingHelper).to receive(:debug).with "@skip_file_sets=skip file sets"
        expect(Deepblue::LoggingHelper).to receive(:debug).with "test_mode=test mode"

        expect(Deepblue::DeactivateExpiredEmbargoesService).to receive(:new).with( email_owner: "email owner", skip_file_sets: "skip file sets",
                                                                                   test_mode: "test mode", verbose: true )
        expect(deepblue_service).to receive(:run)

        subject.perform("opaque")
      end
    end


    context "when an exception is raised calling DeactivateExpiredEmbargoesService.new" do
      before {
        allow(subject).to receive(:job_options_value).with({"opaque"=>nil}, key: 'verbose', default_value: false ).and_return false
        allow(Deepblue::DeactivateExpiredEmbargoesService).to receive(:new).with( email_owner: "email owner", skip_file_sets: "skip file sets",
                                                                                  test_mode: "test mode", verbose: false ).and_raise(Exception, "error message")
        allow(Rails.logger).to receive(:error).with(start_with("Exception error message at "))
      }
      it "calls Rails.logger.error twice" do
        expect(Deepblue::LoggingHelper).to receive(:obj_class).with('class', anything)
        expect(Deepblue::LoggingHelper).to receive(:obj_class).with('args', ["opaque"])
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "class.class=Job",
                                                                       "args=[\"opaque\"]", "class.class=Args", "" ]

        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "options={\"opaque\"=>nil}", "optional", ""]

        expect(Deepblue::DeactivateExpiredEmbargoesService).to receive(:new).with( email_owner: "email owner", skip_file_sets: "skip file sets",
                                                                                   test_mode: "test mode", verbose: false )
        expect(Rails.logger).to receive(:error).with(start_with("Exception error message at "))
        expect(Rails.logger).to receive(:error)

        subject.perform("opaque")

        rescue Exception
          # raises Exception
      end
    end

    after {
      expect(subject).to have_received(:job_options_value).with({"opaque"=>nil}, key: 'verbose', default_value: false )
      expect(subject).to have_received(:job_options_value).with({"opaque"=>nil}, key: 'email_owner', default_value: true )
      expect(subject).to have_received(:job_options_value).with({"opaque"=>nil}, key: 'skip_file_sets', default_value: true )
      expect(subject).to have_received(:job_options_value).with({"opaque"=>nil}, key: 'test_mode', default_value: false )

      expect(Deepblue::SchedulerHelper).to have_received(:log).with( class_name: "DeactivateExpiredEmbargoesJob", event: "deactivate_expired_embargoes" )
    }
  end

end
