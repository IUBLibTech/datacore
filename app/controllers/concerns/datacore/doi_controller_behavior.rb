# frozen_string_literal: true

module Datacore
  module DoiControllerBehavior

    def doi_minting_enabled?
      ::Datacore::DoiMintingService.enabled?
    end 

    def doi
      doi_mint!
        
      respond_to do |wants|
        wants.html { redirect_to [main_app, curation_concern] }
        wants.json do
          render :show,
                 status: :ok,
                 location: polymorphic_path([main_app, curation_concern])
        end
      end
    end 

    private
      
      def doi_mint!
        if !doi_minting_enabled?
          flash[:alert] = MsgHelper.t('data_set.doi_minting_disabled')
        elsif curation_concern.doi_pending?
          flash[:notice] = MsgHelper.t('data_set.doi_is_being_minted')
        elsif curation_concern.doi_minted?
          flash[:alert] = MsgHelper.t('data_set.doi_already_exists')
        elsif !curation_concern.doi_minimum_files?
          flash[:alert] = MsgHelper.t('data_set.doi_requires_work_with_files')
        elsif !curation_concern.valid?
          flash[:alert] = MsgHelper.t('data_set.doi_requires_valid_work')
        elsif (curation_concern.depositor != current_user.email) && !current_ability.admin?
          flash[:alert] = MsgHelper.t('data_set.doi_user_without_access')
        elsif curation_concern.doi_mint(current_user: current_user, event_note: 'DataSetsController')
          flash[:notice] = MsgHelper.t('data_set.doi_minting_started')
        else                         
          flash[:error] = MsgHelper.t('data_set.doi_minting_error')
        end
      end
  end
end
