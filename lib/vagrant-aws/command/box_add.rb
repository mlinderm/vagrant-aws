require 'optparse'

module VagrantAWS
  module Command
    class BoxAdd < Vagrant::Command::Base   
      def execute

        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant aws box_add <name> <uri> [-h]"
          opts.separator ""
        end

        # Parse the options
        argv = parse_options(opts)

        @logger.debug("AWS BoxAdd command: #{argv.inspect} #{options.inspect}")

        Box.add(env, opts[:name], opts[:uri])
      end
    end
  end
end
