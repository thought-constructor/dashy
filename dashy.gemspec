# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dashy/version"

Gem::Specification.new do |s|
  s.name        = "dashy"
  s.version     = Dashy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alex Goldsmith"]
  s.email       = ["alex.tosyx@gmail.com"]
  s.license     = "MIT"
  s.homepage    = "https://github.com/tosyx/dashy"
  s.summary     = "Selector combinators and other helpers for Sass."
  s.description = <<-DESC
Dashy provides...
  DESC

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('sass', '~> 3.3')
  s.add_dependency('thor')

  s.add_development_dependency('aruba', '~> 0.4')
  s.add_development_dependency('rake')
end

# Gem structure adapted from thoughtbot/bourbon...
