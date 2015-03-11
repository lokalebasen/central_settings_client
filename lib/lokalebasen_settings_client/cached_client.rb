module LokalebasenSettingsClient
  class CachingClient
    extend Forwardable
    attr_writer :reraise_error

    def_delegators :client, :timeout=, :cache_time=

    def initialize(url, site_key)
      @url = url
      @site_key = site_key

      # Default values
      @reraise_error = true
    end

    def healthy?
      client.health_check.status == 200
    end

    def get
      cache.cached { settings_by_site_key }
    rescue Exception => e
      Airbrake.notify(e) if defined?(Airbrake)
      raise e if @reraise_error
      cache.last_cached_value
    end

    def cache
      @cache ||= SettingsCache.new
    end

    def settings_by_site_key
      response = client.by_site_key(@site_key)
      fail(BackendError, response.body) unless response.status == 200
      JSON.parse(response.body)
    end

    def client
      Client.new(@url)
    end
  end
end
