module CentralSettingsClient
  class EchoDictionary < CentralSettingsClient::Dictionary
    def read(key)
      super(key)
    rescue KeyError
      key
    end
  end
end
