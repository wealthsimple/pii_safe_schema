module PiiSafeSchema::Paths
  PROJECT_PATH = File.join(File.dirname(__FILE__), '..').freeze
  ASSETS_PATH = File.join(PROJECT_PATH, '/assets').freeze
  ANNOTATION_FILE_PATH = File.join(ASSETS_PATH, 'annotations.json').freeze
end
