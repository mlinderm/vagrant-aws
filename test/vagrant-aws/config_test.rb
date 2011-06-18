require "test_helper"

class ConfigTest < Test::Unit::TestCase
  setup do
    @config = VagrantAWS::Config.new
		@errors = Vagrant::Config::ErrorRecorder.new
  end

	should "be valid by default" do
    @config.validate(@errors)
    assert @errors.errors.empty?
  end
	
end
