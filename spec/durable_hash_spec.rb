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
      app_setting.string 'value_class'
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
    as.save!
  end

  it 'should return the value' do
    ApplicationSetting['foo'].should == 'bar'
  end

  it 'should return the value with a symbol too' do
    ApplicationSetting[:foo].should == 'bar'
  end
end

describe "ApplicationSetting creating" do
  before :each do
    ApplicationSetting.destroy_all
  end
  
  it 'should handle a write' do
    ApplicationSetting['foo'] = 'bar'
    ApplicationSetting['foo'].should == 'bar'
  end
  
  it 'should handle a write with a symbol' do
    ApplicationSetting[:foo] = 'bar'
    ApplicationSetting['foo'].should == 'bar'
  end
end

describe "ApplicationSetting updating" do
  before :each do
    ApplicationSetting.destroy_all
    ApplicationSetting.create! :key => 'foo', :value => 'bar'
  end
  
  it 'should handle a write' do
    ApplicationSetting['foo'] = 'baz'
    ApplicationSetting['foo'].should == 'baz'
  end
end

describe "ApplicationSetting uniqueness" do
  before :all do
    ApplicationSetting.destroy_all
    ApplicationSetting.create! :key => 'foo', :value => 'bar'
  end
  
  it 'should be set on key automatically' do
    lambda {
      ApplicationSetting.create!(:key => 'foo', :value => 'baz')
    }.should raise_error
  end
  
  it 'should prevent new instances from being seen as valid' do
    ApplicationSetting.new(:key => 'foo', :value => 'baz').should_not be_valid
  end
end

describe 'ApplicationSetting with an integer' do
  before :all do
    ApplicationSetting.destroy_all
  end
  
  it 'should read and write as an integer' do
    ApplicationSetting['foo'] = 123
    ApplicationSetting['foo'].should == 123
  end
end

describe 'ApplicationSetting with a float' do
  before :all do
    ApplicationSetting.destroy_all
  end
  
  it 'should read and write as a float' do
    ApplicationSetting['foo'] = 123.0
    ApplicationSetting['foo'].class.should == Float
    ApplicationSetting['foo'].should be_close(123.0, 0.00001)
  end
end

describe 'ApplicationSetting with an array' do
  before :all do
    ApplicationSetting.destroy_all
  end
  
  it 'should read and write as a float' do
    ApplicationSetting['foo'] = [1,2,3]
    ApplicationSetting['foo'].should == [1,2,3]
  end
end

describe 'ApplicationSetting.valid? for a new instance' do
  before :all do
    ApplicationSetting.destroy_all
  end

  it 'should not need a value_class to be explicitly set' do
    app_setting = ApplicationSetting.new :key => 'username', :value => 'bob'
    app_setting.should be_valid
  end
end
