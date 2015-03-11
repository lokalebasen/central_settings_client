module LokalebasenSettingsClient
  class CachingClient
    extend Forwardable
    attr_writer :reraise_error

    def_delegators :client, :timeout=, :cache_time=

    def initialize(url)
      @url = url

      # Default values
      @reraise_error = true
    end

    def healthy?
      client.health_check.status == 200
    end

    def by_site_key(site_key)
      cache.cached site_key_cache_key(site_key) do
        client.json_settings_by_site_key(site_key)
      end
    rescue Exception => e
      Airbrake.notify(e) if defined?(Airbrake)
      raise e if @reraise_error
      cache.last_cached_value site_key_cache_key(site_key)
    end

    private

    def site_key_cache_key(site_key)
      "site_key_#{site_key}"
    end

    def cache
      @cache ||= SettingsCache.new
    end

    def client
      Client.new(@url)
    end
  end
end
