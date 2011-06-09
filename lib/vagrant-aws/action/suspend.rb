module VagrantAWS
	class Action
		class Suspend
			def initialize(app, env)
				@app = app
			end

			def call(env)
				if env["vm"].vm.running?
					raise VagrantAWS::Errors::EBSDeviceRequired, :command => "suspend" if env["vm"].vm.root_device_type != "ebs"
					env.ui.info I18n.t("vagrant.actions.vm.suspend.suspending")
          env["vm"].vm.stop
        end
				
				@app.call(env)
			end
	
		end
	end
end
