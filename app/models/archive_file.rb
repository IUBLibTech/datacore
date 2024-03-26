class ArchiveFile

  attr_accessor :collection, :object

  def initialize(collection:, object:)
    @collection = collection
    @object = object
  end

  def status
    if downloaded?
      :local
    else
      archive_status
    end
  end

  def display_status
    messages = { unstaged: 'File found in archives but not yet staged for download',
                 staged: 'File found in archives but not yet staged for download', # don't consider "staged" until copied from SDA cache to scratch
                 local: 'File is available for download',
                 not_found: 'File not found in archives',
                 no_response: 'File archives server is not responding',
                 unexpected: 'Unexpected response from file archives server' }
    messages[status]
  end

  # @return Hash
  def get!
    current_status = status
    case current_status
    when :local
      { status: current_status, action: nil, file_path: local_path, filename: local_filename, message: 'File is available for download' }
    when :unstaged
      result = stage_request!
      { status: current_status, action: 'stage_request!', message: 'File found in archives and requested for download.  The time required for archive requests is variable -- allow at least 15 minutes before attempting to download again.' }
    when :staged
      result = download_request!
      { status: current_status, action: 'download_request!', message: 'File found in archives and requested for download.  The time required for archive requests is variable -- allow at least 15 minutes before attempting to download again.' }
    when :not_found
      { status: current_status, action: nil, message: 'File not found in archives' }
    when :no_response
      { status: current_status, action: nil, message: 'No response from archives' }
    else
      { status: current_status, action: nil }
    end
  end

  def downloaded?
    File.exist?(local_path)
  end

  def downloaded!
    create_or_update_job_file!({ user_downloaded: Time.now.to_s })
  end

  def remote?
    archive_status.in? [:staged, :unstaged]
  end

  def staged?
    archive_status == :staged
  end
  
  def unstaged?
    archive_status == :unstaged
  end

  private
    def local_path
      return unless Dir.exists?(Settings.archive_api.local % '')
      @local_path ||= Settings.archive_api.local % local_filename
    end

    def local_filename
      @local_filename ||= object.split('/').last
    end

    # TODO: add version support?
    def archive_url
      @archive_url ||= Settings.archive_api.url % [collection, object]
    end

    ARCHIVE_STATUS_CODES =
      { 'local' => :local, # File downloaded
        '000' => :no_response, # No response from file archiver service
        '503' => :unstaged, # File found in archives but not yet staged for download
        '200' => :staged, # File is staged for download
        '404' => :not_found, # File not found in archives
        'unexpected' => :unexpected # Unexpected server response
      }

    # avoid memoization to always get updated status
    # @return Symbol
    def archive_status
      code = status_request.try(:code) || '000' # no response from file archiver service
      unless code.in?(ARCHIVE_STATUS_CODES.keys.select { |k| k.to_i > 0 })
        Rails.logger.warn("Unexpected archives server response: #{code}")
        code = 'unexpected'
      end
      ARCHIVE_STATUS_CODES[code]
    end

    # @return Class
    def request_factory(method)
      case method
      when :get
        # disabled; get calls moved to DownloadArchivalFilesTask
        # Net::HTTP::Get
        nil
      when :head
        Net::HTTP::Head
      else
        nil
      end
    end 
 
    # main method for all archive interactions 
    def archive_request(method: :head)
      uri = URI.parse(archive_url)
      request = request_factory(method).new(uri.request_uri)
      request['Authorization'] = "#{Settings.archive_api.username}:#{Settings.archive_api.password}"
      # TODO: add begin wrapper
      result = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') { |http|
        http.request(request)
      }
      return result
    end
 
    # read-only status request 
    # @return Net::HTTPResponse
    def status_request
      archive_request(method: :head)
    end
 
    # if not yet staged: requests for staging (if possible)
    # @return Net::HTTPResponse
    def stage_request!
      if unstaged?
        create_or_update_job_file!
      else
        Rails.logger.warn("Ignored staging request for #{archive_url} in status #{status}")
      end
    end

    def job_file_path
      @job_file_path ||= "#{local_path}.datacore.yml"
    end

    def create_or_update_job_file!(job_params = nil)
      if job_params
        yaml = YAML.load_file(job_file_path)
        yaml.merge!(job_params)
        File.write(job_file_path, yaml.to_yaml)
      else
        default_params = { url: archive_url, filename: local_filename, file_path: local_path, collection: collection, object: object, created_at: Time.now }
        File.write(job_file_path, default_params.to_yaml) unless File.exist?(job_file_path)
      end
    end

    # if staged: downloads
    def download_request!
      if downloaded?
        Rails.logger.warn("Ignored downloading request for #{archive_url} already at local path #{local_path}")
      elsif staged?
        create_or_update_job_file! # should be redundant
      else
        Rails.logger.warn("Ignored downloading request for #{archive_url} in status #{status}")
      end
    end
end
