# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'zoho_hub/version'

Gem::Specification.new do |spec|
  spec.name          = 'zoho_hub'
  spec.version       = ZohoHub::VERSION
  spec.authors       = ['Ricardo Otero']
  spec.email         = ['oterosantos@gmail.com']

  spec.summary       = 'Simple gem to connect to Zoho CRM API V2'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/rikas/zoho_hub'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '> 6'
  spec.add_dependency 'addressable', '~> 2.8'
  spec.add_dependency 'faraday', '~> 2.7'
  spec.add_dependency 'faraday-multipart'
  spec.add_dependency 'multi_json', '~> 1.15'
  spec.add_dependency 'rainbow', '~> 3.1'
end
