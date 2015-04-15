require 'spec_helper'
require_relative '../../lib/central_settings_client/client'

describe CentralSettingsClient::Client do
  let(:site_key) { 'dk' }
  let(:domain) { 'catalog.dev' }
  let(:client) { CentralSettingsClient::Client.new('https://foo.bar') }

  describe 'settings by site key' do
    it 'returns the settings as json when status is 200' do
      VCR.use_cassette 'working_backend' do
        expect(client.json_settings_by_site_key(site_key)).to include(
          'locale' => 'da'
        )
      end
    end

    it 'raises BackendError when status is not 200' do
      VCR.use_cassette 'dead_backend' do
        expect do
          client.json_settings_by_site_key(site_key)
        end.to raise_error(CentralSettingsClient::BackendError)
      end
    end

    it 'raises timeout error when the request is too slow' do
      allow(Timeout)
        .to receive(:timeout)
        .and_raise(CentralSettingsClient::TimeoutError)
      expect do
        client.json_settings_by_site_key(site_key)
      end.to raise_error(CentralSettingsClient::TimeoutError)
    end
  end

  describe 'settings by domain' do
    it 'returns the settings as json when status is 200' do
      VCR.use_cassette 'working_backend_domain' do
        expect(client.json_settings_by_domain(domain)).to include(
          'locale' => 'da'
        )
      end
    end

    it 'raises BackendError when status is not 200' do
      VCR.use_cassette 'dead_backend_domain' do
        expect do
          client.json_settings_by_domain(domain)
        end.to raise_error(CentralSettingsClient::BackendError)
      end
    end

    it 'raises timeout error when the request is too slow' do
      allow(Timeout)
        .to receive(:timeout)
        .and_raise(CentralSettingsClient::TimeoutError)
      expect do
        client.json_settings_by_domain(domain)
      end.to raise_error(CentralSettingsClient::TimeoutError)
    end
  end

  describe 'all settings' do
    it 'returns the settings as json when status is 200' do
      VCR.use_cassette 'working_backend_all' do
        settings = client.all_json_settings
        expect(settings.length).to eq(2)
        expect(settings.first).to include('locale' => 'da')
      end
    end

    it 'raises BackendError when status is not 200' do
      VCR.use_cassette 'dead_backend_all' do
        expect do
          client.all_json_settings
        end.to raise_error(CentralSettingsClient::BackendError)
      end
    end

    it 'raises timeout error when the request is too slow' do
      allow(Timeout)
        .to receive(:timeout)
        .and_raise(CentralSettingsClient::TimeoutError)
      expect do
        client.all_json_settings
      end.to raise_error(CentralSettingsClient::TimeoutError)
    end
  end

  describe 'health check' do
    it 'returns the response with status 200' do
      VCR.use_cassette 'working_backend_healthy' do
        expect(client.health_check.status).to eq(200)
      end
    end
  end
end