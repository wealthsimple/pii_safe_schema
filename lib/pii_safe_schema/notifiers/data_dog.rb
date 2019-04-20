module PiiSafeSchema
  module Notify
    module DataDog
      # deprecated
      KNOWN_CLIENTS = PiiSafeSchema::Configuration::KNOWN_DD_CLIENTS

      class << self
        def deliver(pii_column)
          return unless %w[staging production development].include?(Rails.env)
          return if datadog_client.nil?

          datadog_client.event(
            'PII Annotation Warning',
            message(pii_column),
            msg_title: 'Unannotated PII Column',
            alert_type: 'warning',
          )
        end

        private

        def message(pii_column)
          "column #{pii_column.table}.#{pii_column.column.name} is not annotated"
        end

        def datadog_client
          PiiSafeSchema.configuration.datadog_client
        end
      end
    end
  end
end
