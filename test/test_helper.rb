require 'test/unit'
require 'contest'
require 'mocha'
require 'vagrant-aws'

Fog.mock!

module Vagrant
	module TestHelpers

    # Override tmp_path so we can keep our artifacts in our own tree
    def tmp_path
      result = VagrantAWS.source_root.join("test", "tmp")
      FileUtils.mkdir_p(result)
      result
    end

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
