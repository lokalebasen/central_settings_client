module CentralSettingsClient
  class Dictionary
    attr_reader :name

    def initialize(hash, name)
      unless hash.is_a?(Hash)
        fail(
          ArgumentError,
          "First argument must be a hash, not a '#{hash.class}'"
        )
      end
      @hash = hash.deep_stringify_keys
      @name = name
    end

    def fetch(*args)
      @hash.fetch(*args)
    end

    def read(full_key)
      return @hash if full_key.to_s.empty?
      search(@hash, full_key, full_key.split('.'))
    end

    private

    def search(hash, full_key, remaining_segments)
      current_level = remaining_segments.shift
      current_value = hash[current_level]

      if current_value.nil?
        fail KeyError, "#{full_key} is not defined for #{name}"
      end

      if remaining_segments.any?
        search(current_value, full_key, remaining_segments)
      else
        current_value
      end
    end
  end
end
