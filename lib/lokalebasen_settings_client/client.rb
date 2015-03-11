module LokalebasenSettingsClient
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
end
