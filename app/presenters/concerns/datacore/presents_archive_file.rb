# frozen_string_literal: true

module Datacore
  module PresentsArchiveFile

    # archive files bypass fedora storage
    def archive_file?
      mime_type.to_s.match(/^message\/external-body\;.*access-type=URL/).present?
    end

    # needs to pass through archive_file in case any / to %2F encoding happened there
    def archive_request_url
      @archive_request_url ||= begin
                                 return '/' unless archive_file?
                                 archive_file.send(:request_url)
                               end
    end

    def archive_status_url
      archive_request_url.sub('/request/', '/status/')
    end

    def archive_file
      @archive_file ||=
        if archive_file?
          # nested objects may be stored in format:
          # /sda/request/<collection>/<subdir>%2F<object>
          # which works rails routing, but we need to force-encode the final '/' if stored as:
          # /sda/request/<collection>/<subdir>/<object>
          collection_and_object = mime_type.split('"').last.sub('/sda/request/', '').split('/')
          collection = collection_and_object.first
          object = collection_and_object[1, collection_and_object.size].join('%2F')
          ArchiveFile.new(collection: collection, object: object)
        end
    end
    delegate :display_status, :request_action, :request_actionable?, :request_for_staging?, :status_in_ui, to: :archive_file, allow_nil: true
    alias_method :archive_status_description, :display_status
    alias_method :archive_status_code, :status_in_ui

    def provide_request_email?
      Settings.archive_api.provide_email.present?
    end

    def require_request_email?
      Settings.archive_api.provide_email == :required
    end
  end
end
