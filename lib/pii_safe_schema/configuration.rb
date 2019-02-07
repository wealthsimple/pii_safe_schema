class PiiSafeSchema::Configuration
  attr_accessor :ignore

  def initialize
    @ignore = {
      schema_migrations: :*,
      ar_internal_metadata: :*,
    }
  end

  def ignore_tables
    ignore.select { |_k, v| v.to_s == '*' }.keys.map(&:to_s)
  end

  def ignore_columns
    ignore.select { |_k, v| v.is_a?(Array) }
  end
end
