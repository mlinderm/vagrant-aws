require 'vagrant'
require 'vagrant-aws/version'
require 'vagrant-aws/errors'
require 'vagrant-aws/environment'
require 'vagrant-aws/vm'
require 'vagrant-aws/config'
require 'vagrant-aws/middleware'
require 'vagrant-aws/command'
require 'vagrant-aws/box'

# Add our custom translations to the load path
I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)

module VagrantAWS
  # The source root is the path to the root directory of
  # the Vagrant gem.
  def self.source_root
    @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
  end
end

