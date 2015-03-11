require 'lokalebasen_settings_client/version'
require 'timeout'
require 'faraday'
require 'json'

module LokalebasenSettingsClient
  class BackendError < RuntimeError; end
  class TimeoutError < RuntimeError; end

  class Client
    attr_reader :settings_service_url
    attr_accessor :timeout

    def initialize(settings_service_url)
      @settings_service_url = settings_service_url

      @timeout = 0.5
    end

    def by_site_key(site_key)
      client.get("/api/#{site_key}")
    end

    def health_check
      client.get('/health_check')
    end

    private

    def with_timeout(&block)
      Timeout.timeout(timeout, TimeoutError) do
        yield
      end
    end

    def client
      @client ||= Faraday.new(settings_service_url) do |faraday|
        faraday.adapter :excon
      end
    end
  end

  class SettingsCache
    attr_reader :cache
    attr_accessor :cache_time
    private :cache

    def initialize
      @cache_time = 60 * 60 # 1 Hour

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

    def cache_valid?
      !@cache.nil? &&
        !@cache[:expires].nil? &&
        @cache[:expires] > Time.now
    end
  end

  # Caching client for lokalebase settings
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
