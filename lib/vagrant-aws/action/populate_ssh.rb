module VagrantAWS
	module Action
		class PopulateSSH
			def initialize(app, env)
				@app = app
			end

			def call(env)
				@env = env

				if @env["config"].aws.private_key_path.nil?
					# See if we are using a key vagrant aws generated
					@env["config"].aws.private_key_path = local_key_path(env["vm"].vm.key_name) if env["vm"].vm.key_name =~ /^vagrantaws_[0-9a-f]{12}/
				end
				
				raise VagrantAWS::Errors::PrivateKeyFileNotSpecified if env["config"].aws.private_key_path.nil? || !File.exists?(env["config"].aws.private_key_path)

				env["config"].ssh.host             = env["vm"].vm.dns_name
				env["config"].ssh.username         = env["config"].aws.username
				env["config"].ssh.private_key_path = env["config"].aws.private_key_path
				env["config"].ssh.port             = 22

				# Make sure we can connect
				begin
					env["vm"].vm.wait_for { env["vm"].ssh.up? }
				rescue Fog::Errors::Error
					raise Vagrant::Errors::SSHConnectionRefused
				end

				@app.call(env)
			end
	
			def local_key_path(name)
				@env.env.ssh_keys_path.join(name)
			end

		end
	end
end


