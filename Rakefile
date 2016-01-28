require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

namespace :specs do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec'
  end

  task :all do
    exit_code = 0

    %w(spec).each do |task_name|
      begin
        Rake::Task["specs:#{task_name}"].invoke
      rescue Exception
        exit_code = 1
      end
    end

    fail if exit_code == 1
  end
end

task default: 'specs:all'
