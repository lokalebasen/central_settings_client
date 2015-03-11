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

  # Caching client for lokalebase settings
  class CachingClient
    extend Forwardable
    attr_writer :cache_time, :reraise_error

    def_delegator :client, :timeout=, :timeout=

    def initialize(url, site_key)
      @url = url
      @site_key = site_key

      # Default values
      @cache_time = 60 * 60 # 1 Hour
      @reraise_error = true
    end

    def healthy?
      health_check.status == 200
    end

    def get
      update_cache unless cache_valid?
      @cache[:value]
    end

    private

    def update_cache
      @cache = {
        value: json,
        expires: Time.now + @cache_time
      }
    rescue Exception => e
      @cache[:expires] = Time.now + @cache_time if @cache.is_a?(Hash)
      Airbrake.notify(e) if defined?(Airbrake)
      raise e if @reraise_error
    end

    def cache_valid?
      !@cache.nil? && !@cache[:expires].nil? && @cache[:expires] > Time.now
    end

    def health_check
      client.health_check
    end

    def json
      response = fetch
      fail(BackendError, response.body) unless response.status == 200
      JSON.parse(response.body)
    end

    def fetch
      client.by_site_key(@site_key)
    end

    def client
      Client.new(@url)
    end

  end
end
