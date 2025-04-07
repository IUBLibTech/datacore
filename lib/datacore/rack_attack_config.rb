module Datacore
  class RackAttackConfig
    class << self
      def config(ttl: Settings.dig(:rack_attack, :config_ttl) || 1.minute)
        return @config if Time.now < (@refresh_time || Time.at(0)) + ttl
        @config = build_config
        @refresh_time = Time.now
        @config
      end

      def config_key
        Settings.dig(:rack_attack, :config_key) || 'rack_attack_config-default'
      end

      def config_source
        ContentBlock.find_or_create_by(name: config_key) do |cb|
          cb.value = default_config.to_yaml
        end
      end

      def default_config
        { 'safe_ips' => [], 'safe_user_agents' => [],
          'block_ips' => [], 'block_user_agents' => [],
          'throttle_ips' => [], 'throttle_user_agents' => [] }
      end

      # @param conf String rack attack config in yaml
      # @see .default_config for format
      def save_config(conf)
        return false unless build_config(conf: conf).is_a? Hash # Validate yaml format
        new_config = config_source
        new_config.value = conf
        new_config.save
      rescue Psych::Exception
        return false
      end

      # @param req Rack::Attack::Request
      # @return Boolean
      def safe_req?(req)
        config[:safe_paths].any? { |path| path.match?(req.path) } ||
          config[:safe_ips].any? { |addr| addr.include?(client_ip(req)) } ||
          config[:safe_user_agents].any? { |ua| ua.match?(req.user_agent) }
      end

      # @param req Rack::Attack::Request
      # @return Boolean
      def block_req?(req)
        config[:block_ips].any? { |addr| addr.include?(client_ip(req)) } ||
          config[:block_user_agents].any? { |ua| ua.match?(req.user_agent) }
      end

      # @param req Rack::Attack::Request
      # @return String throttle key
      # @return false or nil?
      def throttle_req?(req)
        config[:throttle_ips].find { |addr| addr.include?(client_ip(req)) } ||
          config[:throttle_user_agents].find { |ua| ua.match?(req.user_agent) }
      end

      def client_ip(req)
        req.try(:remote_ip) || req.ip
      end

      def build_config(conf: config_source.value)
        new_config = YAML.safe_load(conf)
        {
          safe_paths: new_config.fetch('safe_paths', []).collect { |path| Regexp.new(path) },
          safe_ips: new_config.fetch('safe_ips', []).collect { |addr| IPAddr.new(addr) },
          safe_user_agents: new_config.fetch('safe_user_agents', []).collect { |regexp| Regexp.new(regexp) },
          block_ips: new_config.fetch('block_ips', []).collect { |addr| IPAddr.new(addr) },
          block_user_agents: new_config.fetch('block_user_agents', []).collect { |regexp| Regexp.new(regexp) },
          throttle_ips: new_config.fetch('throttle_ips', []).collect { |addr| IPAddr.new(addr) },
          throttle_user_agents: new_config.fetch('throttle_user_agents', []).collect { |regexp| Regexp.new(regexp) }
        }
      end
    end
  end
end
