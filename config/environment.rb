# Load the Rails application.
require_relative 'application'

# load commit version for footer
ENV['SOURCE_COMMIT'] = `git rev-parse --short HEAD` unless ENV['SOURCE_COMMIT'].present?

# Initialize the Rails application.
Rails.application.initialize!
