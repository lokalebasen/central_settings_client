require 'spec_helper'
require_relative '../../lib/lokalebasen_settings_client/client'

describe LokalebasenSettingsClient::Client do
  let(:site_key) { 'dk' }
  let(:domain) { 'catalog.dev' }
  let(:client) { LokalebasenSettingsClient::Client.new('https://foo.bar') }

  describe "settings by site key" do
    it "returns the settings as json when status is 200" do
      VCR.use_cassette 'working_backend' do
        expect(client.json_settings_by_site_key(site_key)).to include({
          "locale" => "da"
        });
      end
    end

    it "raises BackendError when status is not 200" do
      VCR.use_cassette 'dead_backend' do
        expect {
          client.json_settings_by_site_key(site_key)
        }.to raise_error(LokalebasenSettingsClient::BackendError)
      end
    end

    it "raises timeout error when the request is too slow" do
      allow(Timeout)
        .to receive(:timeout)
        .and_raise(LokalebasenSettingsClient::TimeoutError)
      expect {
        client.json_settings_by_site_key(site_key)
      }.to raise_error(LokalebasenSettingsClient::TimeoutError)
    end
  end

  describe "settings by domain" do
    it "returns the settings as json when status is 200" do
      VCR.use_cassette 'working_backend_domain' do
        expect(client.json_settings_by_domain(domain)).to include({
          "locale" => "da"
        });
      end
    end

    it "raises BackendError when status is not 200" do
      VCR.use_cassette 'dead_backend_domain' do
        expect {
          client.json_settings_by_domain(domain)
        }.to raise_error(LokalebasenSettingsClient::BackendError)
      end
    end

    it "raises timeout error when the request is too slow" do
      allow(Timeout)
        .to receive(:timeout)
        .and_raise(LokalebasenSettingsClient::TimeoutError)
      expect {
        client.json_settings_by_domain(domain)
      }.to raise_error(LokalebasenSettingsClient::TimeoutError)
    end
  end

  describe "all settings" do
    it "returns the settings as json when status is 200" do
      VCR.use_cassette 'working_backend_all' do
        settings = client.all_json_settings
        expect(settings.length).to eq(2)
        expect(settings.first).to include({"locale" => "da"})
      end
    end

    it "raises BackendError when status is not 200" do
      VCR.use_cassette 'dead_backend_all' do
        expect {
          client.all_json_settings
        }.to raise_error(LokalebasenSettingsClient::BackendError)
      end
    end

    it "raises timeout error when the request is too slow" do
      allow(Timeout)
        .to receive(:timeout)
        .and_raise(LokalebasenSettingsClient::TimeoutError)
      expect {
        client.all_json_settings
      }.to raise_error(LokalebasenSettingsClient::TimeoutError)
    end
  end

  describe "health check" do
    it "returns the response with status 200" do
      VCR.use_cassette 'working_backend_healthy' do
        expect(client.health_check.status).to eq(200)
      end
    end
  end
end
