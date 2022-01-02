# frozen_string_literal: true

require File.expand_path(
  File.join('..', 'lib', 'omniauth', 'seznam_cz', 'version'),
  __FILE__
)

Gem::Specification.new do |gem|
  gem.name          = 'omniauth-seznam-cz'
  gem.version       = OmniAuth::SeznamCz::VERSION
  gem.license       = 'MIT'
  gem.summary       = %(A Seznam.cz strategy for OmniAuth)
  gem.description   = %(A Seznam.cz strategy for OmniAuth. This allows you to login via Seznam.cz with your ruby app.)
  gem.authors       = ['Jan Sterba']
  gem.email         = ['info@jansterba.com']
  gem.homepage      = 'https://github.com/honzasterba/omniauth-seznam-cz'

  gem.files         = `git ls-files`.split("\n")
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 2.7'

  gem.add_runtime_dependency 'oauth2', '~> 1.1'
  gem.add_runtime_dependency 'omniauth', '~> 2.0'
  gem.add_runtime_dependency 'omniauth-oauth2', '~> 1.7.1'

  gem.add_development_dependency 'rake', '~> 12.0'
  gem.add_development_dependency 'rspec', '~> 3.6'
  gem.add_development_dependency 'rubocop', '~> 0.49'
end
