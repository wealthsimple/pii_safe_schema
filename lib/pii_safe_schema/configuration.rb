module PiiSafeSchema
  class Configuration
    DEFAULT_IGNORE = {
      schema_migrations: :*,
      ar_internal_metadata: :*,
    }.freeze

    def initialize
      @user_ignore = {}
    end

    def ignore=(ignore_params)
      validate(ignore_params)
      @user_ignore = ignore_params
    end

    def ignore
      @user_ignore.merge(DEFAULT_IGNORE)
    end

    def ignore_tables
      ignore.select { |_k, v| v.to_s == '*' }.keys.map(&:to_s)
    end

    def ignore_columns
      ignore.select { |_k, v| v.is_a?(Array) }
    end

    private

    def validate(ignore_params)
      raise_config_error unless ignore_params.is_a?(Hash)

      ignore_params.values.each do |ip|
        raise_config_error unless valid_column_list?(ip) || ip == :*
      end
      true
    end

    def valid_column_list?(value)
      value.is_a?(Array) && value.all? { |c| c.is_a?(Symbol) }
    end

    def raise_config_error
      raise ConfigurationError, ConfigurationError.message
    end
  end

  class ConfigurationError < StandardError
    def self.message
      <<~HEREDOC
        ignore must be a hash where the values are
        symbols or arrays of symbols.
        e.g. ignore = { some_table: :* } ##ignore the whole some_table
        or   ignore = { some_table: [:some_column, :some_other_column] }
      HEREDOC
    end
  end
end
