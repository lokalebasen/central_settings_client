require 'spec_helper'
require_relative '../../lib/lokalebasen_settings_client/client'

describe LokalebasenSettingsClient::Client do
  let(:site_key) { 'dk' }
  let(:client) { LokalebasenSettingsClient::Client.new('https://foo.bar') }

  describe "settings by site key" do
    it "returns the response with status 200" do
      VCR.use_cassette 'working_backend' do
        expect(client.by_site_key(site_key).status).to eq(200)
      end
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
