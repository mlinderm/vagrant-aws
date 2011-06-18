require "test_helper"

class TerminateActionTest < Test::Unit::TestCase
  setup do
    @app, @env = action_env
		@env.env.vm = VagrantAWS::VM.new(:env => @env.env, :name => "default")
    @middleware = VagrantAWS::Action::Terminate.new(@app, @env)
	
		@internal_vm = mock("internal")
    @env.env.vm.stubs(:vm).returns(@internal_vm)
	end

	should "destroy VM and attached images" do
    @internal_vm.expects(:destroy).once
    @env["vm"].expects(:vm=).with(nil).once
    @app.expects(:call).with(@env).once
    @middleware.call(@env)
  end

end
