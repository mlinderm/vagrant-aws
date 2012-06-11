require 'optparse'

module VagrantAWS
  module Command
    class BoxCreate < Vagrant::Command::Base   
      def execute

        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant aws box_create <name> [-r] [-f image_name] [-d description] [-h]"
          opts.separator ""
        end

        # Parse the options
        opts.on("-r", "--register", "Register with AWS") do |r|
          options[:register] = r
        end

        opts.on("-f", "--image_name", "The name for the created image") do |f|
          options[:image_name] = f
        end

        opts.on("-d", "--description", "The description of created image") do |d|
          options[:image_desc] = d
        end

        # Parse the options
        argv = parse_options(opts)

        @logger.debug("AWS BoxAdd command: #{argv.inspect} #{options.inspect}")

        raise Vagrant::Errors::MultiVMTargetRequired, :command => "box_create" if target_vms(argv).length > 1
      
        ami_vm = target_vms(argv).first   
        ami_vm.env.actions.run(:aws_create_image, {
          'package.output' => options[:image_name] || env.config.package.name,
          'image.register' => options[:register],
          'image.name' => options[:image_name] || "vagrantaws_#{rand(36**8).to_s(36)}",
          'image.desc' => options[:image_desc] || "Image created by vagrant-aws"
        })
      
        0 # We were successful
      end
    end
  end
end
