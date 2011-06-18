require 'test/unit'
require 'contest'
require 'mocha'
require 'vagrant-aws'

Fog.mock!

module Vagrant
	module TestHelpers

		# Creates and _loads_ a Vagrant environment at the given path.
    # If no path is given, then a default {#vagrantfile} is used.
    def vagrant_env(*args)
      path = args.shift if Pathname === args.first
      path ||= vagrantfile
      VagrantAWS::Environment.new(:cwd => path).load!
    end
		
	end
end

class Test::Unit::TestCase
  include Vagrant::TestHelpers
end
