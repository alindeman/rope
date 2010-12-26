# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rope/version"

Gem::Specification.new do |s|
  s.name        = "rope"
  s.version     = Rope::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andy Lindeman"]
  s.email       = ["alindeman@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/rope"
  s.summary     = %q{Pure Ruby implementation of a Rope data structure}
  s.description = %q{A Rope is a convenient data structure for manipulating large amounts of text.  This implementation is inspired by http://www.rubyquiz.com/quiz137.html and https://rubygems.org/gems/cord}

  s.rubyforge_project = "rope"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", "~>2.3.0"
end
