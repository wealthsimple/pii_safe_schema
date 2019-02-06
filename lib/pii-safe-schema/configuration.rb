class PiiSafeSchema::Configuration
  attr_accessor :ignore

  def initialize
    @ignore = {
      schema_migrations: :*,
      ar_internal_metadata: :*
    }
  end

  def ignore_tables
    @ignore_tables ||= ignore.select { |k,v| v.to_s == "*" }.keys
  end

  def ignore_columns
    @ignore_columns ||= ignore.select { |k,v| v.is_a?(Array) }
  end
end
