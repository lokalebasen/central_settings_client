require 'spec_helper'
require_relative '../../lib/lokalebasen_settings_client/client'
require_relative '../../lib/lokalebasen_settings_client/caching_client'

describe LokalebasenSettingsClient::CachingClient do
  let(:site_key) { 'dk' }
  let(:client) {
    LokalebasenSettingsClient::CachingClient.new('https://foo.bar')
  }

  describe "checking server health" do
    it "returns true if the status is 200" do
      allow_any_instance_of(LokalebasenSettingsClient::Client)
        .to receive(:health_check)
        .and_return(double(status: 200))
      expect(client).to be_healthy
    end

    it "returns true if the status is 200" do
      allow_any_instance_of(LokalebasenSettingsClient::Client)
        .to receive(:health_check)
        .and_return(double(status: 500))
      expect(client).not_to be_healthy
    end
  end

  describe "fetching settings by site key" do
    let(:raw_client) { double("Client") }
    let(:raw_client_class) { double(new: raw_client) }

    before :each do
      stub_const "LokalebasenSettingsClient::Client", double(new: raw_client)
    end

    it "returns the value given by the cache" do
      allow_any_instance_of(LokalebasenSettingsClient::SettingsCache)
        .to receive(:cached)
        .and_return("cached value")
      expect(client.by_site_key(site_key)).to eq('cached value')
    end

    context "when the server raises an exception" do
      before :each do
        allow_any_instance_of(LokalebasenSettingsClient::SettingsCache)
          .to receive(:cached)
          .and_yield
        allow(raw_client)
          .to receive(:json_settings_by_site_key)
          .and_raise(LokalebasenSettingsClient::BackendError)
      end

      it "notifies Airbrake" do
        client.reraise_error = false
        airbrake = double("Airbrake")
        stub_const "Airbrake", airbrake
        expect(airbrake).to receive(:notify)
        client.by_site_key(site_key)
      end

      it "raises the error if reraise_error is true" do
        client.reraise_error = true
        expect {
          client.by_site_key(site_key)
        }.to raise_error(LokalebasenSettingsClient::BackendError)
      end

      it "returns the last cached value when not set to reraise error" do
        client.reraise_error = false
        client.by_site_key(site_key)
        allow_any_instance_of(LokalebasenSettingsClient::SettingsCache)
          .to receive(:cached)
          .and_return("cached value")
        client.by_site_key(site_key)
        expect(client.by_site_key(site_key)).to eq('cached value')
      end
    end
  end
end
