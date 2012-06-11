require 'optparse'

module VagrantAWS
  module Command
    class Up < Vagrant::Command::Base   
      def execute

        options = {:provision => true}

        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant aws up [vm-name] [--provision] [-h]"
          opts.separator ""

          opts.on("-p", "--provision", "Overwrite an existing box if it exists.") do |p|
            options[:provision] = p
          end
        end

        # Parse the options
        argv = parse_options(opts)

        @logger.debug("AWS Up command: #{argv.inspect} #{options.inspect}")
        with_target_vms(argv) do |vm|
          if vm.created?
            vm.env.ui.info I18n.t("vagrant.commands.up.vm_created")
          else
            vm.env.action_runner.run(:aws_up, "provision.enabled" => options[:provision])
          end
        end

        0 # We were successful
      end
    end
  end
end
