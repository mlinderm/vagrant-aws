require 'test_helper'

class CommandTest < Test::Unit::TestCase
  setup do
    @env = vagrant_env
  end

	context "up" do
				
		should "run aws_up" do
      @env.config.for_vm(:default).aws.key_name = "default"
			@env.vms.values.each do |vm|
				vm.env.action_runner.expects(:run).with(:aws_up, {'provision.enabled' => true}).once
			end
			@env.cli("aws","up")
		end

	end
	
end

