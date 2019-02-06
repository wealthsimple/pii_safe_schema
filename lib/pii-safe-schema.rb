require 'pii-safe-schema/annotations'
require 'pii-safe-schema/notify'
require 'pii-safe-schema/pii-column'
require 'pii-safe-schema/version'
require 'pii-safe-schema/notifiers/std_out'
require 'active_record'
require 'pii-safe-schema/paths'
require 'pii-safe-schema/railtie'
require "rails/generators"
require "rails/generators/active_record/migration/migration_generator"
require 'pii-safe-schema/migration-generator'
require 'json'
require 'pry'

module PiiSafeSchema
  extend PiiSafeSchema::Notify
  def self.activate!
    ActiveSupport.on_load :active_record do
      Notify.notify(PiiSafeSchema::PiiColumn.all)
    end
  end

  def self.generate_migrations
    PiiSafeSchema::MigrationGenerator.generate_migrations(PiiSafeSchema::PiiColumn.all)
  end
end
