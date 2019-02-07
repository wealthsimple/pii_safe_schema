class PiiSafeSchema::PiiColumn
  extend PiiSafeSchema::Annotations
  attr_reader :table, :column, :suggestion

  def self.all
    @all ||= find_and_create
  end

  def initialize(table:, column:, suggestion:)
    @table = table.to_sym
    @column = column
    @suggestion = suggestion
  end


  private

    class << self
      def find_and_create
        relevant_tables.map do |table|
          connection.columns(table).map do |column|
            next if ignored_column?(table, column)
            rec = recommended_comment(column)
            rec ? new(table: table, column: column, suggestion: rec) : nil
          end.compact
        end.compact.flatten
      end

      def connection
        ActiveRecord::Base.connection
      end

      def relevant_tables
        connection.tables - PiiSafeSchema.configuration.ignore_tables
      end

      def ignored_column?(table, column)
        PiiSafeSchema.configuration
                     .ignore_columns[table.to_sym]
                     &.include?(column.name.to_sym)
      end
    end
end
