require 'optparse'

module VagrantAWS
  module Command
    class SSHConfig < Vagrant::Command::Base   
      def execute

        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant aws ssh_config [vm-name] [-e command] [-h]"
          opts.separator ""
        end

        # Parse the options
        opts.on("-n", "--host_name", "The name to use for this host in the ssh config file (defaults to 'vagrant')") do |n|
          options[:host_name] = n
        end

        argv = parse_options(opts)

        raise Vagrant::Errors::MultiVMTargetRequired, :command => "ssh" if target_vms(argv).length > 1


        @logger.debug("AWS SSHConfig command: #{argv.inspect} #{options.inspect}")
        ssh_vm = target_vms(argv).first

        raise Vagrant::Errors::VMNotCreatedError if !ssh_vm.created?
        ssh_vm.env.actions.run(VagrantAWS::Action::PopulateSSH)
  
        $stdout.puts(Vagrant::Util::TemplateRenderer.render("ssh_config", {
          :host_key => options[:host_name] || "vagrant",
          :ssh_host => ssh_vm.env.config.ssh.host,
          :ssh_user => ssh_vm.env.config.ssh.username,
          :ssh_port => ssh_vm.ssh.port,
          :private_key_path => ssh_vm.env.config.ssh.private_key_path
        }))

        0 # We were successful
      end
    end
  end
end
