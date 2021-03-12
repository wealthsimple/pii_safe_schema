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
      @datadog_client ||=
        KNOWN_DD_CLIENTS.find do |client|
          client.safe_constantize if defined?(client)
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

      ignore_params.each_value do |ip|
        raise_config_error(:ignore) unless valid_column_list?(ip) || ip == :*
      end
      true
    end

    def valid_column_list?(value)
      value.is_a?(Array) && value.all? { |c| c.is_a?(Symbol) }
    end

    def raise_config_error(problem)
      raise ConfigurationError, problem
    end
  end

  class ConfigurationError < StandardError
    IGNORE_MSG = <<~HEREDOC.freeze
      ignore must be a hash where the values are
      symbols or arrays of symbols.
      e.g. ignore = { some_table: :* } ##ignore the whole some_table
      or   ignore = { some_table: [:some_column, :some_other_column] }
    HEREDOC

    DD_CLIENT_MSG = <<~HEREDOC.freeze
      Datadog client must be implement #event(title, text, opts = {})

      Consider using dogstatsd-ruby gem and pass in Datadog::Statsd.new(...)
      as the client.
    HEREDOC

    def initialize(problem)
      super(
        case problem
        when :ignore
          IGNORE_MSG
        when :datadog_client
          DD_CLIENT_MSG
        else
          problem
        end
      )
    end
  end
end
