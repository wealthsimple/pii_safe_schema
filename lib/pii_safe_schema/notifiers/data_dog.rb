module PiiSafeSchema::Notify::DataDog
  KNOWN_CLIENTS = %w[DataDogClient Ws::Railway::Datadog].freeze
  def self.deliver(pii_column)
    return unless %w[staging production development].include?(Rails.env)
    return if dog_client.nil?

    dog_client.event('PII Annotation Warning',
                     message(pii_column),
                     msg_title: 'Unannotated PII Column',
                     alert_type: 'warning')
  end

  def self.message(pii_column)
    "column #{pii_column.table}.#{pii_column.column.name} is not annotated"
  end

  def self.dog_client
    KNOWN_CLIENTS.each do |client|
      return client.safe_constantize if defined?(client)
    end
  end
end
