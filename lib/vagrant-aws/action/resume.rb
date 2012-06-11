module VagrantAWS
	module Action
		class Resume
			def initialize(app, env)
				@app = app
			end

			def call(env)
				if env["vm"].vm.state == "stopped"
					raise VagrantAWS::Errors::EBSDeviceRequired, :command => "resume" if env["vm"].vm.root_device_type != "ebs"
					env.ui.info I18n.t("vagrant.actions.vm.resume.resuming")
					env["vm"].vm.start
				end
				
				@app.call(env)
			end
	
		end
	end
end
