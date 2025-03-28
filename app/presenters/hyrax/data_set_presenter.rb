# frozen_string_literal: true

module Hyrax

  class DataSetPresenter < DeepbluePresenter

    delegate  :authoremail,
              :curation_notes_admin,
              :curation_notes_user,
              :date_coverage,
              :date_published, :date_published2, # FIXME; investigate
              :doi, :doi_the_correct_one, # FIXME: investigate
              :doi_minted?,
              :doi_minting_enabled?,
              :doi_pending?,
              :fundedby,
              :fundedby_other,
              :grantnumber,
              :methodology,
              :prior_identifier,
              :referenced_by,
              :rights_license,
              :rights_license_other,
              :subject_discipline,
              :total_file_size,
              :access_deepblue,
              :geo_location_place,
              :geo_location_box,
              :license_other,
              :academic_affiliation,
              :alt_title,
              :bibliographic_citation,
              :contributor_affiliationumcampus,
              :date_attribute,
              :date_issued,
              :description_abstract,
              :description_mapping,
              :description_sponsorship,
              :external_link,
              :identifier_orcid,
              :identifier_source,
              :language_none,
              :linked,
              :other_affiliation,
              :peerreviewed,
              :relation_ispartofseries,
              :type_none,
              to: :solr_document

    # def initialize( solr_document, current_ability, request = nil )
    #   ::Deepblue::LoggingHelper.bold_debug [ Deepblue::LoggingHelper.here,
    #                                          Deepblue::LoggingHelper.called_from,
    #                                          Deepblue::LoggingHelper.obj_class( 'class', self ),
    #                                          "solr_document = #{solr_document}",
    #                                          "solr_document.class.name = #{solr_document.class.name}",
    #                                          "current_ability = #{current_ability}",
    #                                          "request = #{request}",
    #                                          "" ]
    #   super( solr_document, current_ability, request )
    #   ::Deepblue::LoggingHelper.bold_debug [ Deepblue::LoggingHelper.here,
    #                                          Deepblue::LoggingHelper.called_from,
    #                                          Deepblue::LoggingHelper.obj_class( 'class', self ),
    #                                          "@solr_document.class.name = #{@solr_document.class.name}",
    #                                          "@solr_document.doi = #{@solr_document.doi}",
    #                                          "@solr_document.doi_the_correct_one = #{@solr_document.doi_the_correct_one}",
    #                                          "@solr_document.doi_minted? = #{@solr_document.doi_minted?}",
    #                                          "@solr_document.doi_minting_enabled? = #{@solr_document.doi_minting_enabled?}",
    #                                          "@solr_document.doi_pending? = #{@solr_document.doi_pending?}",
    #                                          "" ]
    # end

    # begin box

    def box_enabled?
      DeepBlueDocs::Application.config.box_integration_enabled
    end

    def box_link( only_if_exists_in_box: false )
      return nil unless box_enabled?
      concern_id = @solr_document.id
      return ::BoxHelper.box_link( concern_id, only_if_exists_in_box: only_if_exists_in_box )
    end

    def box_link_display_for_work?( current_user )
      return false unless box_enabled?
      rv = ::BoxHelper.box_link_display_for_work?( work_id: @solr_document.id,
                                                   work_file_count: total_file_count,
                                                   is_admin: current_ability.admin?,
                                                   user_email: Deepblue::EmailHelper.user_email_from( current_user ) )
      return rv
    end

    # end box

    # display date range as from_date To to_date
    def date_coverage
      solr_value = @solr_document.date_coverage
      return nil if solr_value.blank?
      return solr_value.sub( "/open", "" ) if solr_value.match "/open" # rubocop:disable Performance/RedundantMatch, Performance/RegexpMatch
      solr_value.sub( "/", " to " )
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

    # begin doi
    #
    # def doi
    #   solr_value = @solr_document[Solrizer.solr_name('doi', :symbol)]
    #   return nil if solr_value.blank?
    #   solr_value.first
    # end
    #
    # def doi_minted?
    #   !doi.nil?
    # rescue
    #   nil
    # end
    #
    # def doi_pending?
    #   doi == ::Deepblue::DoiBehavior::DOI_PENDING
    # end
    #
    # def mint_doi_enabled?
    #   true
    # end
    #
    # end doi

    # begin globus

    def globus_download_enabled?
      DeepBlueDocs::Application.config.globus_enabled
    end

    def globus_enabled?
      DeepBlueDocs::Application.config.globus_enabled
    end

    def globus_external_url
      concern_id = @solr_document.id
      ::GlobusJob.external_url concern_id
    end

    def globus_files_available?
      concern_id = @solr_document.id
      ::GlobusJob.files_available? concern_id
    end

    def globus_files_prepping?
      concern_id = @solr_document.id
      ::GlobusJob.files_prepping? concern_id
    end

    def globus_last_error_msg
      concern_id = @solr_document.id
      ::GlobusJob.error_file_contents concern_id
    end

    # end globus

    def hdl
      # @object_profile[:hdl]
    end

    def human_readable( value )
      ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert( value, precision: 3 )
    end

    def label_with_total_file_size( label )
      total = total_file_size
      return label if total.zero?
      count = total_file_count
      files = 1 == count ? 'file' : 'files'
      "#{label} (#{total_file_size_human_readable} in #{count} #{files})"
    end

    # begin tombstone

    def tombstone
      return nil if @solr_document.blank?
      solr_value = @solr_document[Solrizer.solr_name('tombstone', :symbol)]
      return nil if solr_value.blank?
      solr_value.first
    end

    def tombstone_enabled?
      true
    end

    # end tombstone

    def total_file_count
      solr_value = @solr_document[Solrizer.solr_name('file_set_ids', :symbol)]
      return 0 if solr_value.blank?
      solr_value.size
    end

    def total_file_size
      solr_value = @solr_document[Solrizer.solr_name('total_file_size', Hyrax::FileSetIndexer::STORED_LONG)]
      return 0 if solr_value.blank?
      solr_value
    end

    def total_file_size_human_readable
      human_readable( total_file_size )
    end

    def zip_download_enabled?
      Settings.zip_download_enabled
    end
  end
end
