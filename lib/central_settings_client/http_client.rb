require 'open-uri'

module CentralSettingsClient
  class HttpClient
    attr_reader :base_url

    def initialize(base_url)
      @base_url = base_url
    end

    def get(path)
      full_url = File.join(base_url, path)
      open(full_url).read
    end

  end
end
