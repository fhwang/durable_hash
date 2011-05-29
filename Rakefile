# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "durable_hash"
  gem.homepage = "http://github.com/fhwang/durable_hash"
  gem.license = "MIT"
  gem.summary = %Q{Maybe you want something that acts like a hash but is backed by ActiveRecord.}
  gem.description = %Q{Maybe you want something that acts like a hash but is backed by ActiveRecord.}
  gem.email = "francis.hwang@profitably.com"
  gem.authors = ["Francis Hwang"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

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

