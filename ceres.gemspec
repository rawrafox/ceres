# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ceres/version'

Gem::Specification.new do |spec|
  spec.name          = 'ceres'
  spec.version       = Ceres::VERSION
  spec.authors       = ['Aurora']
  spec.email         = ['aurora@aventine.se']

  spec.summary       = %q{An extension to the ruby standard library, with (mostly immutable) structured types.}
  spec.homepage      = 'https://github.com/rawrasaur/ceres'

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
