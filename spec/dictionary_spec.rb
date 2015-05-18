require 'spec_helper'

describe CentralSettingsClient::Dictionary do
  let(:source_hash) { { address: { address_line_1: 'Falkoner Alle 123', postal_code: '2000' }, phone: '12 34 56 78', employees: %w(Alice Bob) } }
  let(:dictionary) { CentralSettingsClient::Dictionary.new(source_hash, 'rspec') }

  it 'supports reading from nested hashes using dot notation' do
    expect(dictionary.read('address.postal_code')).to eql '2000'
  end

  it 'returns source hash when reading with an empty values' do
    source = source_hash.deep_stringify_keys
    nil_read = dictionary.read(nil)
    blank_read = dictionary.read('')

    expect(source).to eql nil_read
    expect(source).to eql blank_read
  end

  it 'is agnostic to leaf node class' do
    expect(dictionary.read('employees')).to be_a Array
    expect(dictionary.read('address')).to be_a Hash
    expect(dictionary.read('phone')).to be_a String
  end

  it 'fails on missing keys' do
    expect { dictionary.read('absent_key') }.to raise_error KeyError
  end
end
