module VagrantAWS
	class Action
		class PopulateSSH
			def initialize(app, env)
				@app = app
			end

			def call(env)
				raise VagrantAWS::Errors::PrivateKeyFileNotSpecified if env["config"].aws.private_key_path.nil?

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
	
		end
	end
end


