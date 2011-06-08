module VagrantAWS
	# A configuration class to configure defaults which are used for
  # the `vagrant-aws` plugin.
  class Config < Vagrant::Config::Base
    configures :aws
   
		attr_accessor :aws_access_key_id
		attr_accessor :aws_secret_access_key

		attr_accessor :ssh_key_name
		attr_accessor :identity_file
		attr_accessor :ssh_user
		attr_accessor :security_groups

		attr_accessor :image
		attr_accessor :flavor

		attr_accessor :region
		attr_accessor :availability_zone

		def initialize
			@ssh_user = "root"
			@security_groups = ["default"]
			@region = "us-east-1"
			@availability_zone = "us-east-1b"
			@flavor = "t1.micro"

			@aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
			@aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
		end

	end
end	
