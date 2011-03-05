require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the soft_destroyable plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the soft_destroyable plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = "SoftDestroyable #{version}"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "soft_destroyable"
    gem.summary = "Rails 3 ActiveRecord compatible soft destroy implementation"
    gem.description = "Rails 3 ActiveRecord compatible soft destroy implementation supporting dependent associations"
    gem.email = "rockrep@yahoo.com"
    gem.homepage = "http://github.com/rockrep/soft_destroyable"
    gem.authors = ["Michael Kintzer"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
