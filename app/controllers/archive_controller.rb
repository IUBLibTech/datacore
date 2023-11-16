# frozen_string_literal: true

class ArchiveController < ApplicationController
  protect_from_forgery with: :null_session

  def user_is_authorized?
    set_variables
    user_signed_in? && current_ability.admin?
  end

  def show
    if user_is_authorized?
      render plain: @archive_url, status: 200
    else
      render plain: 'action unavailable', status: 403
    end
  end

  def status
    if user_is_authorized?
      result = status_request(string: @archive_url, filename: @filename)
      code = result.try(:code) || 'No response from file archiver service'
      case code
      when '503'
        render plain: 'File found in archives but not yet staged for download'
      when '200'
        render plain: 'File is staged for download'
      when '404'
        render plain: 'File not found in archives'
      else
        render plain: "Unexpected response from archives: #{code}"
      end
    else
      render plain: 'action unavailable', status: 403
    end
  end

  def download_request
    if user_is_authorized?
      handle_file_request(string: @archive_url, filename: @filename)
    else
      render plain: 'action unavailable', status: 403
    end
  end

  def request_factory(method)
    case method
    when :get
      Net::HTTP::Get
    when :head
      Net::HTTP::Head
    else
      nil
    end
  end

  def archive_request(string:, filename:, method: :head)
    uri = URI.parse(string)
    request = request_factory(method).new(uri.request_uri)
    request['Authorization'] = "#{Settings.archive_api.username}:#{Settings.archive_api.password}"
    # TODO: add begin wrapper
    result = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') { |http|
      http.request(request)
    }
    return result
  end

  def status_request(string:, filename:)
    archive_request(string: string, filename: filename, method: :head)
  end

  def file_request(string:, filename:)
    archive_request(string: string, filename: filename, method: :get)
  end

  def handle_file_request(string:, filename:, code: nil)
    result = file_request(string: string, filename: filename)
    code = result.try(:code) || 'No response from file archiver service'
    case code
      when '503'
        redirect_to root_url, notice: 'File found in archives and requested for download.  The time required for archive requests is variable -- allow at least 15 minutes before attempting to download again.'
      when '200'
        # FIXME: this will not scale well to large body sizes
        send_data result.body, filename: filename
      when '404'
        redirect_to root_url, alert: 'File not found in archives'
      else
        redirect_to root_url, alert: "Unexpected response from archives: #{code}"
    end
  end

  private
    # TODO: add version support?
    def archive_url_for(collection, object)
      Settings.archive_api.url % [collection, object]
    end

    def variable_params
      params.permit(:collection, :object, :format)
    end

    def set_variables
      @filename = "#{variable_params[:object]}.#{variable_params[:format]}"
      @archive_url = archive_url_for(params[:collection], @filename)
    end
end
