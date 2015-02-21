require 'spec_helper'

describe LokalebasenSettingsClient do

  context "Working backend" do
    let(:client) { LokalebasenSettingsClient::CachingClient.new('https://foo.bar', 'dk') }

    it "fetches settings hash" do
      VCR.use_cassette "working_backend" do
        expect(client.get['site_name']).to eql('Lokalebasen.dk')
      end
    end

    it "is alive" do
      VCR.use_cassette "working_backend_healthy" do
        expect(client.healthy?).to be true
      end
    end
  end

  context "dead backend" do
    let(:client) { LokalebasenSettingsClient::CachingClient.new('https://foo.bar', 'dk') }

    it "fetches settings hash" do
      VCR.use_cassette "dead_backend" do
        expect { client.get['site_name'] }.to raise_error
      end
    end

    it "is alive" do
      VCR.use_cassette "dead_backend_healthy" do
        expect(client.healthy?).to be false
      end
    end
  end

  context "cached response" do
    let(:client) { LokalebasenSettingsClient::CachingClient.new('https://foo.bar', 'dk') }

    before do
      VCR.use_cassette "working_backend" do
        client.get
      end
    end

    it "uses the cache" do
      expect(client.get['site_name']).to eql('Lokalebasen.dk')
    end
  end
end
