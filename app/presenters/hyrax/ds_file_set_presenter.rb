# frozen_string_literal: true

module Hyrax
  class DsFileSetPresenter < Hyrax::FileSetPresenter
    include ::Datacore::PresentsArchiveFile

    delegate :file_size,
             :file_size_human_readable,
             :original_checksum,
             :mime_type,
             :title,
             :virus_scan_service,
             :virus_scan_status,
             :virus_scan_status_date, to: :solr_document

    def relative_url_root
      rv = ::DeepBlueDocs::Application.config.relative_url_root
      return rv if rv
      ''
    end

    # begin display_provenance_log

    def display_provenance_log_enabled?
      true
    end

    def provenance_log_entries?
      file_path = Deepblue::ProvenancePath.path_for_reference( id )
      File.exist? file_path
    end

    # end display_provenance_log

    def parent_public?
      g = DataSet.find parent.id
      g.public?
    end

    def first_title
      title.first || 'File'
    end

    # To handle large files.
    def link_name
      if ( current_ability.admin? || current_ability.can?(:read, id) )
        first_title
      else
        'File'
      end
    end

    def file_name( parent_presenter, link_to )
      if parent_presenter.tombstone.present?
        rv = link_name
      elsif file_size_too_large_to_download?
        rv = link_name
      else
        rv = link_to
      end
      return rv
    end

    def file_size_too_large_to_download?
      !@solr_document.file_size.nil? && @solr_document.file_size >= DeepBlueDocs::Application.config.max_work_file_size_to_download
    end
  end
end
