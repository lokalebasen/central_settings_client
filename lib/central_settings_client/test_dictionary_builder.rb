module CentralSettingsClient
  class TestDictionaryBuilder
    STANDARD_ENTRIES = {
      contact_info: {
        offices: [
          {
            'key' => 'kobenhavn',
            'department_name' => 'København',
            'address_line' => 'Æbeløgade 4, 1.',
            'postal_code_and_city' => '2100 København Ø'
          },
          {
            'key' => 'aarhus',
            'department_name' => 'Aarhus',
            'address_line' => 'Arresøvej 6',
            'postal_code_and_city' => '8240 Risskov'
          }
        ]
      }
    }

    class << self
      def build(settings: {}, echo_missing_keys: true)
        merged_settings = STANDARD_ENTRIES.merge(settings).stringify_keys
        if echo_missing_keys
          CentralSettingsClient::EchoDictionary.new(
            merged_settings, 'TestDictionary'
          )
        else
          CentralSettingsClient::Dictionary.new(
            merged_settings, 'TestDictionary'
          )
        end
      end
    end
  end
end
