require 'lokalebasen_settings_client/version'
require 'timeout'
require 'faraday'
require 'json'

module LokalebasenSettingsClient
  class BackendError < RuntimeError; end
  class TimeoutError < RuntimeError; end

  # Caching client for lokalebase settings
  class CachingClient
    attr_accessor :timeout, :cache_time, :reraise_error

    def initialize(url)
      @url = url

      # Default values
      @timeout = 0.5
      @cache_time = 60 * 60 # 1 Hour
      @reraise_error = true
    end

    def healthy?
      health_check.status == 200
    end

    def get(site_key)
      try_update_cache_for_site_key(site_key) unless cache_valid?
      @cache[:value]
    end

    def get_by_domain(domain)
      try_update_cache_for_domain(domain) unless cache_valid?
      @cache[:value]
    end

    private

    def try_update_cache_for_site_key(site_key)
      with_timeout_and_cache_fallback do
        update_cache(fetch_json_by_site_key(site_key))
      end
    end

    def try_update_cache_for_domain(domain)
      with_timeout_and_cache_fallback do
        update_cache(fetch_json_by_domain(domain))
      end
    end

    def update_cache(value)
      @cache = { value: value, expires: Time.now + cache_time }
    end

    def with_timeout_and_cache_fallback
      Timeout.timeout(timeout, TimeoutError) do
        yield
      end
    rescue Exception => e
      @cache[:expires] = Time.now + cache_time if @cache.is_a?(Hash)
      Airbrake.notify(e) if defined?(Airbrake)
      raise e if reraise_error
    end

    def cache_valid?
      !@cache.nil? && !@cache[:expires].nil? && @cache[:expires] > Time.now
    end

    def health_check
      client.get('/health_check')
    end

    def fetch_json_by_site_key(site_key)
      fetch_json("/api/#{site_key}")
    end

    def fetch_json_by_domain(domain)
      fetch_json("/api/domain/#{domain}")
    end

    def fetch_json(path)
      response = client.get(path)
      fail(BackendError, response.body) unless response.status == 200
      JSON.parse(response.body)
    end

    def client
      @client ||= Faraday.new(@url) do |faraday|
        faraday.adapter :excon
      end
    end
  end
end
