require 'spec_helper'
require_relative '../../lib/lokalebasen_settings_client/settings_cache'

describe LokalebasenSettingsClient::SettingsCache do
  let(:cache_time) { 60 * 60 }
  let(:cache) { LokalebasenSettingsClient::SettingsCache.new(cache_time) }

  it "responds with the newly cached value" do
    expect(cache.cached { 'hello world' }).to eq('hello world')
  end

  it "responds with the earlier cached value when within caching time" do
    cache.cached { 'my cool world' }
    expect(cache.cached { 'my new cool world' }).to eq('my cool world')
  end

  it "caches new value when cache is busted" do
    cache.cached { 'hello hello' }
    Timecop.travel(Time.now + cache_time + 1) do
      expect(cache.cached { 'new value' }).to eq('new value')
    end
  end

  it "postpones cache when exception is raised" do
    cache.cached { 'hello my world' }
    Timecop.travel(Time.now + cache_time + 1) do
      expect { cache.cached { fail StandardError } }.to raise_error
      expect(cache.cached { 'new hello world'}).to eq('hello my world')
    end
  end

  it "returns last cached value" do
    cache.cached { 'hello world' }
    expect(cache.last_cached_value).to eq('hello world')
  end

  it "is able to returned the last cached value after failed caching" do
    cache.cached { 'hello my cool world' }
    Timecop.travel(Time.now + cache_time + 1) do
      expect { cache.cached { fail StandardError } }.to raise_error
      expect(cache.last_cached_value).to eq('hello my cool world')
    end
  end

  # Since a failed attempt could mean that the settings server is down
  # we don't want to spend 0.5 seconds on fetching settings. Instead
  # we just wait for another hour before trying to fetch the latest settings
  it "postpones cache expiration when cache attempt failes" do
    cache.cached { 'hello world' }
    Timecop.travel(Time.now + cache_time + 1) do
      expect { cache.cached { fail StandardError } }.to raise_error
      expect(cache.cached { 'new value' }).to eq('hello world')
    end
  end
end
