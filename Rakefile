require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

Rake::TestTask.new(:spec) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_spec.rb"]
end

task :default => [:test, :spec]
