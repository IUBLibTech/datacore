# frozen_string_literal: true

if Settings.dig(:rack_profiler, :enabled)
  require 'stackprof'
  require 'rack-mini-profiler'

  # initialization is skipped so trigger it
  Rack::MiniProfilerRails.initialize!(Rails.application)
end
