module PiiSafeSchema
  module Notify
    METHODS = %i[StdOut DataDog].freeze
    def self.notify(column_or_columns)
      column_or_columns.each { |c| deliver(c) } if column_or_columns.is_a?(Array)
      deliver(c) if column_or_columns.is_a?(PiiSafeSchema::PiiColumn)
    end

    class << self
      private

      def deliver(pii_column)
        METHODS.each do |m|
          "PiiSafeSchema::Notify::#{m}".constantize.deliver(pii_column)
        end
      end
    end
  end
end
