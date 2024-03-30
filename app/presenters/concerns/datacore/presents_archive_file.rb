# frozen_string_literal: true

module Datacore
  module PresentsArchiveFile

    # archive files bypass fedora storage
    def archive_file?
      mime_type.match(/^message\/external-body\;.*access-type=URL/).present?
    end

    def archive_request_url
      return '/' unless archive_file?
      mime_type.split('"').last
    end

    def archive_status_url
      archive_request_url.sub('/request/', '/status/')
    end

    def archive_file
      @archive_file ||=
        if archive_file?
          # nested objects should be stored in format
          # /sda/request/collection/subdir%2Ffilename
          # but normalize if unencoded / slipped in
          collection_and_object = mime_type.split('"').last.sub('/sda/request/', '').split('/')
          collection = collection_and_object.first
          object = collection_and_object[1, collection_and_object.size].join('%2F')
          ArchiveFile.new(collection: collection, object: object)
        end
    end
    delegate :status, :request_action, :request_actionable?, to: :archive_file, allow_nil: true
    alias_method :archive_status, :status
  end
end
