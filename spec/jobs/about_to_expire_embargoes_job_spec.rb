require 'rails_helper'

class MockJob
  def run(  )
  end

end


RSpec.describe Hyrax::ApplicationJob::AboutToExpireEmbargoesJob do

  describe "#perform" do
    jobObject = MockJob.new

    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with('class', an_instance_of(AboutToExpireEmbargoesJob)).and_return "bundt"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with( 'args', ["cake"] ).and_return "frosting"

      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with([ "here", "called from", "bundt", "args=[\"cake\"]", "frosting", "" ])

      allow(Deepblue::SchedulerHelper).to receive(:log).with( class_name: "AboutToExpireEmbargoesJob", event: "about_to_expire_embargoes" )

      allow(Deepblue::LoggingHelper).to receive(:obj_class).with('options', {"cake"=>nil}).and_return "frosting"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with([[ "here", "options={\"cake\"=>nil}", "frosting", "" ]])

      allow(subject).to receive(:job_options_value).with({"cake"=>nil}, {key: 'email_owner', default_value: true} ).and_return "email_owner"
      allow(subject).to receive(:job_options_value).with({"cake"=>nil}, {key: 'expiration_lead_days'} ).and_return "lead_days"
      allow(subject).to receive(:job_options_value).with({"cake"=>nil}, {key: 'skip_file_sets', default_value: true} ).and_return "skipping"
      allow(subject).to receive(:job_options_value).with({"cake"=>nil}, {key: 'test_mode', default_value: false} ).and_return "la mode"
    }

    context "when verbose" do
      before {
        allow(subject).to receive(:job_options_value).with({"cake"=>nil}, {:key=>"verbose", :default_value=>false} ).and_return true
        allow(Deepblue::LoggingHelper).to receive(:debug).with( "verbose=true" )

        allow(Deepblue::LoggingHelper).to receive(:debug).with( "email_owner=email_owner" )
        allow(Deepblue::LoggingHelper).to receive(:debug).with( "expiration_lead_days=lead_days" )
        allow(Deepblue::LoggingHelper).to receive(:debug).with( "@skip_file_sets=skipping")
        allow(Deepblue::LoggingHelper).to receive(:debug).with( "test_mode=la mode")

        allow(Deepblue::AboutToExpireEmbargoesService).to receive(:new).with( email_owner: "email_owner",
                                                                              expiration_lead_days: "lead_days",
                                                                              skip_file_sets: "skipping",
                                                                              test_mode: "la mode",
                                                                              verbose: true ).and_return(jobObject)
        allow(jobObject).to receive(:run)
      }

      it "calls Deepblue helper methods and logging debug method" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with([ "here", "called from", "bundt", "args=[\"cake\"]", "frosting", "" ])

        expect(Deepblue::SchedulerHelper).to receive(:log).with( class_name: "AboutToExpireEmbargoesJob", event: "about_to_expire_embargoes" )

        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with([ "here", "options={\"cake\"=>nil}", "frosting", "" ])

        expect(subject).to receive(:job_options_value).with({"cake"=>nil}, {:key=>"verbose", :default_value=>false} ).and_return true
        expect(Deepblue::LoggingHelper).to receive(:debug).with( "verbose=true" )

        expect(subject).to receive(:job_options_value).with({"cake"=>nil}, {key: 'email_owner', default_value: true} ).and_return "email_owner"
        expect(Deepblue::LoggingHelper).to receive(:debug).with( "email_owner=email_owner" )

        expect(subject).to receive(:job_options_value).with({"cake"=>nil}, {key: 'expiration_lead_days'} ).and_return "lead_days"
        expect(Deepblue::LoggingHelper).to receive(:debug).with( "expiration_lead_days=lead_days" )

        expect(subject).to receive(:job_options_value).with({"cake"=>nil}, {key: 'skip_file_sets', default_value: true} ).and_return "skipping"
        expect(Deepblue::LoggingHelper).to receive(:debug).with( "@skip_file_sets=skipping")

        expect(subject).to receive(:job_options_value).with({"cake"=>nil}, {key: 'test_mode', default_value: false} ).and_return "la mode"
        expect(Deepblue::LoggingHelper).to receive(:debug).with( "test_mode=la mode")

        expect(Deepblue::AboutToExpireEmbargoesService).to receive(:new).with( email_owner: "email_owner",
                                                                              expiration_lead_days: "lead_days",
                                                                              skip_file_sets: "skipping",
                                                                              test_mode: "la mode",
                                                                              verbose: true ).and_return(jobObject)
        subject.perform "cake"
      end
    end

    context "when not verbose" do
      before {
        allow(subject).to receive(:job_options_value).with({"cake"=>nil}, {:key=>"verbose", :default_value=>false} ).and_return false
        allow(Deepblue::LoggingHelper).to receive(:debug).with( "verbose=false" )

        allow(Deepblue::AboutToExpireEmbargoesService).to receive(:new).with( email_owner: "email_owner",
                                                                              expiration_lead_days: "lead_days",
                                                                              skip_file_sets: "skipping",
                                                                              test_mode: "la mode",
                                                                              verbose: false ).and_return(jobObject)
      }

      it "calls Deepblue helper methods" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with([ "here", "called from", "bundt", "args=[\"cake\"]", "frosting", "" ])
        expect(Deepblue::SchedulerHelper).to receive(:log).with( class_name: "AboutToExpireEmbargoesJob", event: "about_to_expire_embargoes" )
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with([ "here", "options={\"cake\"=>nil}", "frosting", "" ])

        expect(subject).to receive(:job_options_value).with({"cake"=>nil}, {:key=>"verbose", :default_value=>false} ).and_return false

        expect(subject).to receive(:job_options_value).with({"cake"=>nil}, {key: 'email_owner', default_value: true} ).and_return "email_owner"

        expect(subject).to receive(:job_options_value).with({"cake"=>nil}, {key: 'expiration_lead_days'} ).and_return "lead_days"

        expect(subject).to receive(:job_options_value).with({"cake"=>nil}, {key: 'skip_file_sets', default_value: true} ).and_return "skipping"

        expect(subject).to receive(:job_options_value).with({"cake"=>nil}, {key: 'test_mode', default_value: false} ).and_return "la mode"

        expect(Deepblue::AboutToExpireEmbargoesService).to receive(:new).with( email_owner: "email_owner",
                                                                               expiration_lead_days: "lead_days",
                                                                               skip_file_sets: "skipping",
                                                                               test_mode: "la mode",
                                                                               verbose: false ).and_return(jobObject)
        subject.perform "cake"
      end
    end

    context "when exception occurs" do
      it "catches exceptions" do
        skip "Add a test"
      end
    end
  end
end
