require 'spec_helper'

describe CentralSettingsClient do
  let(:site_key) { 'dk' }

  def default_client
    CentralSettingsClient::Client.new('https://foo.bar')
  end

  context 'Working backend' do
    let(:client) { default_client }

    it 'fetches settings hash' do
      VCR.use_cassette 'working_backend' do
        expect(client.by_site_key(site_key).read('site_name'))
          .to eql('Lokalebasen.dk')
      end
    end

  end

  context 'dead backend' do
    let(:client) { default_client }

    it 'fetches settings hash' do
      VCR.use_cassette 'dead_backend' do
        expect { client.by_site_key(site_key) }.to raise_error
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
      expect(
        client.by_site_key(site_key).read('site_name')
      ).to eql('Lokalebasen.dk')
    end
  end

  context 'cached response is expired and backend is dead' do
    let(:client) { default_client }

    before do
      VCR.use_cassette 'working_backend' do
        client.by_site_key(site_key)
      end
      Timecop.freeze(Time.now + 60 * 60 * 2) # Expire cache
    end

    after do
      Timecop.return
    end

    it 'uses the cache' do
      VCR.use_cassette 'dead_backend' do
        expect(client.by_site_key(site_key).read('site_name'))
          .to eql('Lokalebasen.dk')
      end
    end
  end

  context 'backend is slow' do
    let(:client) { default_client }

    before do
      VCR.use_cassette 'working_backend' do
        client.by_site_key(site_key)
      end
      Timecop.freeze(Time.now + 60 * 60 * 2) # Expire cache
    end

    after do
      Timecop.return
    end

    it 'returns the cached response when backend is too slow' do
      expect(Timeout).to receive(:timeout).and_raise(Timeout::Error)
      expect(
        client.by_site_key(site_key).read('site_name')
      ).to eql('Lokalebasen.dk')
    end
  end
end
