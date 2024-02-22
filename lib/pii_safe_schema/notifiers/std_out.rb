require 'colorize'
module PiiSafeSchema
  module Notify
    module StdOut
      class << self
        def deliver(pii_column)
          Rails.logger.info(message(pii_column).red)
        end

        private

        def message(pii_column)
          <<~HEREDOC
            ------------------------------------------------------------------------------------
            Annotation recommended on column:
            #{pii_column.table}.#{pii_column.column.name}: comment: "#{pii_column.suggestion}"

            run `rake pii_safe_schema:generate_migrations`
            to generate all necessary annotation migrations.

            if this column does not contain PII, you can ignore it
            in your PiiSafeSchema configs.
            https://github.com/wealthsimple/pii_safe_schema/blob/master/README.md
            ------------------------------------------------------------------------------------
          HEREDOC
        end
      end
    end
  end
end
