# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mail/mad_mimi/version"

Gem::Specification.new do |s|
  s.name        = "mail-mad_mimi"
  s.version     = Mail::MadMimi::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Grant Hollingworth"]
  s.email       = ["grant@antiflux.org"]
  s.homepage    = "https://github.com/granth/mail-mad_mimi"
  s.summary     = "A Mad Mimi delivery method for the Ruby Mail library, with Rails 3 support."
  s.description = s.summary

  s.rubyforge_project = "mail-mad_mimi"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "madmimi", "~> 1.0.15"
  s.add_runtime_dependency "mail", "~> 2.2"
  s.add_development_dependency "rspec", "~> 2.6"
  s.add_development_dependency "actionmailer", "~> 3.0"
end
