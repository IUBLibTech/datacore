# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'
# require 'app/model/concerns/hydra/access_controls/access_right'
require File.join(Gem::Specification.find_by_name("hydra-access-controls").full_gem_path, "app/models/concerns/hydra/access_controls/access_right.rb")
# require_relative '../lib/rack_multipart_buf_size_setter.rb'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# rubocop:disable Rails/Output
module DeepBlueDocs

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    #
    # reference config values like: DeepBlueDocs::Application.config.variable_name

    # Chimera configuration goes here
    # config.authentication_method = "generic"
    config.authentication_method = "iu"
    # config.authentication_method = "umich"

    config.generators do |g|
      g.test_framework :rspec, spec: true
    end

    # config.middleware.insert_before Rack::Runtime, RackMultipartBufSizeSetter

    # config.dbd_version = 'DBDv1'
    config.dbd_version = 'DBDv2'

    config.show_masthead_announcement = false

    # puts "config.time_zone=#{config.time_zone}"
    config.timezone_offset = DateTime.now.offset
    config.timezone_zone = DateTime.now.zone
    config.datetime_stamp_display_local_time_zone = true

    ## ensure tmp directories are defined
    verbose_init = false
    puts "ENV['TMPDIR']=#{ENV['TMPDIR']}" if verbose_init
    puts "ENV['_JAVA_OPTIONS']=#{ENV['_JAVA_OPTIONS']}" if verbose_init
    puts "ENV['JAVA_OPTIONS']=#{ENV['JAVA_OPTIONS']}" if verbose_init
    tmpdir = ENV['TMPDIR']
    if tmpdir.blank? || tmpdir == '/tmp' || tmpdir.start_with?( '/tmp/' )
      tmpdir = File.absolute_path( './tmp/derivatives/' )
      ENV['TMPDIR'] = tmpdir
    end
    ENV['_JAVA_OPTIONS'] = "-Djava.io.tmpdir=#{tmpdir}" if ENV['_JAVA_OPTIONS'].blank?
    ENV['JAVA_OPTIONS'] = "-Djava.io.tmpdir=#{tmpdir}" if ENV['JAVA_OPTIONS'].blank?
    puts "ENV['TMPDIR']=#{ENV['TMPDIR']}"
    puts "ENV['_JAVA_OPTIONS']=#{ENV['_JAVA_OPTIONS']}" if verbose_init
    puts "ENV['JAVA_OPTIONS']=#{ENV['JAVA_OPTIONS']}" if verbose_init
    puts `echo $TMPDIR`.to_s if verbose_init
    puts `echo $_JAVA_OPTIONS`.to_s if verbose_init
    puts `echo $JAVA_OPTIONS`.to_s if verbose_init

    # For properly generating URLs and minting DOIs - the app may not by default
    # Outside of a request context the hostname needs to be provided.
    config.hostname = Settings.hostname
    # puts "config.hostname=#{config.hostname}"

    ## configure box

    config.box_enabled = false
    config.box_developer_token = nil # replace this with a developer token to override Single Auth
    # config.box_developer_token = 'IGmQMmqw8coKpuQDN3EG4gBrDzn78sGr'.freeze
    config.box_dlib_dbd_box_user_id = '3200925346'
    config.box_ulib_dbd_box_id = '45101723215'
    config.box_verbose = true
    config.box_always_report_not_logged_in_errors = true
    config.box_create_dirs_for_empty_works = true
    config.box_access_and_refresh_token_file = Rails.root.join( 'config', 'box_config.yml' ).freeze
    config.box_access_and_refresh_token_file_init = Rails.root.join( 'config', 'box_config_init.yml' ).freeze
    config.box_integration_enabled = config.box_enabled && ( !config.box_developer_token.nil? ||
        File.exist?( config.box_access_and_refresh_token_file ) )

    ## configure embargo
    config.embargo_enforce_future_release_date = true # now that we have automated embargo expiration
    config.embargo_visibility_after_default_status = ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    config.embargo_visibility_during_default_status = ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    config.embargo_manage_hide_files = true
    config.embargo_allow_children_unembargo_choice = false
    config.embargo_email_rds_hostnames = [ 'testing.deepblue.lib.umich.edu',
                                           'staging.deepblue.lib.umich.edu',
                                           'deepblue.lib.umich.edu' ].freeze
    config.embargo_about_to_expire_email_rds = config.embargo_email_rds_hostnames.include? config.hostname
    config.embargo_deactivate_email_rds = config.embargo_email_rds_hostnames.include? config.hostname

    ## configure for Globus
    # -- To enable Globus for development, create /deepbluedata-globus/download and /deepbluedata-globus/prep
    config.globus_era_timestamp = Time.now.freeze
    config.globus_era_token = config.globus_era_timestamp.to_s.freeze
    if Rails.env.test?
      config.globus_dir = '/tmp/deepbluedata-globus'
      Dir.mkdir config.globus_dir unless Dir.exist? config.globus_dir
    else
      config.globus_dir = Settings.globus_dir
    end
    # puts "globus_dir=#{config.globus_dir}"
    config.globus_dir = Pathname.new config.globus_dir
    config.globus_download_dir = config.globus_dir.join 'download'
    config.globus_prep_dir = config.globus_dir.join 'prep'
    if Rails.env.test?
      Dir.mkdir config.globus_download_dir unless Dir.exist? config.globus_download_dir
      Dir.mkdir config.globus_prep_dir unless Dir.exist? config.globus_prep_dir
    end
    config.globus_enabled = true && Dir.exist?( config.globus_download_dir ) && Dir.exist?( config.globus_prep_dir )
    config.base_file_name = "DeepBlueData_"
    config.globus_base_url = 'https://app.globus.org/file-manager?origin_id=99d8c648-a9ff-11e7-aedd-22000a92523b&origin_path=%2Fdownload%2F'
    config.globus_restart_all_copy_jobs_quiet = true
    config.globus_debug_delay_per_file_copy_job_seconds = 0
    config.globus_after_copy_job_ui_delay_seconds = 3
    if Rails.env.production?
      config.globus_copy_file_group = "dbdglobus"
    else
      config.globus_copy_file_group = nil
    end
    config.globus_copy_file_permissions = "u=rw,g=rw,o=r"

    # deposit notification email addresses
    config.notification_email = Settings.notification_email
    config.user_email = Settings.user_email

    config.max_file_size = 2 * ( 1024 ** 3 )
    config.max_file_size_str = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert(config.max_file_size, {})

    config.max_total_file_size = config.max_file_size * 5
    config.max_total_file_size_str = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert(config.max_total_file_size, {})

    config.max_work_file_size_to_download = 10_000_000_000
    config.min_work_file_size_to_download_warn = 1_000_000_000

    ## configure jira integration
    config.jira_integration_hostnames = [ 'deepblue.local',
                                          'testing.deepblue.lib.umich.edu',
                                          'staging.deepblue.lib.umich.edu',
                                          'deepblue.lib.umich.edu' ].freeze
    config.jira_integration_hostnames_prod = [ 'deepblue.lib.umich.edu' ].freeze
    config.jira_integration_enabled = config.jira_integration_hostnames.include? config.hostname
    config.jira_test_mode = !config.jira_integration_hostnames_prod.include?( config.hostname )
    config.jira_manager_project_key = 'DBHELP'
    config.jira_manager_issue_type = 'Data Deposit'
    # config.jira_manager_project_key = 'BLUEDOC'
    # config.jira_manager_issue_type = 'Story'

    ### file upload and ingest
    config.notify_user_file_upload_and_ingest_are_complete = true
    config.notify_managers_file_upload_and_ingest_are_complete = true

    # ingest characterization config
    config.characterize_excluded_ext_set = { '.csv' => 'text/plain' }.freeze # , '.nc' => 'text/plain' }.freeze
    config.characterize_enforced_mime_type = { '.csv' => 'text/csv' }.freeze # , '.nc' => 'text/plain' }.freeze

    # ingest derivative config
    config.derivative_excluded_ext_set = {}.freeze
    config.derivative_max_file_size = 4_000_000_000 # set to -1 for no limit
    config.derivative_max_file_size_str = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert(config.derivative_max_file_size, precision: 3 )


    # URL for logging the user out of Cosign
    config.logout_prefix = "https://weblogin.umich.edu/cgi-bin/logout?"

    # See references to: DeepBlueDocs::Application.config.relative_url_root
    config.relative_url_root = Settings.relative_url_root unless Rails.env.test?

    # Set the default host for resolving _url methods
    Rails.application.routes.default_url_options[:host] = config.hostname



    # ingest virus scan config
    config.virus_scan_max_file_size = 4_000_000_000
    config.virus_scan_retry = true
    config.virus_scan_retry_on_error = false
    config.virus_scan_retry_on_service_unavailable = true
    config.virus_scan_retry_on_unknown = false

    config.do_ordered_list_hack = true
    config.do_ordered_list_hack_save = true

    config.email_enabled = true
    config.email_log_echo_to_rails_logger = true

    config.provenance_log_name = "provenance_#{Rails.env}.log"
    config.provenance_log_path = Rails.root.join( 'log', config.provenance_log_name )
    config.provenance_log_echo_to_rails_logger = true
    config.provenance_log_redundant_events = true

    config.scheduler_log_echo_to_rails_logger = true
    config.scheduler_job_file = 'scheduler_jobs_prod.yml'
    config.scheduler_heartbeat_email_targets = [ 'fritx@umich.edu' ] # leave empty to disable

    config.upload_log_echo_to_rails_logger = true

  end

end
# rubocop:enable Rails/Output
