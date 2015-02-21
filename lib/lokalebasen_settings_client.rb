require "lokalebasen_settings_client/version"
require 'timeout'
require 'faraday'
require 'json'

module LokalebasenSettingsClient
  class LokalebasenSettingsClient::BackendError < RuntimeError; end
  class LokalebasenSettingsClient::TimeoutError < RuntimeError; end

  class CachingClient
    def initialize(url, site_key)
      @url = url
      @site_key = site_key

      # Default values
      @timeout = 0.5
      @cache_time = 60 * 60 # 1 Hour
      @raise_error = true
    end

    def healthy?
      health_check.status == 200
    end

    def get
      update_cache unless cache_valid?
      @cache[:value]
    end

    def timeout=(timeout)
      @timeout = timeout
    end

    def cache_time=(cache_time)
      @cache_time = cache_time
    end

    def raise_error=(raise_error)
      @raise_error = raise_error
    end

    private

    def update_cache
      Timeout::timeout(@timeout, LokalebasenSettingsClient::TimeoutError) do
        @cache = {
          value: json,
          expires: Time.now + @cache_time
        }
      end
    rescue Exception => e
      @cache[:expires] = Time.now + @cache_time if @cache.is_a?(Hash)
      Airbrake.notify(e)if defined?(Airbrake)
      raise e if @raise_error
    end

    def cache_valid?
      !@cache.nil? && !@cache[:expires].nil? && @cache[:expires] > Time.now
    end

    def health_check
      client.get("/health_check")
    end

    def json
      response = fetch
      fail LokalebasenSettingsClient::BackendError, response.body unless response.status == 200
      JSON.parse(response.body)
    end

    def fetch
      client.get("/api/#{@site_key}")
    end

    def client
      @client ||= Faraday.new(@url) do |faraday|
        faraday.adapter :excon
      end
    end
  end

end
