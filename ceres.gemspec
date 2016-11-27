# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "ceres/version"

Gem::Specification.new do |spec|
  spec.name = "ceres"
  spec.version = Ceres::VERSION
  spec.authors = ["Aurora"]
  spec.email = ["aurora@aventine.se"]

  spec.summary = "An extension to the ruby standard library."
  spec.homepage = "https://github.com/rawrasaur/ceres"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
