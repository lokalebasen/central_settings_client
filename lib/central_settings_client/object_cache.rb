module CentralSettingsClient
  class ObjectCache
    attr_reader :cache

    def initialize
      @cache = {}
    end

    def read(key, &block)
      key = key.to_s
      if cache[key].nil?
        cache[key] = CentralSettingsClient::CacheRecord.new(block)
      end
      cache[key].value
    end

  end
end
