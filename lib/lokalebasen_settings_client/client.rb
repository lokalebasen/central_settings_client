module LokalebasenSettingsClient
  class Client
    attr_reader :settings_service_url
    attr_accessor :timeout

    def initialize(settings_service_url)
      @settings_service_url = settings_service_url

      @timeout = 0.5
    end

    def json_settings_by_site_key(site_key)
      get_json_with_timeout("/api/#{site_key}")
    end

    def json_settings_by_domain(domain)
      get_json_with_timeout("/api/domain/#{domain}")
    end

    def all_json_settings
      get_json_with_timeout('/api/all')
    end

    def health_check
      client.get('/health_check')
    end

    private

    def get_json_with_timeout(path)
      response = with_timeout { client.get(path) }
      fail BackendError, response.body unless response.status == 200
      JSON.parse(response.body)
    end

    def with_timeout
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
