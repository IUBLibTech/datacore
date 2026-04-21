require 'rails_helper'
require 'tasks/abstract_task'

class StdoutLoggerMock

  def level=(level)
  end
end

class MockWorkRelation
  def initialize(work)
    @work = work
  end

  def find(id)
    @work
  end
end

class From
  def to_s
    "from"
  end

  def statistics(object, start_date, user_id)
    "statistics"
  end
end

class MockStatImporterUser
  def initialize(id, name)
    @id = id
    @name = name
  end

  def id
    @id
  end
  def to_s
    "#{@name}"
  end
end

class MockOrderedObject
  def initialize(objects)
    @objects = objects
  end
  def order(date: )
    date == :asc  ?  @objects.sort_by!(&:date)  :  @objects.sort_by!(&:date).reverse
  end

  def last
    @objects.last
  end
end

class MockRetrieval
  def first_or_initialize(user_id:, date:)
    MockUserStat.new
  end

end

class MockUserStat
  def initialize
    @file_views = nil
    @file_downloads = nil
    @work_views = nil
  end

  def file_views=(file_views)
    @file_views = file_views
  end

  def file_downloads=(file_downloads)
    @file_downloads = file_downloads
  end
  def work_views=(work_views)
    @work_views = work_views
  end

  def save!
  end
end


class MockTallyStats
  def initialize(date)
    @date = date
  end

  def date
    @date
  end

  def defenestration
    66
  end
end


