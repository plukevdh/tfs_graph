# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tfs_graph/version'

Gem::Specification.new do |spec|
  spec.name          = "tfs_graph"
  spec.version       = TFSGraph::VERSION
  spec.authors       = ["Luke van der Hoeven"]
  spec.email         = ["hungerandthirst@gmail.com"]
  spec.description   = %q{A library to help cache and fetch TFS data}
  spec.summary       = %q{Simple graph db wrapper for TFS data to various backends}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "ruby_tfs"
  spec.add_dependency "activesupport", '~> 4.0'
  spec.add_dependency 'redis-namespace'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
