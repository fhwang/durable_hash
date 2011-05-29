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
  gem.name = "durable_hash.jeweler"
  gem.homepage = "http://github.com/fhwang/durable_hash.jeweler"
  gem.license = "MIT"
  gem.summary = %Q{TODO: one-line summary of your gem}
  gem.description = %Q{TODO: longer description of your gem}
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

