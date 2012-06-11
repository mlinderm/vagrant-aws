require 'optparse'

module VagrantAWS
  module Command
    class Provision < Vagrant::Command::Base   
      def execute

        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant aws provision [vm-name] [-h]"
          opts.separator ""
        end

        # Parse the options
        argv = parse_options(opts)

        @logger.debug("AWS Provision command: #{argv.inspect} #{options.inspect}")
        with_target_vms(argv) do |vm|
          if vm.created?
            vm.env.actions.run(:aws_provision)
          else
            vm.env.ui.info I18n.t("vagrant.commands.common.vm_not_created")
          end
        end

        0 # We were successful
      end
    end
  end
end
