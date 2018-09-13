# frozen_string_literal: true

namespace :deepblue do

  # bundle exec rake deepblue:curation_concerns_report['{"ids":"id1 id2"}']
  desc 'Write report of all collection and works'
  task :curation_concerns_report, %i[ options ] => :environment do |_task, args|
    args.with_defaults( options: '{}' )
    options = args[:options]
    task = Deepblue::CurationConcernsReport.new( options: options )
    task.run
  end

end

module Deepblue

  require 'tasks/curation_concern_report_task'
  require 'stringio'

  class CurationConcernsReport < CurationConcernReportTask

    DEFAULT_IDS = ''

    # Produce a report containing: TODO
    # * # of datasets
    # * Total size of the datasets in GB
    # * # of unique depositors
    # * # of repeat depositors
    # * Top 10 file formats (csv, nc, txt, pdf, etc)
    # * Discipline of dataset
    # * Names of depositors

    def initialize( options: {} )
      super( options: options )
      @ids_string = TaskHelper.task_options_value( @options, key: 'ids', default_value: DEFAULT_IDS )
      @ids = if @ids_string.blank?
               []
             else
               @ids_string.split( ' ' )
             end
    end

    def run
      initialize_report_values
      report
    end

    protected

      def initialize_report_values
        super()
      end

      def report
        out_report << "Report started: " << Time.new.to_s << "\n"
        prefix = "#{Time.now.strftime('%Y%m%d')}_curation_concerns_report"
        @collections_file = Pathname.new( '.' ).join "#{prefix}_collections.csv"
        @works_file = Pathname.new( '.' ).join "#{prefix}_works.csv"
        @file_sets_file = Pathname.new( '.' ).join "#{prefix}_file_sets.csv"
        @out_collections = open( collections_file, 'w' )
        @out_works = open( works_file, 'w' )
        @out_file_sets = open( file_sets_file, 'w' )
        print_collection_line( out_collections, header: true )
        print_work_line( out_works, header: true )
        print_file_set_line( out_file_sets, header: true )

        if ids.present?
          report_curation_concerns( ids: ids )
        else
          report_collections
          report_works
        end

        print "\n"
        print "#{collections_file}\n"
        print "#{works_file}\n"
        print "#{file_sets_file}\n"

        out_report << "Report finished: " << Time.new.to_s << "\n"
        out_report << "Total collections: #{total_collections}" << "\n"
        out_report << "Total works: #{total_works}" << "\n"
        out_report << "Total file_sets: #{total_file_sets}" << "\n"
        out_report << "Total collections size: #{human_readable(total_collections_size)}\n"
        out_report << "Unique authors: #{authors.size}\n"
        count = 0
        authors.each_pair { |_key, value| count += 1 if value > 1 }
        out_report << "Repeat authors: #{count}\n"
        out_report << "Unique depositors: #{depositors.size}\n"
        count = 0
        depositors.each_pair { |_key, value| count += 1 if value > 1 }
        out_report << "Repeat depositors: #{count}\n"
        top = top_ten( authors )
        top_ten_print( out_report, "\nTop ten authors:", top )
        top = top_ten( depositors )
        top_ten_print( out_report, "\nTop ten depositors:", top )
        top = top_ten( extensions )
        top_ten_print( out_report, "\nTop ten extensions:", top )
        @out_report_file = Pathname.new( '.' ).join "#{prefix}.txt"
        open( @out_report_file, 'w' ) { |out| out << out_report.string }
        print "\n"
        print "\n"
        print out_report.string
        print "\n"
        STDOUT.flush
      ensure
        unless out_collections.nil?
          out_collections.flush
          out_collections.close
        end
        unless out_works.nil?
          out_works.flush
          out_works.close
        end
        unless out_file_sets.nil?
          out_file_sets.flush
          out_file_sets.close
        end
      end

  end

end
