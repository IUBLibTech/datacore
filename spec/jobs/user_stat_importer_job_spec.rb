require 'rails_helper'

class MockUserStatImporter

  def import
  end
end





RSpec.describe UserStatImporterJob do

  describe "#perform" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with( 'class', subject ).and_return "object JobHelper"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with( 'options', {"chocolate"=>nil} ).and_return "JobHelper options"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "object JobHelper", ""]
      allow(Deepblue::SchedulerHelper).to receive(:log).with( class_name: "UserStatImporterJob", event: "user stat importer" )
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "options={\"chocolate\"=>nil}", "JobHelper options", "" ]
      allow(DeepBlueDocs::Application.config).to receive(:hostname).and_return "expected hostname"
    }

    context "when hostnames from job_options_value do NOT include Application.config.hostname" do
      context "when NOT verbose" do
        before {
          allow(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'verbose', default_value: false ).and_return false
          allow(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'hostnames', default_value: [], verbose: false ).and_return ["unexpected name"]
        }

        it "does NOT call UserStatImporter.new, does NOT call LoggingHelper.debug" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "object JobHelper", ""]
          expect(Deepblue::SchedulerHelper).to receive(:log).with( class_name: "UserStatImporterJob", event: "user stat importer" )
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "options={\"chocolate\"=>nil}", "JobHelper options", "" ]

          expect(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'verbose', default_value: false )
          expect(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'hostnames', default_value: [], verbose: false )

          expect(Hyrax::UserStatImporter).not_to receive(:new)
          subject.perform("chocolate")
        end
      end

      context "when it is verbose" do
        before {
          allow(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'verbose', default_value: false ).and_return true
          allow(Deepblue::LoggingHelper).to receive(:debug).with("verbose=true")
          allow(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'hostnames', default_value: [], verbose: true ).and_return ["unexpected name"]
        }

        it "does NOT call UserStatImporter.new, does call LoggingHelper.debug with verbose=true" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "object JobHelper", ""]
          expect(Deepblue::SchedulerHelper).to receive(:log).with( class_name: "UserStatImporterJob", event: "user stat importer" )
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "options={\"chocolate\"=>nil}", "JobHelper options", "" ]

          expect(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'verbose', default_value: false )
          expect(Deepblue::LoggingHelper).to receive(:debug).with("verbose=true")

          expect(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'hostnames', default_value: [], verbose: true )

          subject.perform("chocolate")
        end
      end
    end

    context "when hostnames from job_options_value include Application.config.hostname and verbose is false" do
      mock_importer = MockUserStatImporter.new
      before {
        allow(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'verbose', default_value: false ).and_return false
        allow(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'hostnames', default_value: [], verbose: false ).and_return ["expected hostname",
                                                                                                                                                 "another hostname"]
        allow(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'test', default_value: true, verbose: false ).and_return "job test"
        allow(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'echo_to_stdout', default_value: false, verbose: false ).and_return "job echo"
        allow(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'logging', default_value: false, verbose: false ).and_return "job logging"
        allow(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'number_of_retries', default_value: nil, verbose: false ).and_return "retry number"
        allow(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'delay_secs', default_value: nil, verbose: false ).and_return "job second delay"
      }

      context "when Exception does NOT occur" do
        before {
          allow(Hyrax::UserStatImporter).to receive(:new).with( echo_to_stdout: "job echo",
                                                                verbose: false,
                                                                delay_secs: "job second delay",
                                                                logging: "job logging",
                                                                number_of_retries: "retry number",
                                                                test: "job test" ).and_return mock_importer
        }

        it "calls UserStatImporter.new" do
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "object JobHelper", ""]
          expect(Deepblue::SchedulerHelper).to receive(:log).with(class_name: "UserStatImporterJob", event: "user stat importer")
          expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "options={\"chocolate\"=>nil}", "JobHelper options", "" ]
          expect(subject).to receive(:job_options_value).with({"chocolate"=>nil}, key: 'verbose', default_value: false )
          expect(subject).to receive(:job_options_value).with({"chocolate"=>nil}, key: 'hostnames', default_value: [], verbose: false )

          expect(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'test', default_value: true, verbose: false ).and_return "job test"
          expect(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'echo_to_stdout', default_value: false, verbose: false ).and_return "job echo"
          expect(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'logging', default_value: false, verbose: false ).and_return "job logging"
          expect(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'number_of_retries', default_value: nil, verbose: false ).and_return "retry number"
          expect(subject).to receive(:job_options_value).with( {"chocolate"=>nil}, key: 'delay_secs', default_value: nil, verbose: false ).and_return "job second delay"

          expect(Hyrax::UserStatImporter).to receive(:new).with( echo_to_stdout: "job echo",
                                                                 verbose: false,
                                                                 delay_secs: "job second delay",
                                                                 logging: "job logging",
                                                                 number_of_retries: "retry number",
                                                                 test: "job test" )
          expect(mock_importer).to receive(:import)

          subject.perform("chocolate")
        end
      end

      context "when Exception occurs" do
        before {
          allow(Hyrax::UserStatImporter).to receive(:new).with( echo_to_stdout: "job echo",
                                                                verbose: false,
                                                                delay_secs: "job second delay",
                                                                logging: "job logging",
                                                                number_of_retries: "retry number",
                                                                test: "job test" ).and_raise(Exception, "error message")
          allow(Rails.logger).to receive(:error).with start_with("Exception error message at ")
        }
        it "calls Rails.logger.error twice" do
          expect(Hyrax::UserStatImporter).to receive(:new).with( echo_to_stdout: "job echo",
                                                                 verbose: false,
                                                                 delay_secs: "job second delay",
                                                                 logging: "job logging",
                                                                 number_of_retries: "retry number",
                                                                 test: "job test" )
          expect(Rails.logger).to receive(:error).with start_with("Exception error message at ")
          expect(Rails.logger).to receive(:error)

          subject.perform("chocolate")

          rescue Exception
          # raises Exception
        end
      end

    end
  end

end
