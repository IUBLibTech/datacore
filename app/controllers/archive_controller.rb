# frozen_string_literal: true

class ArchiveController < ApplicationController
  protect_from_forgery with: :null_session

  def user_is_authorized?
    set_variables
    true # satisfy open access requirement
  end

  def status
    if user_is_authorized?
      render plain: @archive_file.display_status
    else
      render plain: 'action unavailable', status: 403
    end
  end

  def download_request
    if user_is_authorized?
      result = @archive_file.get!
      if result[:file_path].present?
        send_file(result[:file_path], filename: result[:filename])
        @archive_file.downloaded!
      else
        unless result[:message]
          Rails.logger.error("Message missing from #{@archive_file} result: #{result}")
          result[:message] = 'Request failed.  Please request technical support.'
        end
        if result[:alert]
          redirect_back fallback_location: root_url, alert: result[:message]
        else
          redirect_back fallback_location: root_url, notice: result[:message]
        end
      end
    else
      redirect_back fallback_location: root_url, alert: 'Action unavailable'
    end
  end

  private
    def variable_params
      params.permit(:collection, :object, :format)
    end

    def set_variables
      @collection = params[:collection]
      @object = "#{variable_params[:object]}.#{variable_params[:format]}"
      @archive_file = ArchiveFile.new(collection: @collection, object: @object)
    end
end
