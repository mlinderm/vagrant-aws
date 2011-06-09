require 'vagrant-aws/action/create'
require 'vagrant-aws/action/terminate'
require 'vagrant-aws/action/populate_ssh'
require 'vagrant-aws/action/prepare_provisioners'
require 'vagrant-aws/action/suspend'
require 'vagrant-aws/action/resume'

module VagrantAWS

	Vagrant::Action.register(:aws_provision, Vagrant::Action::Builder.new do
		use Action::PopulateSSH
		use Action::PrepareProvisioners
		use Vagrant::Action[:provision]
	end)

	Vagrant::Action.register(:aws_up, Vagrant::Action::Builder.new do
		use Action::Create
		use Vagrant::Action[:aws_provision]
	end)

	Vagrant::Action.register(:aws_destroy, Vagrant::Action::Builder.new do
		use Action::Terminate
	end)

	Vagrant::Action.register(:aws_suspend, Vagrant::Action::Builder.new do
		use Action::Suspend
	end)

	Vagrant::Action.register(:aws_resume, Vagrant::Action::Builder.new do
		use Action::Resume
	end)


end
