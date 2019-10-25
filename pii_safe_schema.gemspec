lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pii_safe_schema/version'

Gem::Specification.new do |s|
  s.name          = 'pii_safe_schema'
  s.version       = PiiSafeSchema::VERSION
  s.authors       = ['Alexi Garrow']
  s.email         = ['agarrow@wealthsimple.com']

  s.summary       = 'Schema migration tool for checking and adding comments on PII columns.'
  s.homepage      = 'https://github.com/wealthsimple/pii_safe_schema'

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '>= 5', '< 7'
  s.add_dependency 'colorize'
  s.add_dependency 'rails', '>= 5', '< 7'

  s.add_development_dependency 'bundler', '>= 1.16'
  s.add_development_dependency 'bundler-audit'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'dogstatsd-ruby'
  s.add_development_dependency 'git'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rails', '>= 5.2.3', '< 7'
  s.add_development_dependency 'rake', '>= 10.0'
  s.add_development_dependency 'rspec', '< 4', '>= 3.0'
  s.add_development_dependency 'rspec-collection_matchers'
  s.add_development_dependency 'rspec-its'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'ws-style'


  # Required by activerecord-safer_migrations
  s.add_development_dependency 'pg', '>= 0.21'
  s.add_development_dependency 'strong_migrations'
end
