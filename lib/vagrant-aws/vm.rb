require 'fog'

# Patch required by Vagrant::System
module Fog
	module Compute
		class Server < Fog::Model
			def running?
				state == "running"
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
				pp vm
        my_vm = new(name, env)
        my_vm.vm = vm
		
				# Recover key configuration values from data store not available from AWS directly
				unless my_vm.env.nil?
					my_vm.config.aws.region = desc['region']
				end
				
				my_vm
      end
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
				:region   => region || config.aws.region || nil
			)

		end
	end
end
