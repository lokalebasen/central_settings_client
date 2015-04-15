require 'spec_helper'
require_relative '../../lib/central_settings_client/client'

describe CentralSettingsClient::Client do
  let(:site_key) { 'dk' }
  let(:domain) { 'catalog.dev' }
  let(:client) { CentralSettingsClient::Client.new('https://foo.bar') }

  describe 'settings by site key' do
    it 'returns the settings as json when status is 200' do
      VCR.use_cassette 'working_backend' do
        expect(client.by_site_key(site_key)).to include(
          'locale' => 'da'
        )
      end
    end

    it 'raises BackendError when status is not 200' do
      VCR.use_cassette 'dead_backend' do
        expect do
          client.by_site_key(site_key)
        end.to raise_error(CentralSettingsClient::BackendError)
      end
    end

  end

  describe 'settings by domain' do
    it 'returns the settings as json when status is 200' do
      allow(client).to receive(:all) { ['domain' => 'catalog.dev', 'locale' => 'da'] }
      expect(client.by_domain(domain)).to include(
        'locale' => 'da'
      )
    end

    it 'raises BackendError when status is not 200' do
      allow(client).to receive(:all).and_raise(CentralSettingsClient::BackendError)
      expect do
        client.by_domain(domain)
      end.to raise_error(CentralSettingsClient::BackendError)

    end

  end

  describe 'all settings' do
    it 'returns the settings as json when status is 200' do
      VCR.use_cassette 'working_backend_all' do
        settings = client.all
        expect(settings.length).to eq(2)
        expect(settings.first).to include('locale' => 'da')
      end
    end

    it 'raises BackendError when status is not 200' do
      VCR.use_cassette 'dead_backend_all' do
        expect do
          client.all
        end.to raise_error(CentralSettingsClient::BackendError)
      end
    end

  end

  describe 'health check' do
    it 'returns the response with status 200' do
      VCR.use_cassette 'working_backend_healthy' do
        expect(client.healthy?).to eq(true)
      end
    end
  end
end
