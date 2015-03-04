require 'spec_helper'

RSpec.shared_examples 'fetching settings' do |get_method, get_arg, vcr_postfix|
  describe get_method do
    context 'Working backend' do
      it 'fetches settings hash' do
        VCR.use_cassette "working_backend_#{vcr_postfix}" do
          expect(client.public_send(get_method, get_arg)['site_name']).to eql('Lokalebasen.dk')
        end
      end

    end

    context 'dead backend' do
      it 'fetches settings hash' do
        VCR.use_cassette "dead_backend_#{vcr_postfix}" do
          expect { client.public_send(get_method, get_arg)['site_name'] }.to raise_error
        end
      end

    end

    context 'cached response' do
      before do
        VCR.use_cassette "working_backend_#{vcr_postfix}" do
          client.public_send(get_method, get_arg)
        end
      end

      it 'uses the cache' do
        expect(client.public_send(get_method, get_arg)['site_name']).to eql('Lokalebasen.dk')
      end
    end

    context 'cached response is expired and backend is dead' do
      before do
        client.reraise_error = false
        VCR.use_cassette "working_backend_#{vcr_postfix}" do
          client.public_send(get_method, get_arg)
        end
        Timecop.freeze(Time.now + 60 * 60 * 2) # Expire cache
      end

      after do
        Timecop.return
      end

      it 'uses the cache' do
        expect(client.public_send(get_method, get_arg)['site_name']).to eql('Lokalebasen.dk')
      end

      it 'respects raise_error' do
        client.reraise_error = true
        expect { client.public_send(get_method, get_arg)['site_name'] }.to raise_error
      end
    end

    context 'backend is slow' do
      before do
        client.reraise_error = false
        VCR.use_cassette "working_backend_#{vcr_postfix}" do
          client.public_send(get_method, get_arg)
        end
        Timecop.freeze(Time.now + 60 * 60 * 2) # Expire cache
        allow(client.send(:client)).to receive(:get)
          .and_raise(LokalebasenSettingsClient::TimeoutError, 'test')
      end

      after do
        Timecop.return
      end

      it 'returns the cached response when backend is too slow' do
        expect(client.public_send(get_method, get_arg)['site_name']).to eql('Lokalebasen.dk')
      end

      it 'raises specific error when configured to reraise' do
        client.reraise_error = true
        expect { client.public_send(get_method, get_arg)['site_name'] }.to raise_error
      end
    end
  end
end

describe LokalebasenSettingsClient do
  def default_client
    LokalebasenSettingsClient::CachingClient.new('https://foo.bar')
  end

  describe 'health check' do
    let(:client) { default_client }

    it 'is alive with a working backend' do
      VCR.use_cassette "working_backend_healthy" do
        expect(client.healthy?).to be true
      end
    end

    it 'is not alive' do
      VCR.use_cassette "dead_backend_healthy" do
        expect(client.healthy?).to be false
      end
    end

  end

  include_examples "fetching settings", :get, 'dk', 'site_key' do
    let(:client) { default_client }
  end

  include_examples "fetching settings", :get_by_domain, "catalog.dev", 'domain' do
    let(:client) { default_client }
  end
end

