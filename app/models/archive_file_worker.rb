class ArchiveFileWorker
  TIMEOUT_BEFORE_DOWNLOAD = Settings.archive_api.timeout_before_download || 24.hours
  TIMEOUT_AFTER_DOWNLOAD = Settings.archive_api.timeout_after_download || 3.hours

  attr_accessor :yaml_path, :logger

  def initialize(yaml_path, logger:)
    @yaml_path = yaml_path
    @logger = logger
  end

  # avoid memoization to ensure current data
  def job_yaml
    YAML.load_file(yaml_path)
  end

  # memoization is okay here -- collection, object values are stable
  def archive_file
    @archive_file ||= ::ArchiveFile.new(collection: job_yaml[:collection], object: job_yaml[:object])
  end

  def self.jobs_dir
    Settings.archive_api.local % ''
  end  

  # @return Array job files sorted by creation date ascending
  def self.job_files
    return [] unless Dir.exists?(jobs_dir)
    Dir.glob(jobs_dir + '*.datacore.yml').sort { |x,y| YAML.load_file(x)[:created_at] <=> YAML.load_file(y)[:created_at] }
  end

  def self.too_many_jobs?
    Settings.archive_api.maximum_concurrent_jobs.map do |max_settings|
      job_files.select { |job_file| YAML.load_file(job_file)[:status].in?(max_settings[:statuses]) }.size >= max_settings[:limit]
    end.any?
  end

  def self.too_much_space_used?
    file_paths = ArchiveFileWorker.job_files.map { |job_file| YAML.load_file(job_file)[:file_path] }
    size_used = file_paths.map { |path| (File.size(path) if File.file?(path)).to_i }.sum
    size_used > Settings.archive_api.maximum_disk_space
  end
  delegate :too_much_space_used?, to: :class

  def self.block_new_jobs?
    too_many_jobs? || too_much_space_used?
  end

  def process_file
    # if the file is not currently open by another process
    pids = `lsof -t '#{yaml_path}'`
    if pids.present?
      logger.error("Skipping file that is in use: #{yaml_path}")
      return
    end
    current_status = archive_file.status
    case current_status
    when :local
      clean_local_file
    when :staging_available
      stage_file
    when :staging_requested
      stage_file # TODO: reconsider?
    when :staged_after_request, :staged_without_request
      download_file
    else
      process_error("unexpected file status: #{current_status}")
    end
  end

  def update_job_yaml(hash)
    updated_yaml = job_yaml.dup
    hash.each do |k,v|
      case v
      when Hash
        updated_yaml[k] ||= {}
        updated_yaml[k] = updated_yaml[k].merge(v)
      when Array
        updated_yaml[k] ||= []
        updated_yaml[k] = updated_yaml[k] + v
      else
        updated_yaml[k] = v
      end
    end
    File.write(yaml_path, updated_yaml.to_yaml)
  end

  def process_error(error)
    logger.error(error)
    update_job_yaml({ errors: { Time.now => error }})
  end

  def stage_file
    logger.info("Staging request for #{yaml_path}")
    update_job_yaml({ staging_requested: [Time.now], status: :staging_requested })

    system(curl_command)

    logger.info("Staging request submitted")
  end

  def download_file
    logger.info("Download initiated for #{yaml_path}")
    update_job_yaml({ status: :staged_after_request })

    if too_much_space_used?
      logger.warn("Disk quota exceeded.  Blocking file download until space is available.")
    else
      update_job_yaml({ download_started: Time.now })
      system(curl_command(output: true))
      FileUtils.mv(download_path, file_path)
      update_job_yaml({ status: :local, download_completed: Time.now })
      logger.info("Download completed at #{file_path}")
    end
  end

  def file_path
    job_yaml[:file_path]
  end

  def download_path
    file_path = '.datacore.yml'
  end

  def curl_command(output: false)
    header = "Authorization: #{Settings.archive_api.username}:#{Settings.archive_api.password}"
    if output
      "curl -H '#{header}' #{job_yaml[:url]} --output #{download_path}"
    else
      "curl -H '#{header}' #{job_yaml[:url]}"
    end
  end

  def clean_local_file
    if delete_file?
      logger.info("Deletion timeout met")
      FileUtils.rm(job_yaml[:file_path])
      logger.info("Deleted #{job_yaml[:file_path]}")
      update_job_yaml({ deleted_at: Time.now, status: :deleted })
      FileUtils.mv(yaml_path, yaml_path + '.deleted')
      logger.info("File deleted")
    else
      logger.info("Local file in place, leaving until deletion timeout conditions met")
    end
  end

  def delete_file?
    return false unless job_yaml[:user_downloaded] || job_yaml[:download_completed]
    return true if job_yaml[:user_downloaded] && ((Time.now - job_yaml[:user_downloaded]).to_i > TIMEOUT_AFTER_DOWNLOAD.to_i)
    return true if job_yaml[:download_completed] && ((Time.now - job_yaml[:download_completed]).to_i > TIMEOUT_BEFORE_DOWNLOAD.to_i)
  end
end