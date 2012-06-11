require 'vagrant-aws/action/create'
require 'vagrant-aws/action/terminate'
require 'vagrant-aws/action/create_sshkey'
require 'vagrant-aws/action/populate_ssh'
require 'vagrant-aws/action/prepare_provisioners'
require 'vagrant-aws/action/suspend'
require 'vagrant-aws/action/resume'
require 'vagrant-aws/action/create_image'
require 'vagrant-aws/action/deregister_image'

module VagrantAWS

	Vagrant.actions.register :aws_provision, Vagrant::Action::Builder.new do
		use Action::PopulateSSH
		use Action::PrepareProvisioners
		use Vagrant.actions[:provision]
	end

	Vagrant.actions.register :aws_up, Vagrant::Action::Builder.new do
		use Action::CreateSSHKey
		use Action::Create
		use Vagrant.actions[:aws_provision]
	end

	Vagrant.actions.register :aws_destroy, Vagrant::Action::Builder.new do
		use Action::Terminate
	end

	Vagrant.actions.register :aws_suspend, Vagrant::Action::Builder.new do
		use Action::Suspend
	end

	Vagrant.actions.register :aws_resume, Vagrant::Action::Builder.new do
		use Action::Resume
	end

	Vagrant.actions.register :aws_create_image, Vagrant::Action::Builder.new do
		use Action::CreateImage
		use Vagrant::Action::VM::Package
	end

	Vagrant.actions.register :aws_add_image, Vagrant::Action::Builder.new do
		use Vagrant::Action::Box::Download
    use Vagrant::Action::Box::Unpackage
	end

	Vagrant.actions.register :aws_remove_image, Vagrant::Action::Builder.new do
		use Action::DeregisterImage
    use Vagrant::Action::Box::Destroy
	end


end
