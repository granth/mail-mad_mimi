require 'bundler'
require 'rspec/core/rake_task'
Bundler::GemHelper.install_tasks

desc "Run all specs"
RSpec::Core::RakeTask.new {|task| task.pattern = "spec" }
