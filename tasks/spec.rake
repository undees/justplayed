require 'rake/testtask'
require 'spec/rake/spectask'

task :default => :spec

task :spec => :compile

Spec::Rake::SpecTask.new do |t|
  t.libs << 'test' << 'test/bundles'
end
