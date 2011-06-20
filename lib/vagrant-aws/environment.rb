require 'fog'

module VagrantAWS
	# Represents a single Vagrant environment, overridden to not alias with
	# existing Vagrant data storage, VM implementation, etc.
	class Environment < Vagrant::Environment
		DEFAULT_DOTFILE = ".vagrantaws"
		FOGFILE         = ".fog"

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
      return parent.boxes if parent
      @_boxes ||= VagrantAWS::BoxCollection.new(self)
    end
		

		def load!
			super
			
			# Setup fog credential path
			project_fog_path = root_path.join(FOGFILE) rescue nil
			Fog.credentials_path = File.expand_path(fogfile_path) if project_fog_path && File.exist?(project_fog_path)

			self
		end

		# Override to create "AWS" specific directories in 'home_dir'
		def load_home_directory!
			super

			dirs = %w{ images }.map { |d| aws_home_path.join(d) }
			dirs.each do |dir|
				next if File.directory?(dir)
				ui.info I18n.t("vagrant.general.creating_home_dir", :directory => dir)
        FileUtils.mkdir_p(dir)
      end	
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
