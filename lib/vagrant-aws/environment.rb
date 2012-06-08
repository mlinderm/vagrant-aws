require 'fog'

module VagrantAWS
	# Represents a single Vagrant environment, overridden to not alias with
	# existing Vagrant data storage, VM implementation, etc.
	class Environment < Vagrant::Environment
		DEFAULT_DOTFILE = ".vagrantaws"
		FOGFILE         = ".fog"

		# Add the aws path to HOME_SUBDIRS
		HOME_SUBDIRS << "aws"

		AWS_SUBDIRS = ["images", "keys"]

		def dotfile_path
			root_path.join(DEFAULT_DOTFILE) rescue nil
		end
	
		def aws_home_path
      home_path.join("aws")
    end
	
		def boxes_path
			aws_home_path.join("images")
		end
	
		def boxes
      @_boxes ||= Vagrant::BoxCollection.new(boxes_path, action_runner)
    end

		def ssh_keys_path
			aws_home_path.join("keys")
		end

		def ssh_keys
			Dir.chdir(ssh_keys_path) { |unused| Dir.entries('.').select { |f| File.file?(f) } }
		end

		# Override to create the child directories of aws/
		def setup_home_path
			super

			AWS_SUBDIRS.each do |dir|
				path = aws_home_path.join(dir)
				next if File.directory?(path)
				
				begin
					@logger.info("Creating: #{dir}")
					FileUtils.mkdir_p(path)
				rescue Errno::EACCES
					raise Errors::HomeDirectoryNotAccessible, :home_path
				end
			end
		end


		def load!
			super
			
			# Setup fog credential path
			project_fog_path = root_path.join(FOGFILE) rescue nil
			Fog.credentials_path = File.expand_path(fogfile_path) if project_fog_path && File.exist?(project_fog_path)

			self
		end

		# Override to create "AWS" VM
		def load_vms!
			result = {}

			# Load the VM UUIDs from the local data store
			(local_data[:active] || {}).each do |name, desc|
				result[name.to_sym] = VagrantAWS::VM.find(desc, self, name.to_sym)
			end

			# For any VMs which aren't created, create a blank VM instance for
			# them
			all_keys = config.vm.defined_vm_keys
			all_keys = [DEFAULT_VM] if all_keys.empty?
			all_keys.each do |name|
				result[name] = VagrantAWS::VM.new(:name => name, :env => self) if !result.has_key?(name)
			end

			result
		end
			
	end
end
