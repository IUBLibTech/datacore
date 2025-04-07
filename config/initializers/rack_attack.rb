Rack::Attack.enabled = Settings.dig(:rack_attack, :enabled) || false

Rack::Attack.throttled_response_retry_after_header = true

Rack::Attack.safelist('Safe') do |req|
  Datacore::RackAttackConfig.safe_req?(req)
end

Rack::Attack.blocklist('Blocked') do |req|
  Datacore::RackAttackConfig.block_req?(req)
end

Rack::Attack.throttle('Throttled',
                      limit: Settings.dig(:rack_attack, :throttle_limit) || 100,
                      period: Settings.dig(:rack_attack, :throttle_period) || 2.minutes) do |req|
  Datacore::RackAttackConfig.throttle_req?(req)
end
