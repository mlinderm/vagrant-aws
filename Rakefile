require 'bundler/gem_tasks'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  ENV['VAGRANT_HOME'] = File.join(File.dirname(__FILE__), 'test', 'tmp', 'home')

  t.libs << "test"
  t.pattern = 'test/**/*_test.rb'
end

