# frozen_string_literal: true

module Hyrax

  class DsFileSetPresenter < Hyrax::FileSetPresenter

    delegate :doi, :doi_the_correct_one,
             :doi_minted?,
             :doi_minting_enabled?,
             :doi_pending?,
             :file_size,
             :file_size_human_readable,
             :original_checksum,
             :mime_type,
             :title,
             :virus_scan_service,
             :virus_scan_status,
             :virus_scan_status_date, to: :solr_document

    # def doi_minted?
    #   # the first time this is called, doi will not be in solr.
    #   @solr_document[ Solrizer.solr_name( 'doi', :symbol ) ].first
    # rescue
    #   nil
    # end
    #
    # def doi_pending?
    #   @solr_document[ Solrizer.solr_name( 'doi', :symbol ) ].first == ::Deepblue::DoiBehavior::DOI_PENDING
    # end

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
          collection, object = mime_type.split('"').last.sub('/sda/request/', '').split('/')
          ArchiveFile.new(collection: collection, object: object)
        end
    end

    def archive_status
      @archive_status ||= archive_file.status
    end

    def request_action
      @request_action ||= archive_file.request_action
    end

    def request_actionable?
      @request_actionable ||= archive_file.request_actionable?(archive_status)
    end

    def relative_url_root
      rv = ::DeepBlueDocs::Application.config.relative_url_root
      return rv if rv
      ''
    end

    def parent_doi_minted?
      g = DataSet.find parent.id
      g.doi_minted?
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
