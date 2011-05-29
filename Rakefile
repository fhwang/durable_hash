require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rubygems'

ActiveRecordVersions = %w(3.0.7 2.3.10)

desc "Run all tests"
task :test do
  ActiveRecordVersions.each do |ar_version|
    cmd = "ACTIVE_RECORD_VERSION=#{ar_version} ruby test/durable_hash_test.rb"
    puts cmd
    puts `cd . && #{cmd}`
    puts
  end
end

task :default => :test

