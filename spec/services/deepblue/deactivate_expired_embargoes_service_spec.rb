require 'rails_helper'

class MockExpiredAsset

  def initialize (model_name: "FileSet")
    @model_name = model_name
  end
  def to_ary
    [self]
  end

  def model_name
    @model_name
  end

  def id
    "101"
  end

  def human_readable_type
    "typographic"
  end

  def solr_document
    OpenStruct.new(title: 'solaris')
  end

  def embargo_release_date
    "April 2nd 2025"
  end

  def visibility_after_embargo
    "sparkling clear"
  end
end



RSpec.describe Deepblue::DeactivateExpiredEmbargoesService do

  describe "#initialize" do
    subject { described_class.new( email_owner: false, skip_file_sets: false, test_mode: false, to_console: true, verbose: true) }

    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "from"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with("class", anything).and_return "object class"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                   "from",
                                                                   "object class",
                                                                   "email_owner=false",
                                                                   "skip_file_sets=false",
                                                                   "test_mode=false",
                                                                   "to_console=true",
                                                                   "verbose=true",
                                                                   ""]
    }

    it "calls LoggingHelper.bold_debug" do
      expect(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      expect(Deepblue::LoggingHelper).to receive(:called_from).and_return "from"
      expect(Deepblue::LoggingHelper).to receive(:obj_class).with("class", anything).and_return "object class"

      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                    "from",
                                                                    "object class",
                                                                    "email_owner=false",
                                                                    "skip_file_sets=false",
                                                                    "test_mode=false",
                                                                    "to_console=true",
                                                                    "verbose=true",
                                                                    ""]
      subject.instance_variable_get(:@email_owner) == false
      subject.instance_variable_get(:@skip_file_sets) == false
      subject.instance_variable_get(:@test_mode) == false
      subject.instance_variable_get(:@to_console) == true
      subject.instance_variable_get(:@verbose) == true
    end
  end

  describe "#run" do
    mock_asset = MockExpiredAsset.new

    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "from"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with("class", anything).and_return "object class"

      allow(DateTime).to receive(:now).and_return DateTime.new(2025, 6, 1)
      allow(Hyrax::EmbargoService).to receive(:assets_with_expired_embargoes).and_return(mock_asset)
      allow(subject).to receive(:run_msg).with "The number of assets with expired embargoes is: 1"
    }

    context "when verbose is false and asset.model_name is not 'FileSet'" do
      mock_asset_2 = MockExpiredAsset.new(model_name: "Work")
      subject { described_class.new( skip_file_sets: true, verbose: false) }

      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                     "from",
                                                                     ""]

        allow(Hyrax::EmbargoService).to receive(:assets_with_expired_embargoes).and_return(mock_asset_2)

        allow(::ActiveFedora::Base).to receive(:find).with("101").and_return "basic"
        allow(Deepblue::ProvenanceHelper).to receive(:system_as_current_user).and_return "au courant"
        allow(subject).to receive(:deactivate_embargo).with(curation_concern: "basic",
                                                            copy_visibility_to_files: true,
                                                            current_user: "au courant",
                                                            email_owner: true,
                                                            test_mode: true,
                                                            verbose: false )
      }

      it "calls deactivate_embargo" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                      "from",
                                                                      "object class",
                                                                      "@email_owner=true",
                                                                      "@skip_file_sets=true",
                                                                      "@test_mode=true",
                                                                      ""]

        subject.instance_variable_get(:@now) == DateTime.new(2025, 6, 1)
        subject.instance_variable_get(:@assets) == [mock_asset_2]
        expect(subject).not_to receive(:run_msg)
        expect(::ActiveFedora::Base).to receive(:find).with("101").and_return "basic"
        expect(Deepblue::ProvenanceHelper).to receive(:system_as_current_user).and_return "au courant"
        expect(subject).to receive(:deactivate_embargo).with(curation_concern: "basic",
                                                             copy_visibility_to_files: true,
                                                             current_user: "au courant",
                                                             email_owner: true,
                                                             test_mode: true,
                                                             verbose: false )
        subject.run
      end
    end

    context "when verbose is true and @skip_file_sets is false" do
      subject { described_class.new( skip_file_sets: false, verbose: true) }

      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                     "from",
                                                                     ""]

        allow(subject).to receive(:run_msg).with "The number of assets with expired embargoes is: 1"
        allow(subject).to receive(:run_msg).with "0 - 101, FileSet, typographic, solaris April 2nd 2025, sparkling clear"
        allow(::ActiveFedora::Base).to receive(:find).with("101").and_return "basic"
        allow(Deepblue::ProvenanceHelper).to receive(:system_as_current_user).and_return "au courant"
        allow(subject).to receive(:deactivate_embargo).with(curation_concern: "basic",
                                                            copy_visibility_to_files: true,
                                                            current_user: "au courant",
                                                            email_owner: true,
                                                            test_mode: true,
                                                            verbose: true )
      }

      it "outputs messages and calls deactivate_embargo" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                      "from",
                                                                      "object class",
                                                                      "@email_owner=true",
                                                                      "@skip_file_sets=false",
                                                                      "@test_mode=true",
                                                                      ""]

        subject.instance_variable_get(:@now) == DateTime.new(2025, 6, 1)
        subject.instance_variable_get(:@assets) == [mock_asset]
        expect(subject).to receive(:run_msg).with "The number of assets with expired embargoes is: 1"
        expect(subject).to receive(:run_msg).with "0 - 101, FileSet, typographic, solaris April 2nd 2025, sparkling clear"
        expect(::ActiveFedora::Base).to receive(:find).with("101").and_return "basic"
        expect(Deepblue::ProvenanceHelper).to receive(:system_as_current_user).and_return "au courant"
        expect(subject).to receive(:deactivate_embargo).with(curation_concern: "basic",
                                                            copy_visibility_to_files: true,
                                                            current_user: "au courant",
                                                            email_owner: true,
                                                            test_mode: true,
                                                            verbose: true )
        subject.run
      end
    end

    context "when verbose is false and @skip_file-sets is true" do
      subject { described_class.new( skip_file_sets: true, verbose: false) }

      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                     "from",
                                                                     ""]
      }

      it "does not output messages" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
                                                                      "from",
                                                                      "object class",
                                                                      "@email_owner=true",
                                                                      "@skip_file_sets=true",
                                                                      "@test_mode=true",
                                                                      ""]
        expect(subject).not_to receive(:run_msg)
        expect(subject).not_to receive(:deactivate_embargo)

        subject.instance_variable_get(:@now) == DateTime.new(2025, 6, 1)
        subject.instance_variable_get(:@assets) == [mock_asset]

        subject.run
      end
    end
  end

  describe "#run_msg" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:debug).with "message"
    }

    context "when @to_console is false" do
      before {
        subject.instance_variable_set(:@to_console, false)
      }
      it "calls LoggingHelper.debug" do
        expect(Deepblue::LoggingHelper).to receive(:debug).with "message"

        subject.run_msg "message"
      end
    end

    context "when @to_console is true" do
      before {
        subject.instance_variable_set(:@to_console, true)
      }
      it "calls LoggingHelper.debug" do
        expect(Deepblue::LoggingHelper).to receive(:debug).with "message"
        expect(subject).to receive(:puts).with("message")

        subject.run_msg "message"
      end
    end
  end

end
