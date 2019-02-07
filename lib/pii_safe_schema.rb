require 'pii_safe_schema/configuration'
require 'pii_safe_schema/annotations'
require 'pii_safe_schema/notify'
require 'pii_safe_schema/pii_column'
require 'pii_safe_schema/version'
require 'pii_safe_schema/notifiers/std_out'
require 'pii_safe_schema/paths'
require 'pii_safe_schema/railtie'
require 'rails/generators' if defined?(Rails)
require 'rails/generators/active_record/migration/migration_generator' if defined?(Rails)
require 'pii_safe_schema/migration_generator'
require 'json'
require 'pry'

module PiiSafeSchema
  extend PiiSafeSchema::Notify

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.activate!
    ActiveSupport.on_load :active_record do
      Notify.notify(PiiSafeSchema::PiiColumn.all)
    end
  end

  def self.generate_migrations
    PiiSafeSchema::MigrationGenerator.generate_migrations(PiiSafeSchema::PiiColumn.all)
  end
end
