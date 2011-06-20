module VagrantAWS

	class Box < Vagrant::Box
	
		%w{ ovf_file repackage destroy }.each do |method|
			undef_method(method)
		end

		def add
			raise Vagrant::Errors::BoxAlreadyExists, :name => name if File.directory?(directory)
			env.actions.run(:aws_add_image, { "box" => self, "validate" => false })
		end

		def remove(options=nil)
			env.actions.run(:aws_remove_image, { "box" => self, "validate" => false }.merge(options || {}))
		end

	end

end
