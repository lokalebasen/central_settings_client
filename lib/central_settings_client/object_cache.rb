module CentralSettingsClient
  class ObjectCache
    attr_reader :cache

    def initialize
      @cache = {}
    end

    def read(key, &block)
      key = key.to_s
      cache[key] ||= CentralSettingsClient::CacheRecord.new(block)
      cache[key].value
    end

  end
end
