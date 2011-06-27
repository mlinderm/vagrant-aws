require 'test_helper'

class CreateActionTest < Test::Unit::TestCase
  setup do
    @app, @env = action_env

		@env.env.vm = VagrantAWS::VM.new(:env => @env.env, :name => "default") 
		@connection =  @env["vm"].connection  # We need to trigger the connection creation to load FOG models

		@middleware = VagrantAWS::Action::Create.new(@app, @env)

		# Setup FOG mocks
		@env["config"].aws.key_name = "default"
		@connection.data[:key_pairs] = { "notused" => { "keyName" => "default"} }
		@connection.data[:images] = { "default" => { "imageId" => @env["config"].aws.image, "imageState" => 'available' } }
	end

	should "call the next app" do
    @app.expects(:call).once
    @middleware.call(@env)
  end

  should "create running AWS server" do
    @middleware.call(@env)
		
		assert_not_nil @env["vm"].vm
		assert_instance_of Fog::Compute::AWS::Server, @env["vm"].vm
		assert @env["vm"].vm.running?
	end


	should "mark environment erroneous and not continue chain on failure" do
    Fog::Compute::AWS::Servers.any_instance.stubs(:create).returns(nil)
		@app.expects(:call).never
    assert_raises(VagrantAWS::Errors::VMCreateFailure) {
      @middleware.call(@env)
    }
  end

  context "recovery" do
    setup do
      @env["vm"].stubs(:created?).returns(true)
    end

    should "not run the destroy action on recover if error is a VagrantError" do
      @env["vagrant.error"] = Vagrant::Errors::VMImportFailure.new
      @env.env.actions.expects(:run).never
      @middleware.recover(@env)
    end

    should "not run the destroy action on recover if VM is not created" do
      @env.env.vm.stubs(:created?).returns(false)
      @env.env.actions.expects(:run).never
      @middleware.recover(@env)
    end

    should "run the destroy action on recover" do
      @env.env.vm.stubs(:created?).returns(true)
      @env.env.actions.expects(:run).with(:aws_destroy).once
      @middleware.recover(@env)
    end
  end

end

