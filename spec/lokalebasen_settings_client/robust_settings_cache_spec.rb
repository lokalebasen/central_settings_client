require 'spec_helper'
require_relative '../../lib/lokalebasen_settings_client/robust_settings_cache'
require_relative '../../lib/lokalebasen_settings_client/settings_cache'

describe LokalebasenSettingsClient::RobustSettingsCache do
  describe 'fetching settings by site key' do
    let(:cache) do
      LokalebasenSettingsClient::SettingsCache.new
    end
    let(:robust_cache) do
      LokalebasenSettingsClient::RobustSettingsCache.new(cache)
    end

    it 'returns the value given by the cache' do
      expect(robust_cache.cached('key') { 'hello world' }).to eq('hello world')
    end

    context 'when the cache update raises an exception' do
      it 'notifies Airbrake' do
        robust_cache.reraise_error = false
        airbrake = double('Airbrake')
        stub_const 'Airbrake', airbrake
        expect(airbrake).to receive(:notify)
        robust_cache.cached('key')  { fail StandardError }
      end

      it 'raises the error if reraise_error is true' do
        robust_cache.reraise_error = true
        expect do
          robust_cache.cached('key')  { fail StandardError }
        end.to raise_error(StandardError)
      end

      it 'returns the last cached value when not set to reraise error' do
        robust_cache.reraise_error = false
        robust_cache.cached('key') { 'cached value' }
        expect(
          robust_cache.cached('key') { fail StandardError }
        ).to eq('cached value')
      end
    end
  end
end
