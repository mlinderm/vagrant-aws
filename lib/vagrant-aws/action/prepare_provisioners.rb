require 'archive/tar/minitar'

module VagrantAWS
	module Action
		class PrepareProvisioners
			def initialize(app, env)
				@app = app
				@env = env
				@env["provision.enabled"] = true if !@env.has_key?("provision.enabled")
				@provisioner_configs = []

				load_provisioner_configs if provisioning_enabled?
			end

			def call(env)
				@provisioner_configs.each do |provisioner_config|
					if provisioner_config.is_a?(Vagrant::Provisioners::ChefSolo::Config)
						env.ui.info I18n.t("vagrant.plugins.aws.actions.prepare_provisioners.uploading_chef_resources")
						ChefSolo.prepare(provisioner_config)
					end
				end
				@app.call(env)
			end
	
			def provisioning_enabled?
        !@env["config"].vm.provisioners.empty? && @env["provision.enabled"]
      end

			def load_provisioner_configs
				@env["config"].vm.provisioners.each do |provisioner|
					@provisioner_configs << provisioner.config
				end
			end
		
			class ChefSolo
				
				def self.prepare(config)
					my_preparer = new(config)
					my_preparer.bootstrap_if_needed
					my_preparer.chown_provisioning_folder
					my_preparer.copy_and_update_paths	
				end

				def initialize(config)
					@config = config
				end

				def bootstrap_if_needed
					begin
						@config.env.vm.ssh.execute do |ssh|
							ssh.sudo!("which chef-solo")
						end
					rescue Vagrant::Errors::VagrantError 
						# Bootstrap chef-solo
						@config.env.ui.info I18n.t("vagrant.plugins.aws.actions.prepare_provisioners.chef_not_detected", :binary => "chef-solo")
						@config.env.vm.system.bootstrap_chef
					end
				end


				def chown_provisioning_folder
					@config.env.vm.ssh.execute do |ssh|
						ssh.sudo!("mkdir -p #{@config.provisioning_path}")
						ssh.sudo!("chown #{@config.env.config.ssh.username} #{@config.provisioning_path}")
					end
				end

				def copy_and_update_paths
					# Copy relevant host paths to remote instance and update provisioner config
					# to point to new "vm" paths for cookbooks, etc.
					%w{ cookbooks_path roles_path data_bags_path }.each do |path|
						copy_host_paths(@config.send(path), path)
						@config.send "#{path}=", strip_host_paths(@config.send(path)).push([:vm, path])
					end
				end
			
				def copy_host_paths(paths, target_directory)
					archive  = tar_host_folder_paths(paths)
					
					target_d = "#{@config.provisioning_path}/#{target_directory}"
					target_f = target_d + '.tar'
					
					@config.env.vm.ssh.upload!(archive.path, target_f)
					@config.env.vm.ssh.execute do |ssh|
						ssh.sudo!([
							"mkdir -p #{target_d}",
							"chown #{@config.env.config.ssh.username} #{target_d}",
							"tar -C #{target_d} -xf #{target_f}"
						])
					end

					target_directory
				end
					
				def tar_host_folder_paths(paths)
					tarf = Tempfile.new(['vagrant-chef-solo','.tar']) 
					Archive::Tar::Minitar::Output.open(tarf) do |outp|
						host_folder_paths(paths).each do |full_path|
							Dir.chdir(full_path) do |ignored| 
								Dir.glob("**#{File::SEPARATOR}**") { |entry| Archive::Tar::Minitar.pack_file(entry, outp) }
							end
						end
					end
					tarf
				end


				def host_folder_paths(paths)
					paths = [paths] if paths.is_a?(String) || paths.first.is_a?(Symbol)
					paths.inject([]) do |acc, path|
						path = [:host, path] if !path.is_a?(Array)
						type, path = path
						acc << File.expand_path(path, @config.env.root_path) if type == :host
						acc
					end
				end
		
				def strip_host_paths(paths)
					paths = [paths] if paths.is_a?(String) || paths.first.is_a?(Symbol)
					paths.delete_if { |path| !path.is_a?(Array) || path[0] == :host }
				end
			end

		
		end
	end
end
