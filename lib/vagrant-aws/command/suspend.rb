require 'optparse'

module VagrantAWS
  module Command
    class Suspend < Vagrant::Command::Base   
      def execute

        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant aws suspend [vm-name] [-h]"
          opts.separator ""
        end

        # Parse the options
        argv = parse_options(opts)

        @logger.debug("AWS Suspend command: #{argv.inspect} #{options.inspect}")
        with_target_vms(argv) do |vm|
          if vm.created?
            vm.env.actions.run(:aws_suspend)
          else
            vm.env.ui.info I18n.t("vagrant.commands.common.vm_not_created")
          end
        end

        0 # We were successful
      end
    end
  end
end
