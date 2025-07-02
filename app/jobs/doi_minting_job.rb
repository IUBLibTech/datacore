# frozen_string_literal: true

class DoiMintingJob < ::Hyrax::ApplicationJob

  queue_as :doi_minting

  def perform(id, current_user: nil, job_delay: 0)
    sleep(job_delay) if job_delay > 0
    work = ActiveFedora::Base.find(id)
    unless work.doi_pending?
      Rails.logger.error "DoiMintingJob called on work (#{work.id}) in invalid doi state (#{work.doi}), aborting"
      return
    end
    current_user = work.depositor if current_user.blank?
    if Datacore::DoiMintingService.mint_doi_for(work: work, current_user: current_user)
      Rails.logger.debug "DoiMintingJob work id #{id} #{current_user} succeeded."
      # do success callback
      if Hyrax.config.callback.set?(:after_doi_success)
        Hyrax.config.callback.run(:after_doi_success, work, user, log.created_at)
      end
    else
      Rails.logger.debug "DoiMintingJob work id #{id} #{current_user} failed."
      # do failure callback
      if Hyrax.config.callback.set?(:after_doi_failure)
        Hyrax.config.callback.run(:after_doi_failure, work, user, log.created_at)
      end
    end
  rescue Exception => e # rubocop:disable Lint/RescueException
    Rails.logger.error "DoiMintingJob.perform(#{id},#{job_delay}) #{e.class}: #{e.message} at #{e.backtrace[0]}"
    false
  end
end
