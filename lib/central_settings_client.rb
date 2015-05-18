require 'timeout'
require 'faraday'
require 'json'

require 'active_support/dependencies/autoload'
require 'active_support/core_ext/object'
require 'active_support/core_ext/numeric'
require 'central_settings_client/version'
require 'central_settings_client/client'
require 'central_settings_client/dictionary'
require 'central_settings_client/echo_dictionary'
require 'central_settings_client/object_cache'
require 'central_settings_client/cache_record'

module CentralSettingsClient
  class BackendError < RuntimeError; end
end
