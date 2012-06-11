require 'optparse'

module VagrantAWS
  module Command
    class SSH < Vagrant::Command::Base   
      def execute

        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant aws ssh [vm-name] [-e command] [-h]"
          opts.separator ""
        end

        # Parse the options
        opts.on("-e", "--execute", "Execute the specified command on the target vm.") do |e|
          options[:execute] = e
        end

        argv = parse_options(opts)

        raise Vagrant::Errors::MultiVMTargetRequired, :command => "ssh" if target_vms(argv).length > 1


        @logger.debug("AWS SSH command: #{argv.inspect} #{options.inspect}")
        ssh_vm = target_vms(argv).first
        ssh_vm.env.actions.run(VagrantAWS::Action::PopulateSSH)

        if options[:execute]
          ssh_vm.ssh.execute do |ssh|
            ssh_vm.env.ui.info I18n.t("vagrant.commands.ssh.execute", :command => options[:execute])
            ssh.exec!(options[:execute]) do |channel, type, data|
              ssh_vm.env.ui.info "#{data}"
            end
          end
        else
          raise Vagrant::Errors::VMNotCreatedError if !ssh_vm.created?
          raise Vagrant::Errors::VMNotRunningError if !ssh_vm.vm.running?
          ssh_vm.ssh.connect 
        end 

        0 # We were successful
      end
    end
  end
end
