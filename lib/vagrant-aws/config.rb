module VagrantAWS
	# A configuration class to configure defaults which are used for
  # the `vagrant-aws` plugin.
  class Config < Vagrant::Config::Base
    configures :aws
   	
		attr_accessor :key_name
		attr_writer :private_key_path
		attr_accessor :username
		attr_accessor :security_groups

		attr_accessor :image
		attr_accessor :flavor

		attr_accessor :region
		attr_accessor :availability_zone

		def initialize
			@security_groups   = ["default"]
			@region            = "us-east-1"
			@username          = "ubuntu"
			@image             = "ami-2ec83147"
			@flavor            = "t1.micro"
		end

		def private_key_path
			@private_key_path.nil? ? nil : File.expand_path(@private_key_path)
		end
		

		def validate(errors)
			errors.add(I18n.t("vagrant.config.ssh.private_key_missing", :path => private_key_path)) if private_key_path && !File.exists?(private_key_path)
		end
	end
end	
