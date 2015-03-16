require 'spec_helper'
require_relative '../../lib/lokalebasen_settings_client/caching_client'

describe LokalebasenSettingsClient::CachingClient do
  let(:site_key) { 'dk' }
  let(:client) do
    LokalebasenSettingsClient::CachingClient.new('https://foo.bar')
  end

  describe 'checking server health' do
    it 'returns true if the status is 200' do
      allow_any_instance_of(LokalebasenSettingsClient::Client)
        .to receive(:health_check)
        .and_return(double(status: 200))
      expect(client).to be_healthy
    end

    it 'returns true if the status is 200' do
      allow_any_instance_of(LokalebasenSettingsClient::Client)
        .to receive(:health_check)
        .and_return(double(status: 500))
      expect(client).not_to be_healthy
    end
  end

  describe 'by site key' do
    it 'returns the value from the cache' do
      allow_any_instance_of(LokalebasenSettingsClient::RobustSettingsCache)
        .to receive(:cached)
        .and_return('cached value')
      expect(client.by_site_key('dk')).to eq('cached value')
    end

    it 'finds settings by site key when cache block is called' do
      allow_any_instance_of(LokalebasenSettingsClient::RobustSettingsCache)
        .to receive(:cached)
        .and_yield
      client_instance = double('Client')
      stub_const(
        'LokalebasenSettingsClient::Client',
        double(new: client_instance)
      )
      expect(client_instance).to receive(:json_settings_by_site_key).with('dk')
      client.by_site_key('dk')
    end
  end

  describe 'by domain' do
    it 'returns the value from the cache' do
      allow_any_instance_of(LokalebasenSettingsClient::RobustSettingsCache)
        .to receive(:cached)
        .and_return('cached value')
      expect(client.by_domain('catalog.dev')).to eq('cached value')
    end

    it 'finds settings by site key when cache block is called' do
      allow_any_instance_of(LokalebasenSettingsClient::RobustSettingsCache)
        .to receive(:cached)
        .and_yield
      client_instance = double('Client')
      stub_const(
        'LokalebasenSettingsClient::Client',
        double(new: client_instance)
      )
      expect(client_instance)
        .to receive(:json_settings_by_domain)
        .with('catalog.dev')
      client.by_domain('catalog.dev')
    end
  end
end
