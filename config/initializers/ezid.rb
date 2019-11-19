# frozen_string_literal: true

Ezid::Client.configure do |config|
  config.host     = Settings.ezid.host
  config.port     = Settings.ezid.port
  config.user     = Settings.ezid.user
  config.password = Settings.ezid.password
  config.timeout  = Settings.ezid.timeout
  config.default_shoulder = Settings.ezid.shoulder
end
