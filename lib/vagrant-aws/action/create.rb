module VagrantAWS
	class Action
		class Create
			def initialize(app, env)
				@app = app
			end

			def call(env)
				raise Errors::KeyNameNotSpecified if env["config"].aws.key_name.nil?
				
				env.ui.info I18n.t("vagrant.plugins.aws.actions.create.creating")

				server_def = server_definition(env["config"])

				# Verify AMI is valid (and in the future enable options specific to EBS-based AMIs)
				image = env["vm"].connection.images.get(server_def[:image_id])
				image.wait_for { state == 'available' }

				env["vm"].vm = env["vm"].connection.servers.create(server_def)
				raise VagrantAWS::Errors::VMCreateFailure if env["vm"].vm.nil? || env["vm"].vm.id.nil?
				
				env.ui.info I18n.t("vagrant.plugins.aws.actions.create.created", :id => env["vm"].vm.id)
								
				env["vm"].vm.wait_for { ready? }
				env["vm"].connection.create_tags(env["vm"].vm.id, { "name" => env["vm"].name })

				env.ui.info I18n.t("vagrant.plugins.aws.actions.create.available", :dns => env["vm"].vm.dns_name)

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

