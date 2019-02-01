require 'pii-safe-schema/paths'

class PiiSafeSchema::Annotations
  include Singleton
  
  def initialize
    # @column_name_regexp = 
  end

  def annotation_types
    @annotation_types ||= JSON.parse(File.open(Paths::ANNOTATION_FILE_PATH).read)
  end
end
