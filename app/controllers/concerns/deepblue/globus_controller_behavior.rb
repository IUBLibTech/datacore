# frozen_string_literal: true

module Deepblue
  module GlobusControllerBehavior
    extend ActiveSupport::Concern

    included do
      protect_from_forgery with: :null_session,    only: [:globus_add_email,
                                                          :globus_download,
                                                          :globus_download_add_email,
                                                          :globus_download_notify_me]
      attr_accessor :user_email_one, :user_email_two
    end

    def globus_add_email
      if user_signed_in?
        user_email = Deepblue::EmailHelper.user_email_from( current_user )
        globus_copy_job( user_email: user_email, delay_per_file_seconds: 0 )
        flash_and_go_back globus_files_prepping_msg( user_email: user_email )
      elsif params[:user_email_one].present? || params[:user_email_two].present?
        user_email_one = params[:user_email_one].present? ? params[:user_email_one].strip : ''
        user_email_two = params[:user_email_two].present? ? params[:user_email_two].strip : ''
        # if user_email_one === user_email_two
        if user_email_one == user_email_two
          globus_copy_job( user_email: user_email_one, delay_per_file_seconds: 0 )
          flash_and_redirect_to_main_cc globus_files_prepping_msg( user_email: user_email_one )
        else
          flash.now[:error] = emails_did_not_match_msg( user_email_one, user_email_two )
          render 'globus_download_add_email_form'
        end
      else
        flash_and_redirect_to_main_cc globus_status_msg
      end
    end

    def globus_clean_download
      ::GlobusCleanJob.perform_later( curation_concern.id, clean_download: true )
      globus_ui_delay
      dirs = []
      dirs << ::GlobusJob.target_download_dir( curation_concern.id )
      dirs << ::GlobusJob.target_prep_dir( curation_concern.id, prefix: nil )
      dirs << ::GlobusJob.target_prep_tmp_dir( curation_concern.id, prefix: nil )
      flash_and_redirect_to_main_cc globus_clean_msg( dirs )
    end

    def globus_clean_prep
      ::GlobusCleanJob.perform_later( curation_concern.id, clean_download: false )
      globus_ui_delay
    end

    def globus_complete?
      ::GlobusJob.copy_complete? curation_concern.id
    end

    def globus_copy_job( user_email: nil,
                         delay_per_file_seconds: DeepBlueDocs::Application.config.globus_debug_delay_per_file_copy_job_seconds )

      ::GlobusCopyJob.perform_later( curation_concern.id,
                                     user_email: user_email,
                                     delay_per_file_seconds: delay_per_file_seconds )
      globus_ui_delay
    end

    def globus_download
      if globus_complete?
        flash_and_redirect_to_main_cc globus_files_available_here
      else
        user_email = Deepblue::EmailHelper.user_email_from( current_user, user_signed_in: user_signed_in? )
        msg = if globus_prepping?
                globus_files_prepping_msg( user_email: user_email )
              else
                globus_file_prep_started_msg( user_email: user_email )
              end
        if user_signed_in?
          globus_copy_job( user_email: user_email )
          flash_and_redirect_to_main_cc msg
        else
          render 'globus_download_notify_me_form'
        end
      end
    end

    def globus_download_add_email
      if user_signed_in?
        globus_add_email
      else
        render 'globus_download_add_email_form'
      end
    end

    def globus_download_enabled?
      DeepBlueDocs::Application.config.globus_enabled
    end

    def globus_download_notify_me
      if user_signed_in?
        user_email = Deepblue::EmailHelper.user_email_from( current_user )
        globus_copy_job( user_email: user_email )
        flash_and_go_back globus_file_prep_started_msg( user_email: user_email )
      elsif params[:user_email_one].present? || params[:user_email_two].present?
        user_email_one = params[:user_email_one].present? ? params[:user_email_one].strip : ''
        user_email_two = params[:user_email_two].present? ? params[:user_email_two].strip : ''
        # if user_email_one === user_email_two
        if user_email_one == user_email_two
          globus_copy_job( user_email: user_email_one )
          flash_and_redirect_to_main_cc globus_file_prep_started_msg( user_email: user_email_one )
        else
          # flash_and_go_back emails_did_not_match_msg( user_email_one, user_email_two )
          flash.now[:error] = emails_did_not_match_msg( user_email_one, user_email_two )
          render 'globus_download_notify_me_form'
        end
      else
        globus_copy_job( user_email: nil )
        flash_and_redirect_to_main_cc globus_file_prep_started_msg
      end
    end

    def globus_enabled?
      DeepBlueDocs::Application.config.globus_enabled
    end

    def globus_last_error_msg
      ::GlobusJob.error_file_contents curation_concern.id
    end

    def globus_prepping?
      ::GlobusJob.files_prepping? curation_concern.id
    end

    def globus_ui_delay( delay_seconds: DeepBlueDocs::Application.config.globus_after_copy_job_ui_delay_seconds )
      sleep delay_seconds if delay_seconds.positive?
    end

    def globus_url
      ::GlobusJob.external_url curation_concern.id
    end

    protected

      def emails_did_not_match_msg( _user_email_one, _user_email_two )
        "Emails did not match" # + ": '#{user_email_one}' != '#{user_email_two}'"
      end

      def flash_and_go_back( msg )
        Deepblue::LoggingHelper.debug msg        
        redirect_back fallback_location: root_url, notice: msg
      end
   
      # FIXME: never called
      def flash_error_and_go_back( msg )         
        Deepblue::LoggingHelper.debug msg        
        redirect_back fallback_location: root_url, alert: msg
      end
    
      def flash_and_redirect_to_main_cc( msg )   
        Deepblue::LoggingHelper.debug msg        
        redirect_to [main_app, curation_concern], notice: msg
      end


    private
      def globus_clean_msg( dir )
        dirs = dir.join( MsgHelper.t( 'data_set.globus_clean_join_html' ) )
        rv = MsgHelper.t( 'data_set.globus_clean', dirs: dirs )
        return rv
      end

      def globus_file_prep_started_msg( user_email: nil )
        MsgHelper.t( 'data_set.globus_file_prep_started',
                     when_available: globus_files_when_available( user_email: user_email ) )
      end

      def globus_files_prepping_msg( user_email: nil )
        MsgHelper.t( 'data_set.globus_files_prepping',
                     when_available: globus_files_when_available( user_email: user_email ) )
      end

      def globus_files_when_available( user_email: nil )
        if user_email.nil?
          MsgHelper.t( 'data_set.globus_files_when_available' )
        else
          MsgHelper.t( 'data_set.globus_files_when_available_email', user_email: user_email )
        end
      end

      def globus_files_available_here
        MsgHelper.t( 'data_set.globus_files_available_here', globus_url: globus_url.to_s )
      end

      def globus_status_msg( user_email: nil )
        msg = if globus_complete?
                globus_files_available_here
              elsif globus_prepping?
                globus_files_prepping_msg( user_email: user_email )
              else
                globus_file_prep_started_msg( user_email: user_email )
              end
        msg
      end
  end
end
