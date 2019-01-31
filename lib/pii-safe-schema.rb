require 'active_support'
require 'json'

module PiiSafeSchema
  PROJECT_PATH = File.join(File.dirname(__FILE__), "..")
  ASSETS_PATH = File.join(PROJECT_PATH, "/assets")
  binding.pry
	ANNOTATIONS = JSON.parse( File.open(File.join(ASSETS_PATH), "annotations.json") )
end

