require 'pii-safe-schema/annotations'
require 'pii-safe-schema/schema'
require 'active_record'
require 'active_record/schema_dumper'
require 'json'
require 'pry'

module PiiSafeSchema
  def self.activate!
    ActiveSupport.on_load :active_record do
      PiiSafeSchema::Notify.notify_all(PiiSafeSchema::PiiColumns.all)
    end
  end
end

