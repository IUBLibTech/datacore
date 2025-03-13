# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  skip_after_action :discard_flash_if_xhr
  include Hydra::Controller::ControllerBehavior

  # Behavior for devise.  Use remote user field in http header for auth.
  include Devise::Behaviors::HttpHeaderAuthenticatableBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  protect_from_forgery with: :exception

  around_action :global_request_logging

  def global_request_logging
    logger.info "ACCESS: #{request.remote_ip}, #{request.method} #{request.url}, #{request.headers['HTTP_USER_AGENT']}"
    begin
      yield
    ensure
      logger.info "response_status: #{response.status}"
    end
  end

  if Rails.configuration.authentication_method == "umich"
    before_action :clear_session_user
  end

  # From PSU's ScholarSphere
  # Clears any user session and authorization information by:
  #   * forcing the session to be restarted on every request
  #   * ensuring the user will be logged out if REMOTE_USER is not set
  #   * clearing the entire session including flash messages
  def clear_session_user
    # ::Deepblue::LoggingHelper.bold_debug [ ::Deepblue::LoggingHelper.here,
    #                                        ::Deepblue::LoggingHelper.called_from,
    #                                        "[AUTHN] clear_session_user: #{current_user.try(:email) || '(no user)'}",
    #                                        "request=#{request}",
    #                                        # "request&.keys=#{request&.keys}",
    #                                        "session=#{session}",
    #                                        "session&.keys=#{session&.keys}",
    #                                        "params=#{params}",
    #                                        "params.keys=#{params.keys}",
    #                                        "" ]
    return nil_request if request.nil?
    # ::Deepblue::LoggingHelper.bold_debug [ ::Deepblue::LoggingHelper.here,
    #                                        ::Deepblue::LoggingHelper.called_from,
    #                                        "[AUTHN] clear_session_user: #{current_user.try(:email) || '(no user)'} request not nil",
    #                                        "params=#{params}",
    #                                        "" ]
    search = session[:search].dup if session[:search]
    flash = session[:flash].dup if session[:flash]
    request.env['warden'].logout unless user_logged_in?
    # ::Deepblue::LoggingHelper.bold_debug [ ::Deepblue::LoggingHelper.here,
    #                                        ::Deepblue::LoggingHelper.called_from,
    #                                        "[AUTHN] clear_session_user: #{current_user.try(:email) || '(no user)'}",
    #                                        "After: request.env['warden'].logout unless user_logged_in?",
    #                                        "request=#{request}",
    #                                        # "request&.keys=#{request&.keys}",
    #                                        "session=#{session}",
    #                                        "session&.keys=#{session&.keys}",
    #                                        "params=#{params}",
    #                                        "params.keys=#{params.keys}",
    #                                        "" ]
    session[:search] = search if search
    session[:flash] = flash if flash
    # ::Deepblue::LoggingHelper.bold_debug [ ::Deepblue::LoggingHelper.here,
    #                                        ::Deepblue::LoggingHelper.called_from,
    #                                        "[AUTHN] clear_session_user: #{current_user.try(:email) || '(no user)'}",
    #                                        "After: session search and flash restored",
    #                                        "request=#{request}",
    #                                        # "request&.keys=#{request&.keys}",
    #                                        "session=#{session}",
    #                                        "session&.keys=#{session&.keys}",
    #                                        "params=#{params}",
    #                                        "params.keys=#{params.keys}",
    #                                        "" ]
  end
  
  def user_logged_in?
    user_signed_in? && ( valid_user?(request.headers) || Rails.env.test?)
  end

  def sso_logout
    ::Deepblue::LoggingHelper.bold_debug [ ::Deepblue::LoggingHelper.here,
                                           ::Deepblue::LoggingHelper.called_from,
                                           "[AUTHN] sso_logout: #{current_user.try(:email) || '(no user)'}",
                                           "" ]
    redirect_to Hyrax::Engine.config.logout_prefix + logout_now_url
  end

  def sso_auto_logout
    Rails.logger.debug "[AUTHN] sso_auto_logout: #{current_user.try(:email) || '(no user)'}"
    # ::Deepblue::LoggingHelper.bold_debug [ ::Deepblue::LoggingHelper.here,
    #                                        ::Deepblue::LoggingHelper.called_from,
    #                                        "[AUTHN] sso_auto_logout: #{current_user.try(:email) || '(no user)'}",
    #                                        "" ]
    sign_out(:user)
    cookies.delete("cosign-" + Hyrax::Engine.config.hostname, path: '/')
    session.destroy
    flash.clear
  end

  Warden::Manager.after_authentication do |user, auth, opts|
    Rails.logger.debug "[AUTHN] Warden after_authentication (clearing flash): #{user}"
    # ::Deepblue::LoggingHelper.bold_debug [ ::Deepblue::LoggingHelper.here,
    #                                        ::Deepblue::LoggingHelper.called_from,
    #                                        "[AUTHN] Warden after_authentication (clearing flash): #{user}",
    #                                        "" ]
    auth.request.flash.clear
  end

  rescue_from ActionController::UnknownFormat, with: :rescue_404

  def rescue_404
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end

  before_action :set_locale

  def set_locale
    if params[:locale].present?
      I18n.locale = constrained_locale || I18n.default_locale
      params[:locale] = I18n.locale.to_s
    end
  end

  def constrained_locale
    return params[:locale] if params[:locale].in?(Object.new.extend(HyraxHelper).available_translations)
  end
end
