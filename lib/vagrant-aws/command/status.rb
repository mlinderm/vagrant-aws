require 'optparse'

module VagrantAWS
  module Command
    class Status < Vagrant::Command::Base   
      def execute

        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant aws status [vm-name] [-h]"
          opts.separator ""
        end

        # Parse the options
        argv = parse_options(opts)

        @logger.debug("AWS Status command: #{argv.inspect} #{options.inspect}")

        state = nil
        results = target_vms(argv).collect do |vm|
          state = vm.created? ? vm.vm.state.to_s : 'not_created'
          "#{vm.name.to_s.ljust(25)}#{state.gsub("_", " ")}"  
        end

        state = target_vms(argv).length == 1 ? state : "listing"
        @env.ui.info(I18n.t("vagrant.commands.status.output",
                      :states  => results.join("\n"),
                      :message => I18n.t("vagrant.plugins.aws.commands.status.#{state}")),
                      :prefix  => false)


        0 # We were successful
      end
    end
  end
end
