# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "is24/version"

Gem::Specification.new do |s|
  s.name        = "is24"
  s.version     = Is24::VERSION
  s.authors     = ["Bernd Suenkel"]
  s.email       = ["bernd@bnerd.de"]
  s.homepage    = "http://github.com/bnerd/is24"
  s.summary     = %q{Ruby API Client for Immobilienscout24.}
  s.description = %q{Simple Ruby API Client for Immobilienscout24.}

  s.files         = Dir["{lib}/**/*"] + ["LICENSE.txt", "Rakefile", "README.md"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency 'multi_json'
  s.add_runtime_dependency 'hashie'
  s.add_runtime_dependency 'faraday'
  s.add_runtime_dependency 'faraday_middleware'
  s.add_runtime_dependency 'simple_oauth'
end
