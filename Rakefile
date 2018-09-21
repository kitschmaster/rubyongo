require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
  t.description = 'Run tests'
end

Rake::TestTask.new(:spec) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_spec.rb"]
  t.description = 'Run specs'
end

desc 'Run test suite'
task :default => [:test, :spec]

