module VagrantAWS
	class Action
		class DeregisterImage
			def initialize(app, env)
				@app = app
			end

			def call(env)
				if env['deregister']
					image = Fog::Compute.new(:provider => 'AWS').images.new(load_image(env))	
					env.ui.info I18n.t("vagrant.plugins.aws.actions.deregister_image.deregistering", :image => image.id)
					image.reload
					image.deregister(true)  # Delete snapshot when deregistering	
				end
				@app.call(env)
			end

			def load_image(env)
				File.open(File.join(env["box"].directory, "image.json"), "r") do |f|
					JSON.parse(f.read)
				end
			end

		end
	end
end

