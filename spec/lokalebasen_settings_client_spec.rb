require 'spec_helper'

describe LokalebasenSettingsClient do

  context "Working backend" do
    let(:client) { LokalebasenSettingsClient::CachingClient.new('https://central-settings.services.lokalebasen.dk', 'dk') }

    it "works" do
      VCR.use_cassette "working_backend" do
        expect(client.get['site_name']).to eql('Lokalebasen.dk')
      end
    end
  end
end
