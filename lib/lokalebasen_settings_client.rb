require 'timeout'
require 'faraday'
require 'json'

require 'lokalebasen_settings_client/version'
require 'lokalebasen_settings_client/client'
require 'lokalebasen_settings_client/settings_cache'
require 'lokalebasen_settings_client/caching_client'
require 'lokalebasen_settings_client/robust_settings_cache'

module LokalebasenSettingsClient
  class BackendError < RuntimeError; end
  class TimeoutError < RuntimeError; end
end
