require 'vagrant'
require 'vagrant-aws/version'
require 'vagrant-aws/errors'
require 'vagrant-aws/environment'
require 'vagrant-aws/vm'
require 'vagrant-aws/config'
require 'vagrant-aws/middleware'
require 'vagrant-aws/command'
require 'vagrant-aws/system'

# Add our custom translations to the load path
I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)