RSpec.describe Hyrax::UserStatImporter do

  subject { described_class.new }

  before {
    allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
    allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "from"
    allow(Deepblue::LoggingHelper).to receive(:obj_class).with('class', anything).and_return "obj class"
    allow(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "from", "obj class", "" ]
  }

  describe "#initialize" do
    stdout_logger = StdoutLoggerMock.new
    context "when the options parameter includes :echo_to_stdout" do
      before {
        allow(Logger).to receive(:new).with(STDOUT).and_return stdout_logger
        allow(ActiveSupport::Logger).to receive(:broadcast).with(stdout_logger).and_return "broadcast extension"
        allow(Rails.logger).to receive(:extend).with "broadcast extension"
      }

      it "creates a new logger" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "from", "obj class", ""]
        expect(stdout_logger).to receive(:level=).with Logger::INFO
        expect(ActiveSupport::Logger).to receive(:broadcast).with(stdout_logger)
        expect(Rails.logger).to receive(:extend).with "broadcast extension"

        userStatImporter = Hyrax::UserStatImporter.new(:echo_to_stdout => true)
        expect(userStatImporter.instance_variable_get(:@process_works)).to eq true
        expect(userStatImporter.instance_variable_get(:@process_files)).to eq false
        expect(userStatImporter.instance_variable_get(:@create_or_update_user_stats)).to eq false
      end
    end

    context "when the options parameter does NOT include :echo_to_stdout" do
      it "does NOT create a new logger" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "from", "obj class", ""]

        expect(stdout_logger).not_to receive(:level=).with Logger::INFO
        expect(ActiveSupport::Logger).not_to receive(:broadcast).with(stdout_logger)
        expect(Rails.logger).not_to receive(:extend).with "broadcast extension"

        importer = Hyrax::UserStatImporter.new()
        expect(importer.instance_variable_get(:@process_works)).to eq true
        expect(importer.instance_variable_get(:@process_files)).to eq false
        expect(importer.instance_variable_get(:@create_or_update_user_stats)).to eq false
      end
    end

    context "when the options parameter includes :verbose, :logging, :delay_secs, :number_of_tries, and :test" do
      before {
        allow(Deepblue::LoggingHelper).to receive(:debug).with("@verbose=true")
        allow(Deepblue::LoggingHelper).to receive(:debug).with("@logging=captain's log")
        allow(Deepblue::LoggingHelper).to receive(:debug).with("@delay_secs=2.0")
        allow(Deepblue::LoggingHelper).to receive(:debug).with("@number_of_tries=4")
        allow(Deepblue::LoggingHelper).to receive(:debug).with("@test=testing 1,2,3")
      }

      options = [{:verbose => true, :text => "and logs them"}, {:verbose => false, :text => ""}]
      options.each do |option|

        context "when :verbose option is #{option[:verbose]}" do
          it "sets instance variables with values from options parameter" do
            expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "from", "obj class", ""]

            if option[:verbose]
              expect(Deepblue::LoggingHelper).to receive(:debug).with("@verbose=true")
              expect(Deepblue::LoggingHelper).to receive(:debug).with("@logging=captain's log")
              expect(Deepblue::LoggingHelper).to receive(:debug).with("@delay_secs=2.0")
              expect(Deepblue::LoggingHelper).to receive(:debug).with("@number_of_tries=4")
              expect(Deepblue::LoggingHelper).to receive(:debug).with("@test=testing 1,2,3")
            end

            usi = Hyrax::UserStatImporter.new(:verbose => true, :logging => "captain's log", :delay_secs => "2",
                                              :number_of_retries => "3", :test => "testing 1,2,3")
            expect(usi.instance_variable_get(:@verbose)).to eq true
            expect(usi.instance_variable_get(:@logging)).to eq "captain's log"
            expect(usi.instance_variable_get(:@delay_secs)).to eq 2.0
            expect(usi.instance_variable_get(:@number_of_tries)).to eq 4
            expect(usi.instance_variable_get(:@test)).to eq "testing 1,2,3"

            expect(usi.instance_variable_get(:@process_works)).to eq true
            expect(usi.instance_variable_get(:@process_files)).to eq false
            expect(usi.instance_variable_get(:@create_or_update_user_stats)).to eq false
          end
        end
      end
    end
  end

  skip "add a test for method delegated"


  describe "#import" do
    before {
      allow(subject).to receive(:log_message).with('Begin import of User stats.')
      allow(subject).to receive(:sorted_users).and_return ["Kendra", "George"]
      allow(subject).to receive(:log_message).with('users.size=2')
      allow(subject).to receive(:date_since_last_cache).with("Kendra").and_return "02-01-2026"
      allow(subject).to receive(:date_since_last_cache).with("George").and_return "02-11-2026"
      allow(Time.zone).to receive(:today).and_return DateTime.new(2026, 2, 10)
      allow(subject).to receive(:log_message).with( "processing user Kendra with start_date 02-01-2026" )
      allow(subject).to receive(:log_message).with( "processing user George with start_date 02-11-2026" )

      allow(subject).to receive(:log_message).with('User stats import complete.')
    }

    context "when @process_files, @process_works, and @create_or_update_user_stats are true" do
      before {
        subject.instance_variable_set(:@process_files, true)
        subject.instance_variable_set(:@process_works, true)
        subject.instance_variable_set(:@create_or_update_user_stats, true)
      }
      it "imports user stats for unprocessed users" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "from", "obj class", ""]
        expect(subject).to receive(:log_message).with('Begin import of User stats.')
        expect(subject).to receive(:log_message).with('users.size=2')

        expect(subject).to receive(:log_message).with( "processing user Kendra with start_date 02-01-2026" )
        expect(subject).to receive(:process_files).with({ }, "Kendra", "02-01-2026")
        expect(subject).to receive(:process_works).with({ }, "Kendra", "02-01-2026")
        expect(subject).to receive(:create_or_update_user_stats).with({ }, "Kendra")

        expect(subject).to receive(:log_message).with( "processing user George with start_date 02-11-2026" )
        expect(subject).to receive(:log_message).with('User stats import complete.')

        subject.import
      end
    end

    context "when @process_files, @process_works, and @create_or_update_user_stats are false" do
      before {
        subject.instance_variable_set(:@process_files, false)
        subject.instance_variable_set(:@process_works, false)
        subject.instance_variable_set(:@create_or_update_user_stats, false)
      }
      it "logs user stats as imported for unprocessed users" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "from", "obj class", ""]
        expect(subject).to receive(:log_message).with('Begin import of User stats.')
        expect(subject).to receive(:log_message).with('users.size=2')
        expect(subject).to receive(:log_message).with( "processing user Kendra with start_date 02-01-2026" )

        expect(subject).not_to receive(:process_files)
        expect(subject).not_to receive(:process_works)
        expect(subject).not_to receive(:create_or_update_user_stats)

        expect(subject).to receive(:log_message).with( "processing user George with start_date 02-11-2026" )
        expect(subject).to receive(:log_message).with('User stats import complete.')

        subject.import
      end
    end

    after {
      expect(subject).to have_received(:sorted_users)
      expect(subject).to have_received(:date_since_last_cache).with("Kendra")
      expect(subject).to have_received(:date_since_last_cache).with("George")
    }
  end


  describe "#sorted_users" do
    user1 = OpenStruct.new(id: "101", user_key: "k101")
    user2 = OpenStruct.new(id: "202", user_key: "k202")
    before {
      allow(User).to receive(:find_each).and_return [user1, user2]
      allow(subject).to receive(:date_since_last_cache).with(user1).and_return "02-18-2026"
      allow(subject).to receive(:date_since_last_cache).with(user2).and_return "02-19-2026"
      allow(Hyrax::UserStatImporter::UserRecord).to receive(:new).with("101", "k101", "02-18-2026").and_return "user 1"
      allow(Hyrax::UserStatImporter::UserRecord).to receive(:new).with("202", "k202", "02-19-2026").and_return "user 2"
    }

    context "when @test is true" do
      before {
        subject.instance_variable_set(:@test, true)
      }
      it "returns unsorted users" do
        expect(User).to receive(:find_each)
        subject.sorted_users
      end

      skip "Add a test for new UserRecords and results"
    end

    context "when @test is false" do
      before {
        subject.instance_variable_set(:@test, false)
      }
      it "returns sorted users" do
        expect(User).to receive(:find_each)
        subject.sorted_users
      end

      skip "Add a test for new UserRecords and sorted results"
    end
  end


  # private methods

  describe "#process_files" do
    before {
      allow(subject).to receive(:log_message).with("process files user=the user start_date=the start date")
    }

    context "when @test is true" do
      before {
        subject.instance_variable_set(:@test, true)
      }
      it "returns nil" do
        expect(subject).to receive(:log_message).with("process files user=the user start_date=the start date")

        expect(subject.send(:process_files, "stats", "the user", "the start date")).to be_nil
      end
    end

    context "when @test is false" do
      before {
        subject.instance_variable_set(:@test, false)

        allow(subject).to receive(:file_ids_for_user).with("the user").and_return ["file_id"]
        allow(FileSet).to receive(:find).with("file_id").and_return "the file"

        allow(subject).to receive(:delay)
      }

      file_stats = [{:view_stats => "view stats", :dl_stats => "dl stats"},
                    {:view_stats => "view stats", :dl_stats => nil},
                    {:view_stats => nil, :dl_stats => "dl stats"},
                    {:view_stats => nil, :dl_stats => nil}]
      file_stats.each do |file_stat|
        before {
          allow(subject).to receive(:extract_stats_for).with(object: "the file", from: FileViewStat, start_date: "the start date", user: "the user").and_return file_stat[:view_stats]
          allow(subject).to receive(:tally_results).with(file_stat[:view_stats], :views, "stats").and_return "tally view results"

          allow(subject).to receive(:extract_stats_for).with(object: "the file", from: FileDownloadStat, start_date: "the start date", user: "the user").and_return file_stat[:dl_stats]
          allow(subject).to receive(:tally_results).with(file_stat[:dl_stats], :downloads, !file_stat[:view_stats].nil? ? file_stat[:view_stats] : "stats").and_return "tally download results"
        }
        it "processes the files" do
          expect(subject).to receive(:log_message).with("process files user=the user start_date=the start date")

          expect(subject).to receive(:extract_stats_for).with(object: "the file", from: FileViewStat, start_date: "the start date", user: "the user")
          expect(subject).to receive(:extract_stats_for).with(object: "the file", from: FileDownloadStat, start_date: "the start date", user: "the user")

          if file_stat[:view_stats].nil?
            expect(subject).not_to receive(:tally_results)
          end

          if file_stat[:dl_stats].nil?
            expect(subject).not_to receive(:tally_results)
          end

          expect(subject).to receive(:delay).twice

          expect(subject.send(:process_files, "stats", "the user", "the start date")).to eq ["file_id"]
        end
      end

      skip "Add a test for calling tally_results function"
    end
  end


  describe "#process_works" do
    before {
      allow(subject).to receive(:log_message).with("process works user=the user start_date=the start date")
    }

    context "when @test is true" do
      before {
        subject.instance_variable_set(:@test, true)
      }
      it "returns nil" do
        expect(subject).to receive(:log_message).with("process works user=the user start_date=the start date")

        expect(subject.send(:process_works, "stats", "the user", "the start date")).to be_nil
      end
    end

    context "when @test is false" do
      before {
        subject.instance_variable_set(:@test, false)

        allow(subject).to receive(:work_ids_for_user).with("the user").and_return ["work id 1", "work id 2"]
        allow(subject).to receive(:log_message).with( "processing user the user work work id 1 with start_date the start date" )
        allow(subject).to receive(:log_message).with( "processing user the user work work id 2 with start_date the start date" )
        allow(Hyrax::WorkRelation).to receive(:new).and_return MockWorkRelation.new("work 1")
        allow(Hyrax::WorkRelation).to receive(:new).and_return MockWorkRelation.new("work 2")
        allow(subject).to receive(:extract_stats_for).with(object: "work 1", from: WorkViewStat, start_date: "the start date", user: "the user").and_return "work stats 1"
        allow(subject).to receive(:extract_stats_for).with(object: "work 2", from: WorkViewStat, start_date: "the start date", user: "the user").and_return nil

        allow(subject).to receive(:tally_results).with("work stats 1", :work_views, "stats")
        allow(subject).to receive(:delay)

      }
      it "processes the works" do
        expect(subject).to receive(:log_message).with("process works user=the user start_date=the start date")
        expect(subject).to receive(:work_ids_for_user).with("the user")
        expect(subject).to receive(:log_message).with( "processing user the user work work id 1 with start_date the start date" )
        expect(subject).to receive(:log_message).with( "processing user the user work work id 2 with start_date the start date" )
        expect(subject).not_to receive(:tally_results).with("work stats 2", :work_views, "stats")

        expect(subject).to receive(:delay).twice

        expect(subject.send(:process_works, "stats", "the user", "the start date")).to eq ["work id 1", "work id 2"]
      end

      skip "Add a test for calling tally_results function"
    end
  end


  describe "#extract_stats_for" do
    before {
      allow(subject).to receive(:rescue_and_retry).with("Retried from on user name for the class the id too many times.")
    }
    it "calls rescue_and_retry" do
      expect(subject).to receive(:rescue_and_retry).with("Retried from on user name for the class the id too many times.")

      from = From.new
      object = OpenStruct.new(class: "the class", id: "the id")

      subject.send(:extract_stats_for, object: object, from: from, start_date: "the start date", user: MockStatImporterUser.new("user id", "user name"))
    end

    skip "Add a test for calling from.statistics function"
  end


  describe "#delay" do
    before {
      subject.instance_variable_set(:@delay_secs, 67)
      allow(subject).to receive(:sleep).with(67)
    }
    it "calls sleep function with @delay_secs as parameter" do
      expect(subject).to receive(:sleep).with(67)

      subject.send(:delay)
    end
  end


  describe "#rescue_and_retry" do
    before {
      allow(subject).to receive(:retry_options).and_return "retry options"
    }

    context "when no error occurs" do
      before {
        allow(Retriable).to receive(:retriable).with "retry options"
      }
      it "calls Retriable.retriable with retry_options" do
        expect(Retriable).to receive(:retriable).with "retry options"
        subject.send(:rescue_and_retry, "Report of failure")
      end
    end

    context "when a StandardError occurs" do
      before {
        allow(Retriable).to receive(:retriable).with("retry options").and_raise(StandardError)
        allow(subject).to receive(:log_message).with("Report of failure")
        allow(subject).to receive(:log_message).with("Last exception StandardError")
      }
      it "logs fail_message parameter" do
        expect(Retriable).to receive(:retriable).with "retry options"
        expect(subject).to receive(:log_message).with("Report of failure")
        expect(subject).to receive(:log_message).with("Last exception StandardError")

        subject.send(:rescue_and_retry, "Report of failure")
      end
    end
  end


  describe "#date_since_last_cache" do
    context "when previous cached stat exists" do
      before {
        stats = MockOrderedObject.new([OpenStruct.new(date: DateTime.new(2026, 2, 10)), OpenStruct.new(date: DateTime.new(2026, 2, 6))])
        allow(UserStat).to receive(:where).with(user_id: "user id").and_return stats
      }
      it "returns one day since last cached stat" do
        expect(subject.send(:date_since_last_cache, OpenStruct.new(id: "user id"))).to eq DateTime.new(2026, 2, 11)
      end
    end

    context "when previous cached stat does NOT exist" do
      before {
        allow(UserStat).to receive(:where).with(user_id: "user id").and_return MockOrderedObject.new([])
        allow(Hyrax.config).to receive(:analytic_start_date).and_return "analytic start date"
      }
      it "returns result of Hyrax.config.analytic_start_date" do
        expect(Hyrax.config).to receive(:analytic_start_date)
        expect(subject.send(:date_since_last_cache, OpenStruct.new(id: "user id"))).to eq "analytic start date"
      end
    end

    after{
      expect(UserStat).to have_received(:where).with(user_id: "user id")
    }
  end


  describe "#file_ids_for_user" do
    before {
      allow(subject).to receive(:depositor_field).and_return "depositor field"
      allow(FileSet).to receive(:search_in_batches).with("depositor field:\"user key\"", fl: "id").and_return [{"id" => "11"}, {"id" => "12"}, {"id" => "13"}]
    }
    it "calls FileSet.search_in_batches" do
      expect(subject).to receive(:depositor_field).and_return "depositor field"
      expect(FileSet).to receive(:search_in_batches).with("depositor field:\"user key\"", fl: "id")

      subject.send(:file_ids_for_user, OpenStruct.new(user_key: "user key"))
    end

    skip "Add a test for results returned"
  end


  describe "#work_ids_for_user" do
    before {
      allow(subject).to receive(:depositor_field).and_return "depositor field"

      work_relation = double(Hyrax::WorkRelation)
      allow(Hyrax::WorkRelation).to receive(:new).and_return work_relation
      allow(work_relation).to receive(:search_in_batches).with("depositor field:\"user key\"", fl: "id").and_return [Hash.new("id" => "11")]
    }
    it "calls Hyrax::WorkRelation.new.search_in_batches" do
      expect(subject).to receive(:depositor_field).and_return "depositor field"
      expect(Hyrax::WorkRelation).to receive(:new)

      subject.send(:work_ids_for_user, OpenStruct.new(user_key: "user key"))
    end

    skip "Add a test for results returned"
  end


  describe "#tally_results" do
    before {
      allow(Time.zone).to receive(:today).and_return DateTime.new(2026, 2, 14)
    }

    context "when date of first item in current_stats parameter is equal to today" do
      it "returns total_stats parameter unchanged" do
        current_stats = [MockTallyStats.new(DateTime.new(2026, 2, 14)), MockTallyStats.new(DateTime.new(2026, 2, 10)), MockTallyStats.new(DateTime.new(2026, 2, 12))]
        total_stats = {"2026-02-14" => 1, "2026-02-10" => 1, "2026-02-12" => 1}
        expect(subject.send(:tally_results, current_stats, "defenestration", total_stats)).to eq total_stats
      end
    end

    context "when no item dates in current_stats parameter are equal to today" do
      it "returns updated results" do
        current_stats = [MockTallyStats.new(DateTime.new(2026, 2, 13)), MockTallyStats.new(DateTime.new(2026, 2, 10)), MockTallyStats.new(DateTime.new(2026, 2, 12))]

        total_stats = {"2026-02-10T00:00:00+00:00" => {:defenestration=>12}, "2026-02-13T00:00:00+00:00" => {:defenestration=>0}}
        expect(subject.send(:tally_results, current_stats, :defenestration, total_stats)).to eq "2026-02-10T00:00:00+00:00"=>{:defenestration=>78}, "2026-02-12T00:00:00+00:00"=>{:defenestration=>66}, "2026-02-13T00:00:00+00:00"=>{:defenestration=>66}
      end
    end
  end


  describe "#create_or_update_user_stats" do
    before {
      allow(subject).to receive(:log_message).with("create or update user stats user=Max")
    }

    context "when @test is true" do
      before {
        subject.instance_variable_set(:@test, true)
      }
      it "returns nil" do
        expect(subject).to receive(:log_message).with("create or update user stats user=Max")
        expect(subject.send(:create_or_update_user_stats, {}, MockStatImporterUser.new(101, "Max"))).to be_nil
      end
    end

    context "when @test is false" do
      date_key = DateTime.new(2026, 2, 7)
      mock_retrieval = MockRetrieval.new
      mock_user_stat = MockUserStat.new
      before {
        subject.instance_variable_set(:@test, false)
        allow(Time.zone).to receive(:parse).with("2026-02-07").and_return date_key
        allow(UserStat).to receive(:where).with(user_id: 101, date: date_key).and_return mock_retrieval
        allow(mock_retrieval).to receive(:first_or_initialize).with(user_id: 101, date: date_key).and_return mock_user_stat
      }
      it "creates new UserStat if existing one cannot be found and updates it" do
        expect(subject).to receive(:log_message).with("create or update user stats user=Max")
        expect(Time.zone).to receive(:parse).with("2026-02-07")
        expect(UserStat).to receive(:where).with(user_id: 101, date: date_key)
        expect(mock_retrieval).to receive(:first_or_initialize).with(user_id: 101, date: date_key)

        expect(mock_user_stat).to receive(:file_views=).with(22)
        expect(mock_user_stat).to receive(:file_downloads=).with(33)
        expect(mock_user_stat).to receive(:work_views=).with(44)
        expect(mock_user_stat).to receive(:save!)

        hash = {"2026-02-07" => {:views => 22, :downloads => 33, :work_views => 44}}
        subject.send(:create_or_update_user_stats, hash, MockStatImporterUser.new(101, "Max"))
      end
    end
  end


  describe "#log_message" do
    context "when @verbose" do
      before {
        subject.instance_variable_set(:@verbose, true)
        allow(Deepblue::LoggingHelper).to receive(:debug).with "message"
      }
      it "calls Deepblue::LoggingHelper.debug with message parameter" do
        expect(Deepblue::LoggingHelper).to receive(:debug).with "message"

        subject.send(:log_message, "message")
      end
    end

    context "when NOT @verbose" do
      before {
        subject.instance_variable_set(:@verbose, false)
      }
      it "returns nil" do
        expect(Deepblue::LoggingHelper).not_to receive(:debug).with "message"

        expect(subject.send(:log_message, "message")).to be_nil
      end
    end
  end


  describe "#retry_options" do
    before {
      subject.instance_variable_set(:@number_of_tries, 42)
    }
    it "returns @number_of_tries as a hash" do
      expect(subject.send(:retry_options)).to eq :tries => 42
    end
  end

end
