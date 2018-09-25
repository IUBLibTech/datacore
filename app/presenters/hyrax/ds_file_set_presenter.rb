# frozen_string_literal: true

module Hyrax

  class DsFileSetPresenter < Hyrax::FileSetPresenter

    delegate :title, :file_size,
             :file_size_human_readable,
             :original_checksum,
             :mime_type,
             :virus_scan_service,
             :virus_scan_status,
             :virus_scan_status_date, to: :solr_document

    def doi_minted?
      # the first time this is called, doi will not be in solr.
      @solr_document[ Solrizer.solr_name( 'doi', :symbol ) ].first
    rescue
      nil
    end

    def doi_pending?
      @solr_document[ Solrizer.solr_name( 'doi', :symbol ) ].first == DataSet::DOI_PENDING
    end

    def parent_doi?
      g = DataSet.find parent.id
      g.doi.present?
    end

    def parent_public?
      g = DataSet.find parent.id
      g.public?
    end

    def first_title
      title.first
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
