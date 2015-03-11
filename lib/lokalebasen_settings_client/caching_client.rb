module LokalebasenSettingsClient
  class CachingClient
    extend Forwardable

    def_delegators :client, :timeout=, :cache_time=
    def_delegators :robust_cache, :reraise_error=

    def initialize(url)
      @url = url
    end

    def healthy?
      client.health_check.status == 200
    end

    def by_site_key(site_key)
      robust_cache.cached "site_key_#{site_key}" do
        client.json_settings_by_site_key(site_key)
      end
    end

    private

    def robust_cache
      @cache ||= RobustSettingsCache.new(SettingsCache.new)
    end

    def client
      Client.new(@url)
    end
  end
end
