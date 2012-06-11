require 'Macaddr'

module VagrantAWS
	module Action
		class CreateSSHKey
			def initialize(app, env)
				@app = app
			end

			def call(env)
				@env = env
				
				if @env["vm"].config.aws.key_name.nil?	
          # Do we have a previously created key available on AWS?
					key = @env["vm"].connection.key_pairs.all('key-name' => @env["vm"].env.ssh_keys).first
					if key.nil?
						# Create and save key
						key = @env["vm"].connection.key_pairs.create(:name => "vagrantaws_#{Mac.addr.gsub(':','')}")
						env["ui"].info I18n.t("vagrant.plugins.aws.actions.create_ssh_key.created", :name => key.name)	
						File.open(local_key_path(key.name), File::WRONLY|File::TRUNC|File::CREAT, 0600) { |f| f.write(key.private_key) }	
					end
					
					@env["vm"].config.aws.key_name = key.name
					@env["vm"].config.aws.private_key_path = local_key_path(key.name) 
				end

				@app.call(env)
			end

			def local_key_path(name)
				@env["vm"].env.ssh_keys_path.join(name)
			end

		end
	end
end



