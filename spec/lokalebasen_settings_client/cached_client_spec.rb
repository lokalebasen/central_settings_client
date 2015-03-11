require 'spec_helper'
require_relative '../../lib/lokalebasen_settings_client/client'
require_relative '../../lib/lokalebasen_settings_client/cached_client'

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
  end
end
