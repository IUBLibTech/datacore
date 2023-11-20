# frozen_string_literal: true

class ArchiveController < ApplicationController
  protect_from_forgery with: :null_session

  def show
    if user_signed_in? && current_ability.admin?
      render plain: archive_url_for(params[:collection], "#{params[:object]}.#{params[:format]}"), status: 200
    else
      render plain: 'action unavailable', status: 403
    end
  end

  def request_file
    handle_file_request(string: archive_url_for(params[:collection], params[:object]),
                        filename: params[:object])
  end

  def request_factory(method)
    case method
    when :get
      Net::HTTP::Get
    when
      Net::HTTP::Head
    else
      nil
    end
  end

  def archive_request(string: "http://localhost:8181/datacore/nv9352841_home_banner.jpg", filename: "home_banner.jpg", method: :head)
    uri = URI.parse(string)
    request = request_factory(method).new(uri.request_uri)
    request['Authorization'] = "#{Settings.archive_api.username}:#{Settings.archive_api.password}"
    # TODO: add begin wrapper
    result = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') { |http|
      http.request(request)
    }
    return result
  end

  def status_request(string: "http://localhost:8181/datacore/nv9352841_home_banner.jpg", filename: "home_banner.jpg")
    archive_request(string: string, filename: filename, method: :head)
  end

  def file_request(string: "http://localhost:8181/datacore/nv9352841_home_banner.jpg", filename: "home_banner.jpg")
    archive_request(string: string, filename: filename, method: :get)
  end

  def handle_file_request(string: "http://localhost:8181/datacore/nv9352841_home_banner.jpg", filename: "home_banner.jpg", code: nil)
    result = file_request(string: string, filename: filename)
    code = result.try(:code) || 'No response from file archiver service'
    case code
      when '200'
        send_data result.body, filename: filename
      else
        failed_file_request(filename: filename, code: code)
    end
  end

  def failed_file_request(filename:, code:)
    file_set = FileSet.where(title: filename).first
    destination = file_set ? [main_app, file_set] : main_app.root_url
    case code
      when '503'
        redirect_to destination, notice: 'File found in archives and requested for download'
      when '404'
        debugger
        redirect_to destination, alert: 'File not found in archives'
      else
        redirect_to destination, alert: "Unexpected response from archives: #{code}"
    end
  end

  private
    # TODO: add version support?
    def archive_url_for(collection, object)
      Settings.archive_api.url % [collection, object]
    end
end
