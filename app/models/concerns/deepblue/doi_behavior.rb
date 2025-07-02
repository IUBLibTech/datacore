# frozen_string_literal: true

module Deepblue
  module DoiBehavior

    DOI_PENDING = 'doi_pending'
    DOI_MINIMUM_FILE_COUNT = 1

    def doi_minted?
      doi.present? && !doi_pending?
    end

    def doi_minting_enabled?
      ::Datacore::DoiMintingService.enabled?
    end

    def doi_pending?
      doi == DOI_PENDING
    end

    def doi_minimum_files?
      file_sets.count >= DOI_MINIMUM_FILE_COUNT
    end

    def doi_mint(current_user: nil, event_note: '', enforce_minimum_file_count: true, job_delay: 0 )
      if doi_pending?
        Rails.logger.warn "DoiBehavior.doi_mint called for curation_concern.id #{id} with pending doi"
        return false
      elsif doi_minted?
        Rails.logger.warn "DoiBehavior.doi_mint called for curation_concern.id #{id} with minted doi (#{doi})"
        return false
      elsif enforce_minimum_file_count && !doi_minimum_files?
        Rails.logger.warn "DoiBehavior.doi_mint called for curation_concern.id #{id} with insufficient FileSet count (#{file_sets.count})"
        return false
      else
        self.doi = DOI_PENDING
        self.save
        self.reload
        ::DoiMintingJob.perform_later(id, current_user: current_user&.try(:email), job_delay: job_delay)
        return true
      end
    rescue Exception => e # rubocop:disable Lint/RescueException
      Rails.logger.error "DoiBehavior.doi_mint for curation_concern.id #{id} -- #{e.class}: #{e.message} at #{e.backtrace[0]}"
    end
  end
end
