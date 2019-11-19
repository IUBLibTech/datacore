# Initializer for the Config gem.
Config.setup do |config|
  # Name of the constant exposing loaded settings
  config.const_name = 'Settings'
  # Use ENV settings
  config.use_env = true
  config.env_prefix = 'DATACORE'
  config.env_separator = '__'
  config.env_converter = :downcase
  config.env_parse_values = true
end
