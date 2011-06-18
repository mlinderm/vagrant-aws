module VagrantAWS
	module Errors

		class VagrantError < Vagrant::Errors::VagrantError
			def error_namespace; "vagrant.plugins.aws.errors"; end
		end

		class NotYetSupported < VagrantError
			error_key(:not_yet_supported)
		end

		class KeyNameNotSpecified < VagrantError
			error_key(:key_name_not_specified)
		end

		class PrivateKeyFileNotSpecified < VagrantError
			error_key(:private_key_file_not_specified)
		end

		class EBSDeviceRequired < VagrantError
			error_key(:ebs_device_required)
		end

		class VMCreateFailure < VagrantError
			error_key(:vm_create_failure)
		end

	end
end
