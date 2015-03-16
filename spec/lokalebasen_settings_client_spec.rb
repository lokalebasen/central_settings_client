require 'spec_helper'

describe LokalebasenSettingsClient do
  let(:site_key) { 'dk' }

  def default_client
    LokalebasenSettingsClient::CachingClient.new('https://foo.bar')
  end

  context 'Working backend' do
    let(:client) { default_client }

    it 'fetches settings hash' do
      VCR.use_cassette 'working_backend' do
        expect(client.by_site_key(site_key)['site_name'])
          .to eql('Lokalebasen.dk')
      end
    end

    it 'is alive' do
      VCR.use_cassette 'working_backend_healthy' do
        expect(client.healthy?).to be true
      end
    end
  end

  context 'dead backend' do
    let(:client) { default_client }

    it 'fetches settings hash' do
      VCR.use_cassette 'dead_backend' do
        expect { client.by_site_key(site_key)['site_name'] }.to raise_error
      end
    end

    it 'is alive' do
      VCR.use_cassette 'dead_backend_healthy' do
        expect(client.healthy?).to be false
      end
    end
  end

  context 'cached response' do
    let(:client) { default_client }

    before do
      VCR.use_cassette 'working_backend' do
        client.by_site_key(site_key)
      end
    end

    it 'uses the cache' do
      expect(client.by_site_key(site_key)['site_name']).to eql('Lokalebasen.dk')
    end
  end

  context 'cached response is expired and backend is dead' do
    let(:client) { default_client }

    before do
      client.reraise_error = false
      VCR.use_cassette 'working_backend' do
        client.by_site_key(site_key)
      end
      Timecop.freeze(Time.now + 60 * 60 * 2) # Expire cache
    end

    after do
      Timecop.return
    end

    it 'uses the cache' do
      expect(client.by_site_key(site_key)['site_name']).to eql('Lokalebasen.dk')
    end

    it 'respects raise_error' do
      client.reraise_error = true
      expect { client.by_site_key(site_key)['site_name'] }.to raise_error
    end
  end

  context 'backend is slow' do
    let(:client) { default_client }

    before do
      client.reraise_error = false
      VCR.use_cassette 'working_backend' do
        client.by_site_key(site_key)
      end
      Timecop.freeze(Time.now + 60 * 60 * 2) # Expire cache
    end

    after do
      Timecop.return
    end

    it 'returns the cached response when backend is too slow' do
      expect(client.by_site_key(site_key)['site_name']).to eql('Lokalebasen.dk')
    end

    it 'raises specific error when configured to reraise' do
      client.reraise_error = true
      expect { client.by_site_key(site_key)['site_name'] }.to raise_error
    end
  end
end
