# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "vagrant-aws/version"

Gem::Specification.new do |s|
  s.name        = "vagrant-aws"
  s.version     = VagrantAWS::VERSION
  s.authors     = ["Michael Linderman"]
  s.email       = ["michael.d.linderman@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A vagrant plugin for working with AWS}
  s.description = %q{A vagrant plugin for working with AWS}

  s.rubyforge_project = "vagrant-aws"

	s.add_dependency "vagrant", ">= 0.6.0"
	s.add_dependency "fog"
	s.add_dependency "archive-tar-minitar", ">= 0.5.2"
	s.add_dependency "macaddr", "~> 1.0.0"

  s.add_development_dependency "bundler", ">= 1.0.0"
	s.add_development_dependency "contest", "~> 0.1.3"
	s.add_development_dependency "mocha", "~> 0.9.8"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_path  = "lib"
end
