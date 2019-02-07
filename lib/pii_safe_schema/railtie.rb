require 'active_record/railtie'

module PiiSafeSchema
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load 'tasks/pii_safe_schema.rake'
    end
  end
end
