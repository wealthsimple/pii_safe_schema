require 'pii_safe_schema/invalid_column_error'
require 'pii_safe_schema/configuration'
require 'pii_safe_schema/annotations'
require 'pii_safe_schema/notify'
require 'pii_safe_schema/pii_column'
require 'pii_safe_schema/version'
require 'pii_safe_schema/notifiers/std_out'
require 'pii_safe_schema/notifiers/data_dog'
require 'pii_safe_schema/railtie'
require 'rails/generators'
require 'rails/generators/active_record/migration/migration_generator'
require 'pii_safe_schema/migration_generator'
require 'json'

module PiiSafeSchema
  extend PiiSafeSchema::Notify

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset_configuration!
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.activate!
    return if Rails.env.test?

    ActiveSupport.on_load :active_record do
      Notify.notify(PiiSafeSchema::PiiColumn.all)
    end
  rescue ActiveRecord::NoDatabaseError
    Rails.logger.info('PiiSafeSchema: No DB'.red)
  end

  def self.generate_migrations(additional_pii_columns = [])
    PiiSafeSchema::MigrationGenerator.generate_migrations(
      PiiSafeSchema::PiiColumn.all + additional_pii_columns,
    )
  end

  def self.parse_additional_columns(arguments)
    arguments.map do |str|
      matches = /([a-z_]+):([a-z_]+):([a-z_]+)/i.match(str)
      print_help! if matches.blank?

      suggestion = Annotations.comment(matches[3])
      print_help! if suggestion.blank?

      PiiColumn.from_column_name(table: matches[1], column: matches[2], suggestion: suggestion)
    end
  end

  def self.print_help!(exit: true)
    puts <<~HELPMSG
  Usage:
    rake pii_safe_schema:generate_migrations [table:column:annotation_type] ...

  Arguments:
    [table:column:annotation_type]   # A column to manually annotate. Can be repeated.
                                     # annotation_type can be "email", "phone", "ip_address",
                                     # "geolocation", "address", "postal_code", "name",
                                     # "sensitive_data", or "encrypted_data"

  Description:
    Generates a migration to add PII annotation comments to appropriate columns on a table.
    Uses a series of regular expressions to find sensitive fields.

    Optionally supply arguments to annotate columns explicitly

  Example:
    rake pii_safe_schema:generate_migrations signatures:signatory_name:name signatures:landline:phone

    Will generate a migration with the following, assuming automatic regex had no matches:

    class ChangeCommentsInSignatures < ActiveRecord::Migration[5.2]
      def change
        safety_assured do
          change_column :signatures, :signatory_name, :string, comment: '{"pii":{"obfuscate":"name_obfuscator"}}'
          change_column :signatures, :landline, :string, comment: '{"pii":{"obfuscate":"phone_obfuscator"}}'
        end
      end
    end
    HELPMSG

    exit(1) if exit
  end
end
