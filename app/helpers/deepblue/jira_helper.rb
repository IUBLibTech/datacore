# frozen_string_literal: true

module Deepblue

  require 'jira-ruby'

  module JiraHelper
    extend ActionView::Helpers::TranslationHelper

    FIELD_NAME_CONTACT_INFO = "customfield_11315".freeze
    FIELD_NAME_CREATOR = "customfield_11304".freeze
    FIELD_NAME_DEPOSIT_ID = "customfield_11303".freeze
    FIELD_NAME_DEPOSIT_URL = "customfield_11305".freeze
    FIELD_NAME_DESCRIPTION = "description".freeze
    FIELD_NAME_DISCIPLINE = "customfield_11309".freeze
    FIELD_NAME_STATUS = "customfield_12000".freeze
    FIELD_NAME_SUMMARY = "summary".freeze

    FIELD_VALUES_DISCIPLINE_MAP = {
        "Arts" =>
        [{
            # "self" => "https://tools.lib.umich.edu/jira/rest/api/2/customFieldOption/11303",
            "value" => "Arts",
            "id" => "11303"
        }],
        "Business" =>
        [{
            # "self" => "https://tools.lib.umich.edu/jira/rest/api/2/customFieldOption/10820",
            "value" => "Business",
            "id" => "10820"
        }],
        "Engineering" =>
        [{
            # "self" => "https://tools.lib.umich.edu/jira/rest/api/2/customFieldOption/10821",
            "value" => "Engineering",
            "id" => "10821"
        }],
        "General Information Sources" =>
        [{
            # "self" => "https://tools.lib.umich.edu/jira/rest/api/2/customFieldOption/11304",
            "value" => "General Information Sources",
            "id" => "11304"
        }],
        "Government, Politics, and Law" =>
        [{
            # "self" => "https://tools.lib.umich.edu/jira/rest/api/2/customFieldOption/11305",
            "value" => "Government, Politics, and Law",
            "id" => "11305"
        }],
        "Health Sciences" =>
        [{
            # "self" => "https://tools.lib.umich.edu/jira/rest/api/2/customFieldOption/10822",
            "value" => "Health Sciences",
            "id" => "10822"
        }],
        "Humanities" =>
        [{
            # "self" => "https://tools.lib.umich.edu/jira/rest/api/2/customFieldOption/11306",
            "value" => "Humanities",
            "id" => "11306"
        }],
        "International Studies" =>
        [{
            # "self" => "https://tools.lib.umich.edu/jira/rest/api/2/customFieldOption/11307",
            "value" => "International Studies",
            "id" => "11307"
        }],
        "News and Current Events" =>
        [{
            # "self" => "https://tools.lib.umich.edu/jira/rest/api/2/customFieldOption/11308",
            "value" => "News and Current Events",
            "id" => "11308"
        }],
        "Science" =>
        [{
            # "self" => "https://tools.lib.umich.edu/jira/rest/api/2/customFieldOption/10824",
            "value" => "Science",
            "id" => "10824"
        }],
        "Social Sciences" =>
        [{
            # "self" => "https://tools.lib.umich.edu/jira/rest/api/2/customFieldOption/10825",
            "value" => "Social Sciences",
            "id" => "10825"
        }],
        "Other" =>
        [{
            # "self" => "https://tools.lib.umich.edu/jira/rest/api/2/customFieldOption/10823",
            "value" => "Other",
            "id" => "10823"
        }]
    }.freeze

    def self.jira_enabled
      DeepBlueDocs::Application.config.jira_integration_enabled
    end

    def self.jira_manager_issue_type
      DeepBlueDocs::Application.config.jira_manager_issue_type
    end

    def self.jira_manager_project_key
      DeepBlueDocs::Application.config.jira_manager_project_key
    end

    def self.jira_test_mode
      DeepBlueDocs::Application.config.jira_test_mode
    end

    def self.summary_last_name( curation_concern: )
      name = Array( curation_concern.creator ).first
      return "" if name.blank?
      match = name.match( /^([^,]+),.*$/ ) # first non-comma substring
      return match[1] if match
      match = name.match( /^.* ([^ ]+)$/ ) # last non-space substring
      return match[1] if match
      return name
    end

    def self.summary_description( curation_concern: )
      description = Array( curation_concern.description ).first
      return "" if description.blank?
      match = description.match( /^([^ ]+) +([^ ]+) [^ ].*$/ ) # three plus words
      return "#{match[1]}#{match[2]}" if match
      match = description.match( /^([^ ]+) +([^ ]+)$/ ) # two words
      return "#{match[1]}#{match[2]}" if match
      match = description.match( /^[^ ]+$/ ) # one word
      return description if match
      return description
    end

    def self.summary_title( curation_concern: )
      title = Array( curation_concern.title ).first
      return "" if title.blank?
      match = title.match( /^([^ ]+) +([^ ]+) [^ ].*$/ ) # three plus words
      return "#{match[1]}#{match[2]}" if match
      match = title.match( /^([^ ]+) +([^ ]+)$/ ) # two words
      return "#{match[1]}#{match[2]}" if match
      match = title.match( /^[^ ]+$/ ) # one word
      return title if match
      return title
    end

    def self.jira_ticket_for_create( curation_concern: )
      ::Deepblue::LoggingHelper.bold_debug [ Deepblue::LoggingHelper.here,
                                             Deepblue::LoggingHelper.called_from,
                                             "curation_concern.id=#{curation_concern.id}",
                                             "" ]

      # Issue type: Data deposit
      #
      # * issue type field name: "issuetype"
      #
      # Status: New
      #
      # * status field name: "customfield_12000"
      #
      # Summary: [Depositor last name] _ [First two words of deposit] _ [deposit ID] - e.g., Nasser_BootAcceleration_n583xv03w
      #
      # * summary field name: "summary"
      #
      # Requester/contact: "Creator", "Contact information" fields in DBD - e.g., Meurer, William wmeurer@med.umich.edu
      #
      # * creator field name: "customfield_11304"
      # * contact information field name: "customfield_11315"
      #
      # Unique Identifier: Deposit ID (from deposit URL) - e.g., n583xv03w
      #
      # * unique identifier field name: "customfield_11303"
      #
      # URL in Deep Blue Data: Deposit URL - e.g., https://deepblue.lib.umich.edu/data/concern/data_sets/4x51hj04n
      #
      # * deposit url field name: "customfield_11305"
      #
      # Description: "Title of deposit" - e.g., Effect of financial incentives on head CT use dataset"
      #
      # * description field name: "description"
      #
      # Discipline: "Discipline" field in DBD - e.g., Health sciences
      #
      # * discipline field name: "customfield_11309"
      #
      summary_title = summary_title( curation_concern: curation_concern )
      summary_last_name = summary_last_name( curation_concern: curation_concern )
      summary = "#{summary_last_name}_#{summary_title}_#{curation_concern.id}"

      contact_info = curation_concern.authoremail
      creator = Array( curation_concern.creator ).first
      deposit_id = curation_concern.id
      deposit_url = ::Deepblue::EmailHelper.data_set_url( data_set: curation_concern )
      discipline = Array( curation_concern.subject_discipline ).first
      description = Array( curation_concern.title ).join("\n") + "\n\nby #{creator}"

      ::Deepblue::LoggingHelper.bold_debug [ Deepblue::LoggingHelper.here,
                                             Deepblue::LoggingHelper.called_from,
                                             Deepblue::LoggingHelper.obj_class( 'class', self ),
                                             "summary=#{summary}",
                                             "description=#{description}",
                                             "" ]
      jira_url = JiraHelper.new_ticket( contact_info: contact_info,
                                        deposit_id: deposit_id,
                                        deposit_url: deposit_url,
                                        description: description,
                                        discipline: discipline,
                                        summary: summary )
      ::Deepblue::LoggingHelper.bold_debug [ Deepblue::LoggingHelper.here,
                                             Deepblue::LoggingHelper.called_from,
                                             "jira_url=#{jira_url}",
                                             "" ]

      return if jira_url.nil?
      return unless curation_concern.respond_to? :curation_notes_admin
      ::Deepblue::LoggingHelper.bold_debug [ Deepblue::LoggingHelper.here,
                                             Deepblue::LoggingHelper.called_from,
                                             "curation_concern.curation_notes_admin=#{curation_concern.curation_notes_admin}",
                                             "" ]
      curation_concern.date_modified = DateTime.now # touch it so it will save updated attributes
      notes = curation_concern.curation_notes_admin
      notes = [] if notes.nil?
      curation_concern.curation_notes_admin = notes << "Jira ticket: #{jira_url}"
      curation_concern.save!
    end

    def self.new_ticket( project_key: jira_manager_project_key,
                         issue_type: jira_manager_issue_type,
                         contact_info:,
                         deposit_id:,
                         deposit_url:,
                         description:,
                         discipline:,
                         summary: )
      ::Deepblue::LoggingHelper.bold_debug [ Deepblue::LoggingHelper.here,
                                             Deepblue::LoggingHelper.called_from,
                                             Deepblue::LoggingHelper.obj_class( 'class', self ),
                                             "summary=#{summary}",
                                             "project_key=#{project_key}",
                                             "issue_type=#{issue_type}",
                                             "description=#{description}",
                                             "jira_enabled=#{jira_enabled}",
                                             "" ]
      return nil unless jira_enabled
      client_options = {
          :username     => Settings.jira.username,
          :password     => Settings.jira.password,
          :site         => Settings.jira.site_url,
          # :site         => 'https://tools.lib.umich.edu',
          :context_path => '/jira',
          :auth_type    => :basic
      }
      save_options = {
          "fields" => {
              "project"     => { "key" => project_key },
              "issuetype"   => { "name" => issue_type },
              FIELD_NAME_CONTACT_INFO => contact_info,
              FIELD_NAME_DEPOSIT_ID => deposit_id,
              FIELD_NAME_DEPOSIT_URL => deposit_url,
              FIELD_NAME_DESCRIPTION => description,
              FIELD_NAME_DISCIPLINE => discipline,
              FIELD_NAME_SUMMARY => summary }
      }
      ::Deepblue::LoggingHelper.bold_debug [ Deepblue::LoggingHelper.here,
                                             Deepblue::LoggingHelper.called_from,
                                             "client_options=#{client_options}",
                                             "save_options=#{save_options}",
                                             "" ]

      return "https://test.jira.url/#{project_key}" if jira_test_mode
      # return nil if jira_test_mode

      client = JIRA::Client.new( client_options )
      # issue = client.Issue.build
      # rv = issue.save( save_options )
      # ::Deepblue::LoggingHelper.bold_debug [ Deepblue::LoggingHelper.here,
      #                                        Deepblue::LoggingHelper.called_from,
      #                                        "issue.save rv=#{rv}",
      #                                        "" ]
      build_options = {
          "fields" => {
              FIELD_NAME_SUMMARY => summary,
              "project"     => { "key" => project_key },
              "issuetype"   => { "name" => issue_type },
              FIELD_NAME_DESCRIPTION => description }
      }
      issue = client.Issue.build
      rv = issue.save( build_options )
      ::Deepblue::LoggingHelper.bold_debug( [ Deepblue::LoggingHelper.here,
                                             Deepblue::LoggingHelper.called_from,
                                             "issue.save( #{build_options} ) rv=#{rv}",
                                             "" ] ) unless rv
      sopts = { "fields" => { FIELD_NAME_CONTACT_INFO => contact_info } }
      rv = issue.save( sopts )
      ::Deepblue::LoggingHelper.bold_debug( [ Deepblue::LoggingHelper.here,
                                             Deepblue::LoggingHelper.called_from,
                                             "issue.save( #{sopts} ) rv=#{rv}",
                                             "" ] ) unless rv
      sopts = { "fields" => { FIELD_NAME_DEPOSIT_ID => deposit_id } }
      rv = issue.save( sopts )
      ::Deepblue::LoggingHelper.bold_debug( [ Deepblue::LoggingHelper.here,
                                              Deepblue::LoggingHelper.called_from,
                                              "issue.save( #{sopts} ) rv=#{rv}",
                                              "" ] ) unless rv
      sopts = { "fields" => { FIELD_NAME_DEPOSIT_URL => deposit_url } }
      rv = issue.save( sopts )
      ::Deepblue::LoggingHelper.bold_debug( [ Deepblue::LoggingHelper.here,
                                              Deepblue::LoggingHelper.called_from,
                                              "issue.save( #{sopts} ) rv=#{rv}",
                                              "" ] ) unless rv
      sopts = { "fields" => { FIELD_NAME_DISCIPLINE => FIELD_VALUES_DISCIPLINE_MAP[discipline] } }
      rv = issue.save( sopts )
      ::Deepblue::LoggingHelper.bold_debug( [ Deepblue::LoggingHelper.here,
                                              Deepblue::LoggingHelper.called_from,
                                              "issue.save( #{sopts} ) rv=#{rv}",
                                              "" ] ) unless rv
      # if rv is false, the save failed.
      url = ticket_url( client: client, issue: issue )
      ::Deepblue::LoggingHelper.bold_debug [ Deepblue::LoggingHelper.here,
                                             Deepblue::LoggingHelper.called_from,
                                             "url=#{url}",
                                             "" ]
      return url
    end

    def self.ticket_url( client:, issue: )
      issue_key = issue.key if issue.respond_to? :key
      "#{client.options[:site]}#{client.options[:context_path]}/browse/#{issue.key}"
    end

  end

end
