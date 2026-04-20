require 'rails_helper'
require_relative '../../../lib/tasks/task_helper'
require_relative '../../../lib/tasks/task_logger'

class MockTaskHelper
  include Deepblue::TaskHelper
end

class TaskLoggerMock

  def level=(level)
  end
end

class MockStorage

  def initialize(keys)
    @keys = keys
  end

  def key?(name)
    @keys.include?(name)
  end

  def store(name, value)
  end
end

class MockMeasurement
  def initialize (label = "")
    @label = label
  end

  def label
    @label
  end

  def real
    "+#{@label}"
  end

  def blank?
    @label.blank?
  end

  def format(text)
    "~#{text}"
  end
end

RSpec.describe Deepblue::TaskHelper do

  describe "#self.all_works" do
    works = [{:version => true, :type => "GenericWork"}, {:version => false, :type => "DataSet"}]
    works.each do |work|
      context "when dbd_version_1? is #{work[:version]}" do
        before {
          allow(Deepblue::TaskHelper).to receive(:dbd_version_1?).and_return work[:version]
          allow(work[:type].constantize).to receive(:all)
        }
        it "returns #{work[:type]}.all" do
          expect(work[:type].constantize).to receive(:all)
          Deepblue::TaskHelper.all_works
        end
      end
    end

    after {
      expect(Deepblue::TaskHelper).to have_received(:dbd_version_1?)
    }
  end


  describe "#self.benchmark_report" do    # NOTE: Benchmark::CAPTION = "      user     system      total        real\n"
    before {                              #       Benchmark::FORMAT =  "%10.6u %10.6y %10.6t %10.6r\n"
      subject { MockTaskHelper.new }
      allow(subject).to receive(:puts).with "crimson         user     system      total        real\n"
    }
    context "when total is blank" do
      it "puts each measurement, does not output total" do
        expect(subject).to receive(:puts).with "crimson         user     system      total        real\n"

        expect(Deepblue::TaskHelper.benchmark_report(label: "crimson", first_id: "carnelian", measurements: [])).to be_nil
      end
    end

    context "when total is NOT blank" do
      before {
        allow(Deepblue::TaskHelper).to receive(:seconds_to_readable).with("+forest").and_return "teal"
        allow(subject).to receive(:puts).with "~forest %10.6u %10.6y %10.6t %10.6r is teal\n"

        allow(Deepblue::TaskHelper).to receive(:seconds_to_readable).with("+total").and_return "peridot"
        allow(subject).to receive(:puts).with "total      %10.6u %10.6y %10.6t %10.6r is peridot\n"
      }
      it "puts each measurement and outputs total" do
        expect(subject).to receive(:puts).with "emerald          user     system      total        real\n"
        expect(subject).to receive(:puts).with "~forest %10.6u %10.6y %10.6t %10.6r is teal\n"
        expect(subject).to receive(:puts).with "~total      %10.6u %10.6y %10.6t %10.6r is peridot\n"

        measure = MockMeasurement.new("forest")
        totaled = MockMeasurement.new("total")
        Deepblue::TaskHelper.benchmark_report(label: "emerald", first_id: "chartreuse",
                                                     measurements: [measure], total: totaled)
      end
    end
  end


  describe "#self.dbd_version_1?" do
    dbds = [{:version => "DBDv1", :expected_result => true}, {:version => "DBDv2", :expected_result => false}]

    dbds.each do |dbd|
      context "when config dbd_version is equal to '#{dbd[:version]}'" do
        before {
          allow(DeepBlueDocs::Application.config).to receive(:dbd_version).and_return dbd[:version]
        }
        it "returns #{dbd[:expected_result]}" do
          expect(Deepblue::TaskHelper.dbd_version_1?).to eq dbd[:expected_result]
        end
      end
    end
  end


  describe "#self.dbd_version_2?" do
    dbds = [{:version => "DBDv2", :expected_result => true}, {:version => "DBDv1", :expected_result => false}]

    dbds.each do |dbd|
      context "when config dbd_version is equal to '#{dbd[:version]}'" do
        before {
          allow(DeepBlueDocs::Application.config).to receive(:dbd_version).and_return dbd[:version]
        }
        it "returns #{dbd[:expected_result]}" do
          expect(Deepblue::TaskHelper.dbd_version_2?).to eq dbd[:expected_result]
        end
      end
    end
  end


  describe "#self.ensure_dirs_exist?" do
    before {
      allow(Dir).to receive(:exist?).with("dir1").and_return true
      allow(Dir).to receive(:exist?).with("dir2").and_return false
      allow(Dir).to receive(:mkdir).with("dir2")
    }

    it "makes the directories in the parameter that do not exist" do
      expect(Dir).to receive(:exist?).with("dir1")
      expect(Dir).to receive(:exist?).with("dir2")
      expect(Dir).to receive(:mkdir).with("dir2")

      Deepblue::TaskHelper.ensure_dirs_exist("dir1", "dir2")
    end
  end


  describe "#self.hydra_model_work?" do
    hydras = [{:version => true, :expected_param => "GenericWork", :unexpected_param => "NOT GenericWork"},
              {:version => false, :expected_param => "DataSet", :unexpected_param => "NOT DataSet"}]
    hydras.each do |hydra|
      context "when dbd_version_1? is #{hydra[:version]}" do
        before {
          allow(Deepblue::TaskHelper).to receive(:dbd_version_1?).and_return hydra[:version]
        }
        context "when parameter is #{hydra[:expected_param]}" do
          it "returns true" do
            expect(Deepblue::TaskHelper.hydra_model_work?(hydra_model: hydra[:expected_param])).to eq true
          end
        end
        context "when parameter is #{hydra[:unexpected_param]}" do
          it "returns false" do
            expect(Deepblue::TaskHelper.hydra_model_work?(hydra_model: hydra[:unexpected_param])).to eq false
          end
        end
      end
    end

    after {
      expect(Deepblue::TaskHelper).to have_received(:dbd_version_1?)
    }
  end


  describe "#self.human_readable_size" do
    before {
      allow(ActiveSupport::NumberHelper::NumberToHumanSizeConverter).to receive(:convert).with( 1234567, precision: 3 ).and_return "1.23 MB"
    }
    it "calls NumberToHumanSizeConverter.convert on parameter and returns result" do
      expect(ActiveSupport::NumberHelper::NumberToHumanSizeConverter).to receive(:convert).with( 1234567, precision: 3 )

      expect(Deepblue::TaskHelper.human_readable_size("1234567")).to eq "1.23 MB"
    end
  end


  describe "#self.logger_new" do
    logger = TaskLoggerMock.new
    before {
      allow(Deepblue::TaskLogger).to receive(:new).with(STDOUT).and_return logger

      allow(Rails).to receive(:logger=).with(logger)
    }
    it "calls TaskLogger.new" do
      expect(Deepblue::TaskLogger).to receive(:new).with(STDOUT)
      expect(logger).to receive(:level=).with(Logger::INFO)
      expect(Rails).to receive(:logger=).with(logger)

      Deepblue::TaskHelper.logger_new(logger_level: Logger::INFO)
    end
  end


  describe "#self.seconds_to_readable" do
    before {
      allow(Deepblue::TaskHelper).to receive(:split_seconds).with(3661).and_return [1, 1, 1, ""]
    }
    it "returns seconds formatted as string hours, minutes and seconds" do
      expect(Deepblue::TaskHelper).to receive(:split_seconds).with(3661)

      expect(Deepblue::TaskHelper.seconds_to_readable(3661)).to eq "1 hours, 1 minutes, and 1 seconds"
    end
  end


  describe "#self.split_seconds" do
    it "returns seconds as numeric hours, minutes, and seconds" do
      expect(Deepblue::TaskHelper.split_seconds(3661)).to eq [1, 1, 1, 3661]
    end
  end


  describe "#self.target_file_name" do
    context "when the files_extracted parameter has the file_set parameter label as a key" do
      before {
        allow(File).to receive(:extname).with("mountain").and_return "base_ext"
        allow(File).to receive(:basename).with("mountain", "base_ext").and_return "valley"
      }
      it "stores file and returns incremented file name" do
        storage = MockStorage.new(["mountain", "valley_001base_ext"])
        expect(storage).to receive(:store).with("valley_002base_ext", true)
        expect(Deepblue::TaskHelper.target_file_name(file_set: OpenStruct.new(label: "mountain"),
                                                     files_extracted: storage)).to eq "valley_002base_ext"
      end
    end

    context "when the files_extracted parameter does NOT have the file_set parameter label as a key" do
      it "stores file and returns filename" do
        files = MockStorage.new(["sea", "lake"])
        expect(files).to receive(:store).with("ocean", true)
        expect(Deepblue::TaskHelper.target_file_name(file_set: OpenStruct.new(label: "ocean"),
                                                     files_extracted: files)).to eq "ocean"
      end
    end
  end


  describe "#self.task_options_parse" do
    context "when parameter is a hash" do
      it "returns parameter" do
        expect(Deepblue::TaskHelper.task_options_parse(:visible => "public")).to eq :visible => "public"
      end
    end

    context "when parameter is blank" do
      it "returns empty hash" do
        expect(Deepblue::TaskHelper.task_options_parse("\t\n")).to be_empty
      end
    end

    context "when parameter is a correct JSON string" do
      before {
        allow(ActiveSupport::JSON).to receive(:decode).with('{"name":"John", "age":"30"}').and_return :name => "John", :age => "30"
      }
      it "returns decoded JSON" do
        expect(Deepblue::TaskHelper.task_options_parse('{"name":"John", "age":"30"}')).to eq  :name => "John", :age => "30"
      end
    end

    context "when parameter is an incorrect JSON string" do
      before {
        allow(ActiveSupport::JSON).to receive(:decode).with('{}incorrect JSON{}').and_raise(ActiveSupport::JSON.parse_error)
      }
      it "returns error hash" do
        result = Deepblue::TaskHelper.task_options_parse('{}incorrect JSON{}')
        expect(result[:options_str]).to eq "{}incorrect JSON{}"
        expect((result[:error].class)).to eq JSON::ParserError
      end
    end
  end


  describe "#self.task_options_value" do

    context "when options parameter is blank" do
      it "returns default_value parameter" do
        expect(Deepblue::TaskHelper.task_options_value(nil, key: nil, default_value: "default")).to eq "default"
      end
    end

    context "when options parameter keys do NOT include key parameter" do
      it "returns default_value parameter" do
        expect(Deepblue::TaskHelper.task_options_value({:blueberry => "cordial"}, key: :fruit, default_value: "default")).to eq "default"
      end
    end

    context "when options parameter keys include key parameter, and verbose parameter is true" do
      before {
        allow(subject).to receive(:puts).with "set key fruit to cherry"
      }
      it "returns value of options parameter key" do
        expect(subject).to receive(:puts).with "set key fruit to cherry"

        expect(Deepblue::TaskHelper.task_options_value({:fruit => "cherry"}, key: :fruit,
                                                       default_value: "default", verbose: true)).to eq "cherry"
      end
    end
  end


  describe "#self.work?" do
    data_types = [{:version => true, :expected_param => GenericWork.new, :unexpected_param => DataSet.new},
                  {:version => false, :expected_param => DataSet.new, :unexpected_param => GenericWork.new}]
    data_types.each do |data_type|
      context "when dbd_version_1? is #{data_type[:version]}" do
        before {
          allow(Deepblue::TaskHelper).to receive(:dbd_version_1?).and_return data_type[:version]
        }

        context "when parameter is a #{data_type[:expected_param].class}" do
          it "returns true" do
            expect(Deepblue::TaskHelper.work?(data_type[:expected_param])).to eq true
          end
        end

        context "when parameter is NOT a #{data_type[:expected_param].class}" do
          it "returns false" do
            expect(Deepblue::TaskHelper.work?(data_type[:unexpected_param].class)).to eq false
          end
        end
      end
    end
  end


  describe "#self.work_discipline" do
    work_fields = [{:version => true, :field => "subject", :expected_result => "subjectivity"},
                   {:version => false, :field => "subject_discipline", :expected_result => "disciplinary"},]

    work_fields.each do |work_field|
      context "when dbd_version_1? is #{work_field[:version]}" do
        before {
          allow(Deepblue::TaskHelper).to receive(:dbd_version_1?).and_return work_field[:version]
        }
        it "returns #{work_field[:field]} field of work parameter" do
          expect(Deepblue::TaskHelper.work_discipline(work: OpenStruct.new(subject: "subjectivity", subject_discipline: "disciplinary")))
            .to eq  work_field[:expected_result]
        end
      end
    end
  end


  describe "#self.work_find" do
    works = [{:version => true, :expected_type => "GenericWork" }, {:version => false, :expected_type => "DataSet"}]

    works.each do |work|
      context "when dbd_version_1? is #{work[:version]}" do
        before {
          allow(Deepblue::TaskHelper).to receive(:dbd_version_1?).and_return work[:version]
          allow(work[:expected_type].constantize).to receive(:find).with(747).and_return work[:expected_type]
        }
        it "finds #{work[:expected_type]} by id" do
          expect(work[:expected_type].constantize).to receive(:find).with(747)

          expect(Deepblue::TaskHelper.work_find(id: 747)).to eq work[:expected_type]
        end
      end
    end
  end


end
