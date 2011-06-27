require 'fog'

# Patch required by Vagrant::System
module Fog
	module Compute
		class AWS
			class Server < Fog::Model
				def running?
					state == "running"
				end
			end
		end
	end
end


module VagrantAWS
		
	class VM < Vagrant::VM

		[:uuid, :package].each do |method|
			undef_method(method)
		end

		class << self
			def find(desc, env=nil, name=nil)
				env.ui.info I18n.t("vagrant.plugins.aws.general.getting_status") if env
				
				vm = Fog::Compute.new(:provider => 'AWS', :region => desc['region']).servers.get(desc['id'])
				my_vm = new(:vm => vm, :env => env, :name => name)
		
				# Recover key configuration values from data store not available from AWS directly
				unless my_vm.env.nil?
					my_vm.env.config.aws.region = desc['region']
				end
				
				my_vm
      end
    end
				
		# Copied from Vagrant VM, but modified to generate a VagrantAWS::Environment
		def initialize(opts=nil)
      defaults = { :vm => nil, :env => nil, :name => nil }

      opts = defaults.merge(opts || {})

      @vm = opts[:vm]
      @connection = @vm.connection if @vm  # Initialize connection from intialized server
			
			@name = opts[:name]

      if !opts[:env].nil?
        # We have an environment, so we create a new child environment
        # specifically for this VM. This step will load any custom
        # config and such.
        @env = VagrantAWS::Environment.new({
          :cwd => opts[:env].cwd,
          :parent => opts[:env],
          :vm => self
        }).load!

        # Load the associated system.
        load_system!
      end

      @loaded_system_distro = false
    end
	
		def vm=(value)
      @vm = value
      env.local_data[:active] ||= {}

      if value && value.id
        env.local_data[:active][name.to_s] = {
					'id'     => value.id,
					'region' => value.connection.instance_variable_get(:@region)
				}
      else
        env.local_data[:active].delete(name.to_s)
      end

      # Commit the local data so that the next time vagrant is initialized,
      # it realizes the VM exists
      env.local_data.commit
    end
	
		def connection(region = nil)
			@connection ||= Fog::Compute.new(
				:provider => 'AWS',
				:region   => region || env.config.aws.region || nil
			)
		end
	end
end
