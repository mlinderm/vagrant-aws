require 'test_helper'

class CreateSSHKeyActionTest < Test::Unit::TestCase
	setup do
		@app, @env = action_env
	
		@env.env.vm = VagrantAWS::VM.new(:env => @env.env, :name => "default")
		@connection =  @env["vm"].connection  # We need to trigger the connection creation to load FOG models

		@middleware = VagrantAWS::Action::CreateSSHKey.new(@app, @env)
		
		@env["config"].aws.key_name = "default"
	end

	should "call the next app" do
    @app.expects(:call).once
    @middleware.call(@env)
  end

	should "not do anything if key name is provided" do
		@env["vm"].connection.expects(:key_pairs).never
		@middleware.call(@env)
	end

	context "no key specified" do 
		setup do
			@env["config"].aws.key_name = nil
		end
	
		should "use pre-existing key pair if available" do
			@env.env.expects(:ssh_keys).returns(["existing_key"])
			@connection.data[:key_pairs] = { "notused" => { "keyName" => "existing_key"} }
			@middleware.call(@env)
		end

		should "create key pair if none available" do
			@env.env.expects(:ssh_keys).returns([])
			File.stubs(:open).with(@env.env.ssh_keys_path.join("vagrantaws_#{Mac.addr.gsub(':','')}"), File::WRONLY|File::TRUNC|File::CREAT, 0600).returns(nil)  
			@middleware.call(@env)
		end
	end

end
