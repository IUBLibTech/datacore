# Load the Rails application.
require_relative 'application'

# load commit version for footer
ENV['SOURCE_COMMIT'] = `git rev-parse --short HEAD`.squish unless ENV['SOURCE_COMMIT'].present?
ENV['SOURCE_VERSION'] = `git describe --tags --abbrev=0`.squish unless ENV['SOURCE_VERSION'].present?

# Initialize the Rails application.
Rails.application.initialize!
