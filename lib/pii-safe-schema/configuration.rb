class PiiSafeSchema::Configuration
  attr_accessor :ignore, :ignore_columns,

  def initialize
    @ignore = {
      schema_migrations: :*,
      ar_internal_metadata: :*,
      known_devices: [:hi, :bye]
    }
  end

  def ignore_tables
    @ignore_tables ||= ignore.select { |k,v| v.to_s == "*" }.keys
  end

  def ignore_columns
    @ignore_columns ||= ignore.select { |k,v| v.is_a?(Array) }
  end
end
