require 'optparse'

module VagrantAWS
  module Command
    class BoxRemove < Vagrant::Command::Base   
      def execute

        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant aws box_remove <name> [-d] [-h]"
          opts.separator ""
        end

        opts.on("-d", "--deregister", "Unregister the image with AWS") do |d|
          options[:deregister] = d
        end

        # Parse the options
        argv = parse_options(opts)

        @logger.debug("AWS BoxRemove command: #{argv.inspect} #{options.inspect}")

        b = env.boxes.find(argv)
        raise Vagrant::Errors::BoxNotFound, :name => argv if !b
        b.remove({ 'image.deregister' => options[:deregister] })

        0 # We were successful
      end
    end
  end
end
