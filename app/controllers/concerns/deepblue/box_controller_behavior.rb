# frozen_string_literal: true

module Deepblue
  module BoxControllerBehavior

    def box_create_dir_and_add_collaborator
      return nil unless DeepBlueDocs::Application.config.box_integration_enabled
      user_email = Deepblue::EmailHelper.user_email_from( current_user )
      BoxHelper.create_dir_and_add_collaborator( curation_concern.id, user_email: user_email )
    end

    def box_link
      return nil unless DeepBlueDocs::Application.config.box_integration_enabled
      BoxHelper.box_link( curation_concern.id )
    end

    def box_work_created
      box_create_dir_and_add_collaborator
    end
  end
end
