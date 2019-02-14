require 'simplecov'
SimpleCov.start
require 'bundler/setup'
Bundler.require(:default)
require 'pii_safe_schema'
require 'rspec'
require 'rspec/collection_matchers'
require 'rspec/its'
require 'active_record'
require 'sample_migrations'
require 'datadog/statsd'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expose_dsl_globally = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

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
