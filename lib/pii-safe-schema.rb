require 'pii-safe-schema/annotations'
require 'pii-safe-schema/notify'
require 'pii-safe-schema/pii-column'
require 'pii-safe-schema/version'
require 'pii-safe-schema/notifiers/std_out'
require 'active_record'
require 'active_record/schema_dumper'
require 'json'
require 'pry'

module PiiSafeSchema
  extend PiiSafeSchema::Notify
  def self.activate!
    ActiveSupport.on_load :active_record do
      Notify.notify(PiiSafeSchema::PiiColumn.all)
    end
  end
end
