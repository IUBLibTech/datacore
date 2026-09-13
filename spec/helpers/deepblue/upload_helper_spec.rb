RSpec.describe Deepblue::UploadHelper, type: :helper do

  describe '#self.echo_to_rails_logger' do
    before {
      allow(DeepBlueDocs::Application.config).to receive(:upload_log_echo_to_rails_logger).and_return "upload log rails echo"
    }

    context "when class variable has value" do
      before {
        Deepblue::UploadHelper.class_variable_set(:@@echo_to_rails_logger, "echo to upload rails logger")
      }
      it "returns value" do
        expect(DeepBlueDocs::Application.config).not_to receive(:upload_log_echo_to_rails_logger)

        expect(Deepblue::UploadHelper.echo_to_rails_logger).to eq "echo to upload rails logger"
      end
    end

    context "when class variable has NO value" do
      before {
        Deepblue::UploadHelper.class_variable_set(:@@echo_to_rails_logger, nil)
      }
      it "calls upload_log_echo_to_rails_logger, sets class variable and returns its value" do
        expect(DeepBlueDocs::Application.config).to receive(:upload_log_echo_to_rails_logger)
        expect(Deepblue::UploadHelper.echo_to_rails_logger).to eq "upload log rails echo"
        expect(Deepblue::UploadHelper.class_variable_get(:@@echo_to_rails_logger)).to eq "upload log rails echo"
      end
    end
  end


  describe "#self.echo_to_rails_logger=" do
    it "sets the value of the class variable" do
      Deepblue::UploadHelper.echo_to_rails_logger = "rails echo upload"

      expect(Deepblue::UploadHelper.class_variable_get(:@@echo_to_rails_logger)).to eq "rails echo upload"
    end
  end


  describe "#self.log" do
    before {
      allow(Deepblue::JsonLoggerHelper).to receive(:timestamp_now).and_return "the endless now"
      allow(Deepblue::JsonLoggerHelper).to receive(:timestamp_zone).and_return "the Time Zone"
      allow(Deepblue::UploadHelper).to receive(:msg_to_log).and_return "Captain's Log"
      allow(Deepblue::UploadHelper).to receive(:log_raw)
      allow(Rails.logger).to receive(:info)
    }

    context "when echo_to_rails_logger parameter has a value" do
      it "calls log_raw and Rails.logger.info" do
        expect(Deepblue::UploadHelper).to receive(:msg_to_log)
        expect(Deepblue::UploadHelper).to receive(:log_raw).with "Captain's Log"
        expect(Rails.logger).to receive(:info).with "Captain's Log"

        Deepblue::UploadHelper.log(event_note: 'event note')
      end
    end

    context "when echo_to_rails_logger parameter has NO value" do
      it "calls log_raw" do
        expect(Deepblue::UploadHelper).to receive(:msg_to_log)
        expect(Deepblue::UploadHelper).to receive(:log_raw).with "Captain's Log"
        expect(Rails.logger).not_to receive(:info)

        Deepblue::UploadHelper.log(event_note: 'event note', echo_to_rails_logger: nil)
      end
    end
  end


  describe "#self.log_raw" do
    skip "Add a test"
  end


  describe "#self.uploaded_file_id" do
    context "when id field is present" do
      it "returns id" do
        expect(Deepblue::UploadHelper.uploaded_file_id(OpenStruct.new(id: "42A"))).to eq "42A"
      end
    end

    context "when id field is NOT present" do
      it "returns nil" do
        expect(Deepblue::UploadHelper.uploaded_file_id(OpenStruct.new(log: "Captain's Log"))).to be_nil
      end
    end
  end


  describe "#self.uploaded_file_path" do
    it "returns file path" do
      expect(Deepblue::UploadHelper.uploaded_file_path(OpenStruct.new(file: OpenStruct.new(path: "here/there")))).to eq "here/there"
    end
  end


  describe "#self.uploaded_file_size" do
    before {
      allow(File).to receive(:size).with("here/there").and_return "4.3 MB"
    }
    it "returns file size" do
      expect(Deepblue::UploadHelper.uploaded_file_size(OpenStruct.new(file: OpenStruct.new(path: "here/there")))).to eq "4.3 MB"
    end
  end


end
