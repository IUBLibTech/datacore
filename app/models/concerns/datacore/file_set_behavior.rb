# frozen_string_literal: true

module Datacore
  module FileSetBehavior
    def archive_only?
      self.original_file.mime_type.match(/^message\/external-body;access-type=URL/).present?
    end

    def in_fedora?
      !archive_only?
    end

    def in_archives?
      true
      # TODO: make api call to check
    end

    def archive_filename
      Array.wrap(self.original_file.file_name).first
    end

    def archive_status_url
      "/sda/status/datacore/#{archive_filename}"
    end

    def archive_request_url
      "/sda/request/datacore/#{archive_filename}"
    end
  end
end
