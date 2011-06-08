require 'fog'
require 'ruby-debug'

module VagrantAWS
	class AWSCommands < Vagrant::Command::GroupBase		
		DEFAULT_DOTFILE = ".vagrantaws"
		
		register "aws", "Commands to interact with Amazon AWS (EC2)"

		desc "up", "Creates the Vagrant environment on EC2"
		method_options %w( ssh-key -S) => :string
		method_options %w( ssh-user -x) => :string
		method_options %w( identity-file -i) => :string
		method_options %w( image -I ) => :string
		def up
			target_vms.each do |vm| 
				server = create_server( vm.name, vm.env.config.aws, options )
			
				# Persist server information to the local store
				local_data[:active] ||= {}
				local_data[:active][vm.name.to_s] = {
					:id => server.id,
					:username => server.username,
					:private_key_path => server.private_key_path
				}
				local_data.commit
			end
		end

		desc "destroy", "Destroy the environment, deleting the created virtual machines"
		def destroy
			target_vms.each do |vm|
				if vm_created?(vm.name)
					destroy_server( vm.name, vm.env.config.aws, options )
					local_data[:active].delete(vm.name.to_s)
				else
					env.ui.info "VM not created"
				end
			end
		end

		protected

		# Maintain distinct and non-conflicting local data store

		def dotfile_path
			env.root_path.join(DEFAULT_DOTFILE) rescue nil
		end

		def local_data
			@local_data ||= Vagrant::DataStore.new(dotfile_path)
		end

		# Server creation and manipulation

		def vm_created?(name)
			local_data[:active] && local_data[:active].has_key?(name.to_s)
		end

		def server_definition(config, options)
			{
				:image_id  => options["image"] || config.image,
				:groups    => config.security_groups,
				:flavor_id => config.flavor,
				:key_name  => options["ssh-key"] || config.ssh_key_name,
				:username  => options["ssh-user"] || config.ssh_user,
				:private_key_path  => options["identity-file"] || config.identity_file,
				:availability_zone => config.availability_zone
			}
		end

		def create_server(name, config, options)
			connection = Fog::Compute.new(
				:provider => 'AWS',
				:aws_access_key_id     => config.aws_access_key_id, 
				:aws_secret_access_key => config.aws_secret_access_key, 
				:region => options["region"] || config.region
			)
		
			server_def = server_definition(config, options)

			ami = connection.images.get(server_def[:image_id])
		
			server = connection.servers.create(server_def)
			
			config.env.ui.info("Created EC2 Server -- Instance ID: #{server.id}")
			config.env.ui.info("Waiting for server to become ready...")

			connection.create_tags(server.id, { "name" => name })
			server.wait_for { ready? }

			config.env.ui.info("Server DNS: #{server.dns_name}")

			# TODO: Bootstrap server node

			server
		end

		def destroy_server(name, config, options)
			connection = Fog::Compute.new(
				:provider => 'AWS',
				:aws_access_key_id     => config.aws_access_key_id, 
				:aws_secret_access_key => config.aws_secret_access_key, 
				:region => options["region"] || config.region
			)
			connection.servers.get(local_data[:active][name.to_s]['id']).destroy
		end

		class FogError < Vagrant::Errors::VagrantError
			def initialize(message=nil, *args)
				super
			end
		end

	end	
end
