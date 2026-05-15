RSpec.shared_examples "PresentsArchiveFile behaviors" do |archive_file_object_factory|
  # expects archive_file_archive_file_object present as subject

  describe "#file_size_value" do
    it "returns an integer" do
      expect(archive_file_object.file_size_value).to be_a Integer
    end
  end

  describe "#large_file?" do
    context "when file size is above fedora ingest limit" do
      before { allow(Settings.ingest.size_limit).to receive(:fedora).and_return(-1) }
      it "returns true" do
        expect(archive_file_object.file_size_value).to be > Settings.ingest.size_limit.fedora
        expect(archive_file_object.large_file?).to be true
      end
    end
    context "when file size is below fedora ingest limit" do
      it "returns false" do
        expect(archive_file_object.file_size_value).to be < Settings.ingest.size_limit.fedora
        expect(archive_file_object.large_file?).to be false
      end
    end
  end

  describe "#exclude_from_zip?" do
    context "when an archived file" do
      before { allow(archive_file_object).to receive(:archive_file?).and_return(true) }
      it "returns true" do
        expect(archive_file_object.archive_file?).to be true
        expect(archive_file_object.exclude_from_zip?).to be true
      end
    end
    context "when a large file" do
      before { allow(archive_file_object).to receive(:large_file?).and_return(true) }
      it "returns true" do
        expect(archive_file_object.large_file?).to be true
        expect(archive_file_object.exclude_from_zip?).to be true
      end
    end
    context "when neither archived nor large" do
      it "returns false" do
        expect(archive_file_object.archive_file?).to be false
        expect(archive_file_object.large_file?).to be false
        expect(archive_file_object.exclude_from_zip?).to be false
      end
    end
  end
end
