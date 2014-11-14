# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rope/version"

Gem::Specification.new do |s|
  s.name        = "basic-rope"
  s.version     = Rope::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andy Lindeman", "Logan Bowers"]
  s.email       = ["alindeman@gmail.com", "logan@datacurrent.com"]
  s.homepage    = "http://rubygems.org/gems/basic-rope"
  s.summary     = %q{Pure Ruby implementation of a Rope data structure}
  s.description = %q{A Rope is a convenient data structure for manipulating large amounts of text.  This implementation is inspired by http://www.rubyquiz.com/quiz137.html and https://rubygems.org/gems/cord. Basic-rope is a fork of Andy Lindeman's original rope gem to generalize the rope data structure to work with any data type that has a length and supports slice(). }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "rdoc"
end
