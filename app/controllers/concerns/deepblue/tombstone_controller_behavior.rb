# frozen_string_literal: true

module Deepblue
  module TombstoneControllerBehavior
    extend ActiveSupport::Concern

    included do
      before_action :prepare_permissions,          only: [:show]
      after_action :reset_permissions,             only: [:show]
    end

    # These methods (prepare_permissions, and reset_permissions) are used so that
    # when viewing a tombstoned work, and the user is not admin, the user 
    # will be able to see the metadata.
    def prepare_permissions
      if current_ability.admin?
      else
        # Need to add admin group to current_ability
        # or presenter will not be accessible.
        current_ability.user_groups << "admin"
        if presenter&.tombstone.present?
        else
          current_ability.user_groups.delete("admin")
        end
      end
    end

    def reset_permissions
      current_ability.user_groups.delete("admin")
    end

    def tombstone
      epitaph = params[:tombstone]
      success = curation_concern.entomb!( epitaph, current_user )
      msg = if success
              MsgHelper.t( 'data_set.tombstone_notice', title: curation_concern.title.first.to_s, reason: epitaph.to_s )
            else
              "#{curation_concern.title.first} is already tombstoned."
            end
      redirect_to dashboard_works_path, notice: msg
    end

    # FIXME: never called
    def tombstone_enabled?
      true
    end
  end
end
