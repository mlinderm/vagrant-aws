module VagrantAWS
	class Action
		class Create
			def initialize(app, env)
				@app = app
			end

			def call(env)
				env.ui.info "Creating VM ..."

				server_def = server_definition(env["config"])

				# Verify AMI is valid (and in the future enable options specific to EBS-based AMIs)
				ami = env["vm"].connection.images.get(server_def[:image_id])

				env["vm"].vm = env["vm"].connection.servers.create(server_def)

				env.ui.info("Created EC2 Server: #{env["vm"].vm.id}")
				env.ui.info("Waiting for server to become ready... (this may take a few minutes)")
				
				env["vm"].vm.wait_for { ready? }
				env["vm"].connection.create_tags(env["vm"].vm.id, { "name" => env["vm"].name })

				env.ui.info("Server available at DNS: #{env["vm"].vm.dns_name}")

				@app.call(env)
			end

			def recover(env)
				if env["vm"].created?
					return if env["vagrant.error"].is_a?(Vagrant::Errors::VagrantError)

					# Interrupted, destroy the VM
					env["actions"].run(:aws_destroy)
				end
			end

			def server_definition(config)
				{
					:image_id  => config.aws.image,
					:groups    => config.aws.security_groups,
					:flavor_id => config.aws.flavor,
					:key_name  => config.aws.key_name,
					:username  => config.aws.username,
					:private_key_path  => config.aws.private_key_path,
					:availability_zone => config.aws.availability_zone
				}
			end

		end
	end
end

