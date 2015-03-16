module LokalebasenSettingsClient
  class RobustSettingsCache
    attr_reader :cache
    attr_accessor :reraise_error

    def initialize(cache)
      @cache = cache

      @reraise_error = true
    end

    def cached(cache_key, &block)
      cache.cached cache_key do
        yield
      end
    rescue Exception => e
      Airbrake.notify(e) if defined?(Airbrake)
      raise e if reraise_error
      cache.last_cached_value(cache_key)
    end
  end
end
