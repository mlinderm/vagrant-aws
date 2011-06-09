# vagrant-aws

`vagrant-aws` is a plugin for [Vagrant](http://vagrantup.com) which allows the user
to instantiate the Vagrant environment on Amazon AWS (using EC2). This document assumes
you are familiar with Vagrant, if not, the project has excellent [documentation](http://vagrantup.com/docs/index.html).

**NOTE:** This plugin is "pre-alpha", see below for the caveats

## Installing / Getting Started

To use this plugin, first install Vagrant, then install the plugin gem. It should be
picked up automatically by vagrant. You can then use the `vagrant aws` commands.

`vagrant-aws` uses [fog](https://github.com/geemus/fog) internally, and you will need to
specify your Amazon AWS credentials in a "fog" file. Create `~/.fog` with:

	---
	default: 
		aws_access_key_id:  <YOUR ACCESS KEY>
		aws_secret_access_key: <YOUR SECRET KEY>

Additionally, although `vagrant-aws` has many useful defaults, you will need to specify your
Amazon AWS key name and the path the associated private key. You can specify this on a
per-environment basis (i.e., in each Vagrantfile) or in a single Vagrantfile in your
`~/.vagrant` directory. In the latter case, create `~/.vagrant/Vagrantfile` with:

	Vagrant::Config.run do |config|
		config.aws.key_name = "<KEY NAME>"
		config.aws.private_key_path = "<PATH/TO/KEY>"
	end
	
With the above in place you should be ready instantiate your Vagrant environment on 
Amazon AWS. See below for additional information on configuration, caveats, etc..

## Configuration

`vagrant-aws` defines a new configuration class for use in your Vagrantfile. An example
usage (showing the defaults) would be:

	Vagrant::Config.run do |config|
		config.aws.region = "us-east-1"
		config.aws.availability_zone = nil  # Let AWS choose
		config.aws.image = "ami-2ec83147"   # EBS-backed Ubuntu 10.04 64-bit
		config.aws.username = "ubuntu"
		config.aws.security_groups = ["default"]
		config.aws.flavor = "t1.micro"
	end

## Caveats

`vagrant-aws` is "pre-alpha" and currently only supports creation, suspension, resumption
and descruction of the Vagrant environment. Provisioning should be supported for shell,
chef-server and chef-solo, but has only been tested with chef-solo and on an Ubuntu guest. 
Only a subset of Vagrant features are supported. Currently port forwarding and shared 
directories are not implemented, nor is host networking (although that is less relevant for AWS). 
`vagrant-aws` in general has only been tested for a single VM, on OSX 10.6, with chef-solo.
	
