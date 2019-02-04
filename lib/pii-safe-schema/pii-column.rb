class PiiSafeSchema::PiiColumn
  INGORE_TABLES = ["schema_migrations", "ar_internal_metadata"].freeze
  attr_reader :table, :column, :suggestion

  class << self
    def all
    end

    def find_and_create
      relevant_tables.each do |table|

      end
    end
  end

  def initialize(table:, column:, suggestion:)
  end


  private
    def self.relevant_tables
      ActiveRecord::Base.connection.tables - INGORE_TABLES
    end
end
