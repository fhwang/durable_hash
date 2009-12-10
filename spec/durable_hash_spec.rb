RAILS_ENV = 'test'
require 'rubygems'
require 'active_record'
require 'active_record/base'
require File.dirname(__FILE__) + '/../lib/durable_hash'

# Configure ActiveRecord
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.establish_connection(
  'timeout' => 5000, 'adapter' => 'sqlite3', 'database' => 'spec/test.sqlite3', 
  'pool' => 5
)

# Create the DB schema
silence_stream(STDOUT) do
  ActiveRecord::Schema.define do
    create_table 'application_settings', :force => true do |app_setting|
      app_setting.string 'key'
      app_setting.string 'value'
    end
  end
end

# Define a sample ActiveRecord class
class ApplicationSetting < ActiveRecord::Base
  include DurableHash
end

# Finally some specs
describe "ApplicationSettings that are empty" do
  before :all do
    ApplicationSetting.destroy_all
  end

  it 'should return nil for most everything' do
    ApplicationSetting['foo'].should be_nil
  end
end

describe "ApplicationSetting reading" do
  before :all do
    as = ApplicationSetting.find_or_create_by_key 'foo'
    as.value = 'bar'
    as.save
  end

  it 'should return the value' do
    ApplicationSetting['foo'].should == 'bar'
  end

  it 'should return the value with a symbol too' do
    ApplicationSetting[:foo].should == 'bar'
  end
end
