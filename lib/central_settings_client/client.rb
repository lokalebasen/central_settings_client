module CentralSettingsClient
  class Client
    attr_reader :settings_service_url, :eternal_file_cache
    HttpError = Class.new(RuntimeError)

    def initialize(settings_service_url, eternal_file_cache: false)
      @object_cache = CentralSettingsClient::ObjectCache.new
      @settings_service_url = settings_service_url
      @eternal_file_cache = eternal_file_cache
    end

    def by_site_key(site_key)
      path = path_for_site_key(site_key)
      @object_cache.read(path) do
        data = quietly_fetch(path)
        CentralSettingsClient::Dictionary.new(data, site_key) if data.present?
      end
    end

    def by_domain(domain)
      data = all.find do |site|
        site.fetch('domain') == domain
      end
      CentralSettingsClient::Dictionary.new(data, domain)
    end

    def all
      path = 'api/all'
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
      response_data = fetch(path)
      JSON.parse(response_data)
    rescue JSON::ParserError, TypeError, Faraday::ConnectionFailed, HttpError
      nil
    end

    def fetch(path)
      if eternal_file_cache
        read_from_file_cache(path) { remotely_fetch(path) }
      else
        remotely_fetch(path)
      end
    end

    def remotely_fetch(path)
      response = client.get(path)
      fail HttpError, response.status if response.status != 200
      response.body.force_encoding('UTF-8')
    end

    def client
      @client ||= Faraday.new(settings_service_url) do |faraday|
        faraday.adapter :excon
      end
    end

    def read_from_file_cache(path)
      file_path = "tmp/cache/central_settings_client/#{path}"
      if File.exist?(file_path)
        File.read(file_path)
      else
        response_body = yield
        FileUtils.mkdir_p(File.dirname(file_path))
        File.write(file_path, response_body)
        response_body
      end
    end
  end
end
