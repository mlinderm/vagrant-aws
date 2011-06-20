module VagrantAWS
	class BoxCollection < Vagrant::BoxCollection

		def reload!
			@boxes.clear
      Dir.open(env.boxes_path) do |dir|
        dir.each do |d|
          next if d == "." || d == ".." || !File.directory?(env.boxes_path.join(d))
          @boxes << VagrantAWS::Box.new(env, d)
        end
      end
		end

	end
end
