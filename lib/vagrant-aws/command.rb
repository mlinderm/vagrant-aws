require 'fog'

module VagrantAWS
	module Command
		class AWS < Vagrant::Command::Base	
			def initialize(argv, env)
				super

				# Set up our AWS credentials
				initialize_aws_environment(env)

        @main_args, @sub_command, @sub_args = split_main_and_subcommand(argv)

        @subcommands = Vagrant::Registry.new
        @subcommands.register(:up)         { VagrantAWS::Command::Up }
        @subcommands.register(:destroy)    { VagrantAWS::Command::Destroy }
        @subcommands.register(:status)     { VagrantAWS::Command::Status }
        @subcommands.register(:ssh)        { VagrantAWS::Command::SSH }
        @subcommands.register(:suspend)    { VagrantAWS::Command::Suspend }
        @subcommands.register(:resume)     { VagrantAWS::Command::Resume }
        @subcommands.register(:ssh_config) { VagrantAWS::Command::SSHConfig }
        @subcommands.register(:box_create) { VagrantAWS::Command::BoxCreate }
        @subcommands.register(:box_add)    { VagrantAWS::Command::BoxAdd }
        @subcommands.register(:box_list)   { VagrantAWS::Command::BoxList }
        @subcommands.register(:box_remove) { VagrantAWS::Command::BoxRemove }
			end

			def execute
       if @main_args.include?("-h") || @main_args.include?("--help")
          # Print the help for all the box commands.
          return help
        end

        # If we reached this far then we must have a subcommand. If not,
        # then we also just print the help and exit.
        command_class = @subcommands.get(@sub_command.to_sym) if @sub_command
        return help if !command_class || !@sub_command
        @logger.debug("Invoking command class: #{command_class} #{@sub_args.inspect}")

        # Initialize and execute the command class
        command_class.new(@sub_args, @env).execute
			end

			def help
        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant aws <command> [<args>]"
          opts.separator ""
          opts.separator "Available subcommands:"

          # Add the available subcommands as separators in order to print them
          # out as well.
          keys = []
          @subcommands.each { |key, value| keys << key.to_s }

          keys.sort.each do |key|
            opts.separator "     #{key}"
          end

          opts.separator ""
          opts.separator "For help on any individual command run `vagrant aws COMMAND -h`"
        end

        @env.ui.info(opts.help, :prefix => false)
			end

			protected

			# Reinitialize "AWS" environment
			def initialize_aws_environment(env)
				raise Errors::CLIMissingEnvironment if !env
				if env.is_a?(VagrantAWS::Environment)
					@env = env
				else
					@env = VagrantAWS::Environment.new
					@env.ui = env.ui  # Touch up UI 
					@env.load!
				end
			end

		end

    Vagrant.commands.register(:aws, AWS)

    autoload :BoxAdd,      'vagrant-aws/command/box_add'
    autoload :BoxCreate,   'vagrant-aws/command/box_create'
    autoload :BoxList,     'vagrant-aws/command/box_list'
    autoload :BoxRemove,   'vagrant-aws/command/box_remove'
    autoload :Destroy,     'vagrant-aws/command/destroy'
    autoload :Provision,   'vagrant-aws/command/provision'
    autoload :Resume,      'vagrant-aws/command/resume'
    autoload :SSH,         'vagrant-aws/command/ssh'
    autoload :SSHConfig,   'vagrant-aws/command/ssh_config'
    autoload :Status,      'vagrant-aws/command/status'
    autoload :Suspend,     'vagrant-aws/command/suspend'
    autoload :Up,          'vagrant-aws/command/up'

	end
end
