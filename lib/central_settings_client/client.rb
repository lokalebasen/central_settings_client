module CentralSettingsClient
  class Client
    attr_reader :settings_service_url

    def initialize(settings_service_url)
      @object_cache = CentralSettingsClient::ObjectCache.new
      @settings_service_url = settings_service_url
    end

    def by_site_key(site_key)
      path = path_for_site_key(site_key)
      @object_cache.read(path) do
        quietly_fetch(path)
      end
    end

    def by_domain(domain)
      all.find do |site|
        site.fetch('domain') == domain
      end
    end

    def all
      path = "api/all"
      @object_cache.read(path) do
        quietly_fetch(path)
      end
    end

    def healthy?
      client.get('/health_check').status == 200
    end

    private

    def path_for_site_key(site_key)
      "api/#{site_key}"
    end

    def quietly_fetch(path)
      response = client.get(path)
      return nil if response.status != 200
      JSON.parse(response.body)
    rescue JSON::ParserError, TypeError, Faraday::ConnectionFailed
      nil
    end

    def client
      @client ||= Faraday.new(settings_service_url) do |faraday|
        faraday.adapter :excon
      end
    end
  end
end
