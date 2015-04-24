module CentralSettingsClient
  class CacheRecord
    TIMEOUT = 0.5 # Seconds
    EXPIRATION_TIME = 3600 # One hour in seconds

    attr_accessor :expires_at, :last_computed_value, :block

    def initialize(block)
      self.block = block
    end

    def value
      refresh! if stale?
      fail CentralSettingsClient::BackendError if last_computed_value.nil?
      last_computed_value
    end

    private

    def stale?
      expires_at.nil? || expires_at.past?
    end

    def refresh!
      current_value = impatiently_recompute_block
      self.last_computed_value = current_value unless current_value.nil?
      update_expires_at!
    end

    def update_expires_at!
      self.expires_at = EXPIRATION_TIME.seconds.from_now
    end

    def impatiently_recompute_block
      Timeout.timeout(TIMEOUT) do
        block.call
      end
    rescue Timeout::Error
      nil
    end
  end
end
