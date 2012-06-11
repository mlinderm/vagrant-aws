require 'optparse'

module VagrantAWS
  module Command
    class BoxList < Vagrant::Command::Base   
      def execute

        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant aws box_list [-h]"
          opts.separator ""
        end

        # Parse the options
        argv = parse_options(opts)

        @logger.debug("AWS BoxAdd command: #{argv.inspect} #{options.inspect}")

        boxes = env.boxes.sort
        return env.ui.warn(I18n.t("vagrant.commands.box.no_installed_boxes"), :prefix => false) if boxes.empty?
        boxes.each { |b| env.ui.info(b.name, :prefix => false) }

        0 # We were successful
      end
    end
  end
end
