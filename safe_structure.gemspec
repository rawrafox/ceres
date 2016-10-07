# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'safe_structure/version'

Gem::Specification.new do |spec|
  spec.name          = 'safe_structure'
  spec.version       = SafeStructure::VERSION
  spec.authors       = ['Aurora']
  spec.email         = ['aurora@aventine.se']

  spec.summary       = %q{A typesafe (mostly immutable) structure type.}
  spec.homepage      = 'https://github.com/rawrasaur/safe_structure'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.12.0'
end
