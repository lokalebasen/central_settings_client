require 'bundler/setup'
Bundler.setup

require 'central_settings_client'
require 'vcr'
require 'webmock'
require 'timecop'
require 'timeout'

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
end
