module Vagrant
	module Systems
		class Debian < Linux
			def bootstrap_chef
        vm.ssh.execute do |ssh|
          commands = [
						"apt-get -y --force-yes update",
						"apt-get -y --force-yes install ruby ruby-dev libopenssl-ruby irb build-essential wget ssl-cert",
						"cd /tmp && wget -nv http://production.cf.rubygems.org/rubygems/rubygems-1.7.2.tgz && tar zxf rubygems-1.7.2.tgz",
						"cd rubygems-1.7.2 && ruby setup.rb --no-format-executable",
						"gem install chef --no-ri --no-rdoc"
					]	
					ssh.sudo!(commands) do |channel, type, data|
            if type == :exit_status
              ssh.check_exit_status(data, commands)
            else
              vm.env.ui.info("#{data}: #{type}")
            end
          end
				end
			end
		end
	end
end
