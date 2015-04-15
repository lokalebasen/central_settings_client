require 'timeout'
require 'faraday'
require 'json'

require 'central_settings_client/version'
require 'central_settings_client/client'
require 'central_settings_client/settings_cache'
require 'central_settings_client/caching_client'
require 'central_settings_client/robust_settings_cache'

module CentralSettingsClient
  class BackendError < RuntimeError; end
  class TimeoutError < RuntimeError; end
end
