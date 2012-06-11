require 'test_helper'

class CreateImageTest < Test::Unit::TestCase
	
	setup do
		@app, @env = action_env
		
		@middleware = VagrantAWS::Action::CreateImage.new(@app, @env)
		
		@env["vm"].expects(:created?).returns(true)
		
		@env["vm"].vm = @env["vm"].connection.servers.create
		@env["vm"].vm.root_device_type = "ebs"  # Fog mock instances are "instance-store" by default
		
		@env["vm"].connection.data[:images] = { "notused" => { "imageId" => @env["vm"].vm.image_id }}
	end

	should "return error if instance not running" do
		@env["vm"].vm.stubs(:running?).returns(false)
		assert_raise(Vagrant::Errors::VMNotRunningError) do
			@middleware.call(@env)
		end
	end

	context "instance running" do
		setup do
			@env["vm"].vm.stubs(:running?).returns(true)
		end
	
		should "not create image unless register specified" do
			@env["vm"].connection.expects(:create_image).never
			@middleware.call(@env)
		end

		should "create image if register specified" do
			@env["vm"].connection.expects(:create_image => @env["vm"].connection.create_image(@env["vm"].vm.id, "test", "test"))
			@env["image.register"] = true
			@middleware.call(@env)
		end

		context "recovery" do
			setup do
				@internal_image = @env["vm"].connection.create_image(@env["vm"].vm.id, "test", "test")
				@env["vm"].connection.stubs(:create_image).returns(@internal_image)
			end

			should "deregister if error during registration" do
				@env["image.register"] = true
				@middleware.call(@env)
				@middleware.image.expects(:deregister).with(true)
				@middleware.recover(@env)
			end

		end

		should "call the next app" do
			@app.expects(:call).once
			@middleware.call(@env)
		end
	end

end
