class PiiSafeSchema::PiiColumn
  extend PiiSafeSchema::Annotations
  INGORE_TABLES = ["schema_migrations", "ar_internal_metadata"].freeze
  attr_reader :table, :column, :suggestion

  class << self
    def all
      @all ||= find_and_create
    end

    def find_and_create
      relevant_tables.map do |table|
        connection.columns(table).map do |column|
          rec = recommended_comment(column)
          rec ? new(table: table, column: column, suggestion: rec) : nil
        end.compact
      end.compact.flatten
    end
  end

  def initialize(table:, column:, suggestion:)
    @table = table
    @column = column
    @suggestion = suggestion
  end


  private
    def self.connection
      ActiveRecord::Base.connection
    end

    def self.relevant_tables
      connection.tables - INGORE_TABLES
    end
end
