module LokalebasenSettingsClient
  class SettingsCache
    DEFAULT_CACHE_TIME = 60 * 60 # 1 hour

    attr_reader :cache
    attr_accessor :cache_time
    private :cache

    def initialize(cache_time = DEFAULT_CACHE_TIME)
      @cache_time = cache_time

      @cache = {}
    end

    def cached(&block)
      return @cache[:value] if cache_valid?
      new_value = yield
      @cache = {
        value: new_value,
        expires: Time.now + cache_time
      }
      new_value
    rescue Exception => exception
      @cache[:expires] = Time.now + cache_time if @cache.is_a?(Hash)
      raise exception
    end

    def last_cached_value
      @cache[:value]
    end

    private

    def cache_valid?
      !@cache.nil? &&
        !@cache[:expires].nil? &&
        @cache[:expires] > Time.now
    end
  end
end
