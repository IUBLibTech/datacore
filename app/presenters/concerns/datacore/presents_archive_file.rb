# frozen_string_literal: true

# included in both FileSet and DsFileSetPresenter
module Datacore
  module PresentsArchiveFile

    # archive files bypass fedora storage
    def archive_file?
      mime_type.to_s.match(/^message\/external-body\;.*access-type=URL/).present?
    end

    # file that should have bypassed fedora storage, but didn't
    def large_file?
      file_size_value > Settings.ingest.size_limit.fedora
    end

    def exclude_from_zip?
      archive_file? || large_file?
    end

    # common interface across presenter, model
    def file_size_value
      case file_size
      when Integer # DsFileSetPresenter, solr storage
        file_size
      when Array, ActiveTriples::Relation # FileSet storage
        file_size.first.to_i
      else # nil values, etc.
        0
      end
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
