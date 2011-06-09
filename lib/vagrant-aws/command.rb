require 'fog'

module VagrantAWS
	class AWSCommands < Vagrant::Command::GroupBase		
		register "aws", "Commands to interact with Amazon AWS (EC2)"

		def initialize(*args)
			super
			initialize_aws_environment(*args)
		end


		desc "up [NAME]", "Creates the Vagrant environment on Amazon AWS."
		method_options :provision => true
		def up(name=nil)
			raise Errors::KeyNameNotSpecified if @env.config.aws.key_name.nil?

			target_vms(name).each do |vm|				
				if vm.created?
					raise VagrantAWS::Errors::NotYetSupported
					vm.env.ui.info I18n.t("vagrant.commands.up.vm_created")
					#vm.start("provision.enabled" => options[:provision])
				else
					vm.env.actions.run(:aws_up, "provision.enabled" => options[:provision])
				end
			end
		end


		desc "destroy [NAME]", "Destroy the Vagrant AWS environment, terminating the created virtual machines."
		def destroy(name=nil)
			target_vms(name).each do |vm|
				if vm.created?
					vm.env.actions.run(:aws_destroy)
				else
					vm.env.ui.info I18n.t("vagrant.commands.common.vm_not_created")
				end
			end
		end


		desc "status", "Show the status of the current Vagrant AWS environment." 
		def status
			state = nil
			results = target_vms.collect do |vm|
				state = vm.created? ? vm.vm.state.to_s : 'not_created'
				"#{vm.name.to_s.ljust(25)}#{state.gsub("_", " ")}"	
			end
			state = target_vms.length == 1 ? state : "listing"
			@env.ui.info(I18n.t("vagrant.commands.status.output",
                    :states  => results.join("\n"),
                    :message => I18n.t("vagrant.plugins.aws.commands.status.#{state}")),
                    :prefix  => false)
		end


		desc "ssh [NAME]", "SSH into the currently running Vagrant AWS environment."
		method_options %w( execute -e ) => :string
		def ssh(name=nil)
			raise Errors::MultiVMTargetRequired, :command => "ssh" if target_vms.length > 1
			
			ssh_vm = target_vms.first
			ssh_vm.env.actions.run(VagrantAWS::Action::PopulateSSH)

			if options[:execute]
				ssh_vm.ssh.execute do |ssh|
          ssh_vm.env.ui.info I18n.t("vagrant.commands.ssh.execute", :command => options[:execute])
          ssh.exec!(options[:execute]) do |channel, type, data|
            ssh_vm.env.ui.info "#{data}"
          end
        end
			else
				raise Errors::VMNotCreatedError if !ssh_vm.created?
        raise Errors::VMNotRunningError if !ssh_vm.vm.ready?
        ssh_vm.ssh.connect 
			end	
		end


		desc "provision [NAME]", "Rerun the provisioning scripts on a running VM."
		def provision(name=nil)
			target_vms(name).each do |vm|
				if vm.created? && vm.vm.state == 'running'
					vm.env.actions.run(:aws_provision)
				else
					vm.env.ui.info I18n.t("vagrant.commands.common.vm_not_created")
				end
      end
    end
		

		desc "suspend [NAME]", "Suspend a running Vagrant AWS environment"
		def suspend(name=nil)
			target_vms(name).each do |vm|
				if vm.created?
					vm.env.actions.run(:aws_suspend)
				else
					vm.env.ui.info I18n.t("vagrant.commands.common.vm_not_created")
				end
			end	
		end


		desc "resume [NAME]", "Resume a suspended Vagrant AWS environment"
		def resume(name=nil)
			target_vms(name).each do |vm|
				if vm.created?
					vm.env.actions.run(:aws_resume)
				else
					vm.env.ui.info I18n.t("vagrant.commands.common.vm_not_created")
				end
			end	
		end


		desc "ssh_config [NAME]", "outputs .ssh/config valid syntax for connecting to this environment via ssh"
		method_options %w{ host_name -h } => :string
		def ssh_config(name=nil)
			raise Errors::MultiVMTargetRequired, :command => "ssh_config" if target_vms.length > 1

			ssh_vm = target_vms.first
			ssh_vm.env.actions.run(VagrantAWS::Action::PopulateSSH)
	
			$stdout.puts(Vagrant::Util::TemplateRenderer.render("ssh_config", {
        :host_key => options[:host] || "vagrant",
        :ssh_host => ssh_vm.env.config.ssh.host,
				:ssh_user => ssh_vm.env.config.ssh.username,
				:ssh_port => ssh_vm.ssh.port,
				:private_key_path => ssh_vm.env.config.ssh.private_key_path
      }))
		end

		protected
	
		# Reinitialize "AWS" environment
		def initialize_aws_environment(args, options, config)
			raise Errors::CLIMissingEnvironment if !config[:env]
			@env = VagrantAWS::Environment.new
			@env.ui = config[:env].ui  # Touch up UI 
			@env.load!
		end


	end	
end
