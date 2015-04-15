module CentralSettingsClient
  class SettingsCache
    DEFAULT_CACHE_TIME = 60 * 60 # 1 hour

    attr_reader :cache
    attr_accessor :cache_time
    private :cache

    def initialize(cache_time = DEFAULT_CACHE_TIME)
      @cache_time = cache_time

      @cache = {}
    end

    def cached(cache_key)
      return cache_value(cache_key) if cache_valid?(cache_key)
      yield.tap do |new_value|
        update_cache(cache_key, new_value)
      end
    rescue Exception => exception
      set_cache_expiration(cache_key, Time.now + cache_time)
      raise exception
    end

    def last_cached_value(cache_key)
      cache_value(cache_key)
    end

    private

    def set_cache_expiration(cache_key, expiration)
      fetch_cache(cache_key)[:expires] = expiration
    end

    def update_cache(cache_key, value)
      @cache[cache_key] = {
        value: value,
        expires: Time.now + cache_time
      }
    end

    def cache_expiration(cache_key)
      fetch_cache(cache_key).fetch(:expires, nil)
    end

    def cache_value(cache_key)
      fetch_cache(cache_key).fetch(:value, nil)
    end

    def cache_valid?(cache_key)
      !fetch_cache(cache_key).nil? &&
        !cache_expiration(cache_key).nil? &&
        cache_expiration(cache_key) > Time.now
    end

    def fetch_cache(cache_key)
      @cache[cache_key] ||= {}
    end
  end
end
