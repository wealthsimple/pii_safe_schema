module PiiSafeSchema
  class Configuration
    DEFAULT_IGNORE = {
      schema_migrations: :*,
      ar_internal_metadata: :*,
    }.freeze

    KNOWN_DD_CLIENTS = %w[DataDogClient Ws::Railway::Datadog].freeze

    def initialize
      @user_ignore = {}
    end

    def ignore=(ignore_params)
      validate_ignore(ignore_params)
      @user_ignore = ignore_params
    end

    def ignore
      @user_ignore.merge(DEFAULT_IGNORE)
    end

    def datadog_client=(client)
      raise_config_error(:datadog_client) if client.present? && !client.respond_to?(:event)

      @datadog_client = client
    end

    def datadog_client
      @datadog_client ||= begin
        KNOWN_DD_CLIENTS.each do |client|
          return client.safe_constantize if defined?(client)
        end
      end
    end

    def ignore_tables
      ignore.select { |_k, v| v.to_s == '*' }.keys.map(&:to_s)
    end

    def ignore_columns
      ignore.select { |_k, v| v.is_a?(Array) }
    end

    private

    def validate_ignore(ignore_params)
      raise_config_error(:ignore) unless ignore_params.is_a?(Hash)

      ignore_params.values.each do |ip|
        raise_config_error(:ignore) unless valid_column_list?(ip) || ip == :*
      end
      true
    end

    def valid_column_list?(value)
      value.is_a?(Array) && value.all? { |c| c.is_a?(Symbol) }
    end

    def raise_config_error(problem)
      raise ConfigurationError.new(problem)
    end
  end

  class ConfigurationError < StandardError
    def initialize(problem)
      super(
        case problem
        when :ignore
          <<~HEREDOC
            ignore must be a hash where the values are
            symbols or arrays of symbols.
            e.g. ignore = { some_table: :* } ##ignore the whole some_table
            or   ignore = { some_table: [:some_column, :some_other_column] }
          HEREDOC
        when :datadog_client
          <<~HEREDOC
            Datadog client must be implement #event(title, text, opts = {})

            Consider using dogstatsd-ruby gem and pass in Datadog::Statsd.new(...)
            as the client.
          HEREDOC
        else
          problem
        end
      )
    end
  end
end
