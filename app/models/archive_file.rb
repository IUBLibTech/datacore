# wrapper to present a file on the archives server, via interactions with:
# - archive server, via read-only actions to check status
# - job parameters .yml files for DownloadArchivalFilesTask, via read and write actions
# - scratch server, via reading downloaded files
class ArchiveFile

  attr_accessor :collection, :object

  # collection is parent folder for object
  # object may be either filename, or subdirs*/filename
  def initialize(collection:, object:)
    @collection = collection
    @object = object.sub(/\.$/, '') # "match" routing case can add terminal "."
  end

  def to_s
    "collection: #{collection}, object: #{object}, status: #{status}"
  end

  # no memoization, to ensure up-to-date results
  # overrides #virtual_status by directly checking for file
  # @return Symbol [:staging_available, :staging_requested, :staged_after_request, :staged_without_request, :local, :not_found, :no_response, :unexpected]
  def status
    if downloaded?
      :local
    else
      virtual_status
    end
  end

  # abstract helper method
  def description_for_status(method:, lookup_status:, lookup_hash:)
    lookup_hash = lookup_hash.to_hash.with_indifferent_access # convert from Config
    Rails.logger.error("##{method} called with invalid key: #{lookup_status}") unless lookup_status.in?(lookup_hash.keys.map(&:to_sym))
    lookup_hash[lookup_status]
  end

  # used in descriptive fields, above action button
  def display_status(current_status = status)
    description_for_status(method: :display_status, lookup_status: current_status, lookup_hash: Settings.archive_api.status_messages)
  end

  # used for button text
  def request_action(current_status = status)
    description_for_status(method: :request_action, lookup_status: current_status, lookup_hash: Settings.archive_api.request_actions)
  end

  # used for UI display of status codes
  def status_in_ui(current_status = status)
    description_for_status(method: :status_code, lookup_status: current_status, lookup_hash: Settings.archive_api.status_codes_in_ui)
  end

  def request_actionable?(request_status = status)
    request_status.in? [:staging_available, :staged_without_request, :local]
  end

  def request_for_staging?(request_status = status)
    request_status.in? [:staging_available, :staged_without_request]
  end

  # used for :notice and :alert messages in controller flash
  def flash_message(current_status = status)
    description_for(method: :flash_message, lookup_status: current_status, lookup_hash: Settings.archive_api.flash_messages.to_hash.with_indifferent_access)
  end

  # requests staging (if available and not requested yet)
  # returns describing status, action taken (if any), and descriptive message
  # @return Hash
  def get!(request_hash = {})
    current_status = status
    request_hash.merge!({ status: current_status })
    case current_status
    when :local
      create_or_update_job_file!(new_params: { latest_user_download: Time.now })
      { status: current_status, action: nil, file_path: local_path, filename: local_filename, message: display_status(current_status) }
    when :staging_available, :staged_without_request
      stage_request!(request_hash)
    when :staging_requested, :staged_after_request
      # no action -- wait for DownloadArchivalFilesTask to stage and download
      create_or_update_job_file!(new_params: { requests: [request_hash] })
      { status: current_status, action: nil, message: display_status(:staging_requested) }
    when :not_found, :no_response, :unexpected
      create_or_update_job_file!(new_params: { requests: [request_hash] })
      { status: current_status, action: nil, message: display_status(current_status) }
    else
      Rails.logger.warn("Unexpected archive file status: #{current_status}")
      create_or_update_job_file!(new_params: { requests: [request_hash] })
      { status: current_status, action: nil, message: 'Unknown file status' }
    end
  end

  def log_denied_attempt!(request_hash: {}, update_only: true)
    create_or_update_job_file!(new_params: { denials: [request_hash] }, update_only: update_only)
  end

  # bypasses status in job file via checking directly
  def downloaded?
    File.exist?(local_path.to_s)
  end

  def staged?
    archive_status.in? [:staged_without_request, :staged_after_request]
  end
  
  def unstaged?
    archive_status.in? [:staging_available, :staging_requested]
  end

  private
    delegate :jobs_dir, :block_new_jobs?, to: ArchiveFileWorker
    def local_path
      return unless Dir.exists?(jobs_dir)
      @local_path ||= jobs_dir + local_filename
    end

    # collection is only the parent folder
    # object may be a direct filename, or include subfolders if nested, delimited by %2F or /
    def local_filename
      @local_filename ||= Addressable::URI.normalized_encode(object).split('/').last
    end

    # TODO: add version support?
    def archive_url
      @archive_url ||= Settings.archive_api.url % [collection, object]
    end

    def request_url
      @request_url ||= "/sda/request/#{collection}/#{object}"
    end

    # numeric keys are possible responses from archives server
    # text keys are virtual status values from #job_status or #virtual_status
    ARCHIVE_STATUS_CODES =
      { 'local' => :local, # File downloaded
        '000' => :no_response, # No response from file archiver service
        '503' => :unstaged, # File found in archives but not yet staged for download -- converted to :staging_available or :staging_requested
        'staging available' => :staging_available, # :unstaged, with not job indicating user request
        'staging requested' => :staging_requested, # :unstaged, but job indicates staging has been requested
        '200' => :staged, # File is staged for download -- converted to :staged_without_request or :staged_after_request
        'staged without request' => :staged_without_request, # :staged, but job status does not reflect it
        'staged after request' => :staged_after_request, # :staged, with according job status
        '404' => :not_found, # File not found in archives
        'unexpected' => :unexpected, # Unexpected server response
        'deleted' => :deleted # applied by DownloadArchivalFilesTask after deletion -- shouldn't show up elsewhere
      }

    # avoids memoization to always get updated server status
    # @return Symbol [:no_response, :unstaged, :staged, :not_found, :unexpected]
    def archive_status
      code = status_request.try(:code) || '000' # no response from file archiver service
      unless code.in?(ARCHIVE_STATUS_CODES.keys.select { |k| k.to_i > 0 })
        Rails.logger.warn("Unexpected archives server response: #{code}")
        code = 'unexpected'
      end
      ARCHIVE_STATUS_CODES[code]
    end

    # distinguishes archive_status results:
    #   unstaged: [:staging_requested, :staging_available],
    #   staged: [:staged_after_request, :staged_without_request]
    # leaves :local status check to #status
    # avoids memoization to always get updated server status
    # @return Symbol [:staging_requested, :staging_available, :staged_after_request, :staged_without_request, :not_found, :no_response, :unexpected]
    def virtual_status
      remote_status = archive_status
      case remote_status
      when :unstaged
        case job_status
        when :staging_requested, :staging_available, :staged_without_request # job's existence implies forthcoming :staging_requested update
          :staging_requested
        else # job possibly absent
          :staging_available
        end
      when :staged
        case job_status
        when :staging_requested, :staged_after_request, :local, :staged_without_request # job's existence implies forthcoming :staging_requested update
          :staged_after_request
        else # job possibly absent
          :staged_without_request
        end
      else
        remote_status
      end
    end

    VirtualResponse = Struct.new(:code)

    def status_request
      return VirtualResponse.new(code: '000') if Settings.archive_api.disabled
      archive_request
    end
 
    # if not yet staged: requests for staging (if possible)
    # @return Hash
    def stage_request!(request_hash = {})
      Rails.logger.warn("Staging request for #{archive_url} made in status: #{status}") if staged? # log :staged_without_request cases
      if block_new_jobs?
        log_denied_attempt!(request_hash: request_hash.merge({ reason: 'block_new_jobs' }))
        { status: request_hash[:status], action: :throttled, message: display_status(:too_many_requests), alert: true }
      else
        create_or_update_job_file!(new_params: { requests: [request_hash.merge({ action: 'create_or_update_job_file!'})] })
        { status: request_hash[:status], action: :create_or_update_job_file!, message: display_status(:staging_requested) }
      end
    end

    def job_file_path
      @job_file_path ||= "#{local_path}.datacore.yml"
    end

    # @return nil, Symbol [:staging_available, :staging_requested, :staged_after_request, :local]
    def job_status
      archive_file_worker&.job_status
    end

    def job_file?
      File.exist?(job_file_path)
    end

    # avoid memoization for current results
    def archive_file_worker
      @archive_worker ||= begin
        return unless job_file?
        ArchiveFileWorker.new(job_file_path, logger: Rails.logger)
      end
    end

    def default_job_parameters
      { url: archive_url, filename: local_filename, file_path: local_path, collection: collection, object: object, status: status, created_at: Time.now }
    end

    def create_or_update_job_file!(new_params: {}, update_only: false)
      if job_file?
        unless new_params.any? # only update an existing file with new, non-default job parameters
          Rails.logger.warn("Ignoring duplicate call to create default job parameters file for #{archive_url}")
          return
        end
        archive_file_worker.update_job_yaml(new_params)
      elsif !update_only
        new_params = default_job_parameters.merge(new_params).merge(updated_at: Time.now)
        File.write(job_file_path, new_params.to_yaml)
      end
    end

    private
      # main method for all archive interactions 
      # formerly supported Net::HTTP::Get calls, but those are now handled by DownloadArchivalFilesTask
      # now only supports read-only status requests
      # @return Net::HTTPResponse
      def archive_request(method: Net::HTTP::Head)
        uri = URI.parse(archive_url)
        unless method == Net::HTTP::Head
          Rails.logger.error("archive_request called with non-whitelisted method: #{method}")
          return
        end
        request = method.new(uri.request_uri)
        request['Authorization'] = "#{Settings.archive_api.username}:#{Settings.archive_api.password}"
        begin
          result = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') { |http|
            http.request(request)
          }
        rescue => error
          Rails.logger.error("Error connecting to archives #{archive_url}: #{error.message}")
          return
        end
        return result
      end
  
end
