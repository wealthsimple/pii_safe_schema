require 'simplecov'
SimpleCov.start
require 'bundler/setup'
Bundler.require(:default)
require 'pii-safe-schema'
require 'rspec'
require 'rspec/collection_matchers'
require 'rspec/its'
require 'active_record'
require 'sample_migrations'
require 'datadog/statsd'

ActiveRecord::Base.establish_connection('postgres://localhost/pii_safe_schema_test')
ActiveRecord::Base.logger = ActiveSupport::Logger.new($stdout) if ENV['VERBOSE']

def connection
  @connection ||= ActiveRecord::Base.connection
end

def migrate(migration, direction: :up)
  ActiveRecord::Migration.suppress_messages do
    migration.migrate(direction)
  end
  true
end

TestSchema = ActiveRecord::Schema

def clean_db
  connection.tables.each do |table|
    connection.drop_table(table, force: true)
  end
  migrate(CreateTables)
end

def remove_migration_files
  FileUtils.rm_rf('db')
end

RSpec.configure do |config|
  config.before(:each) do
    clean_db
  end

  config.after(:each) do
    remove_migration_files
  end
end

def find_column(columns, table_name, column_name)
  columns.find do |pc|
    pc.table == table_name && pc.column.name == column_name
  end
end
