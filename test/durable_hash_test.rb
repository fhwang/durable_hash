RAILS_ENV = 'test'
require 'rubygems'
require 'active_record'
require 'active_record/base'
require 'active_support/core_ext/logger'
require File.dirname(__FILE__) + '/../lib/durable_hash'
require 'test/unit'

# Configure ActiveRecord
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/test.log')
ActiveRecord::Base.establish_connection(
  'timeout' => 5000, 'adapter' => 'sqlite3', 'database' => 'test/test.sqlite3', 
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
    
    create_table 'customized_settings', :force => true do |app_setting|
      app_setting.string 'key'
      app_setting.string 'value'
      app_setting.string 'value_class'
    end
  end
end

# Define some sample classes
class ApplicationSetting < ActiveRecord::Base
  acts_as_durable_hash
end

module WrapperModule
  class Custom
    attr_accessor :value
  
    def initialize(value); @value = value; end
  end
  
  class SonOfCustom < Custom
  end
end

class CustomizedSetting < ActiveRecord::Base
  acts_as_durable_hash do |dh|
    dh.serialize(WrapperModule::Custom) do |custom|
      custom.value
    end
    dh.deserialize(WrapperModule::Custom) do |data|
      WrapperModule::Custom.new data
    end
  end
end

# Finally some tests
class EmptyApplicationSettingTestCase < Test::Unit::TestCase
  def setup
    ApplicationSetting.destroy_all
  end

  def test_should_return_nil_for_most_everything
    assert_nil(ApplicationSetting['foo'])
  end
end

class ApplicationSettingReadingTestCase < Test::Unit::TestCase
  def setup
    as = ApplicationSetting.find_or_create_by_key 'foo'
    as.value = 'bar'
    as.save!
  end
  
  def test_should_return_the_value
    assert_equal(ApplicationSetting['foo'], 'bar')
  end
  
  def test_should_return_the_value_with_a_symbol_too
    assert_equal(ApplicationSetting[:foo], 'bar')
  end
end

class ApplicationSettingCreatingTestCase < Test::Unit::TestCase
  def setup
    ApplicationSetting.destroy_all
  end
  
  def test_it_should_handle_a_write
    ApplicationSetting['foo'] = 'bar'
    assert_equal(ApplicationSetting['foo'], 'bar')
  end
  
  def test_should_handle_a_write_with_a_symbol
    ApplicationSetting[:foo] = 'bar'
    assert_equal(ApplicationSetting['foo'], 'bar')
  end
end

class ApplicationSettingUpdatingTestCase < Test::Unit::TestCase
  def setup
    ApplicationSetting.destroy_all
    ApplicationSetting.create! :key => 'foo', :value => 'bar'
  end
  
  def test_should_handle_a_write
    ApplicationSetting['foo'] = 'baz'
    assert_equal(ApplicationSetting['foo'], 'baz')
  end
end

class ApplicationSettingUniquenessTestCase < Test::Unit::TestCase
  def setup
    ApplicationSetting.destroy_all
    ApplicationSetting.create! :key => 'foo', :value => 'bar'
  end
  
  def test_should_be_set_on_key_automatically
    assert_raises(ActiveRecord::RecordInvalid) {
      ApplicationSetting.create!(:key => 'foo', :value => 'baz')
    }
  end
  
  def test_should_prevent_new_instances_from_being_seen_as_valid
    assert(!ApplicationSetting.new(:key => 'foo', :value => 'baz').valid?)
  end
end

class ApplicationSettingWithAnIntegerTestCase < Test::Unit::TestCase
  def setup
    ApplicationSetting.destroy_all
  end
  
  def test_should_read_and_write_as_an_integer
    ApplicationSetting['foo'] = 123
    assert_equal(ApplicationSetting['foo'], 123)
  end
end

class ApplicationSettingWithAFloatTestCase < Test::Unit::TestCase
  def setup
    ApplicationSetting.destroy_all
  end
  
  def test_should_read_and_write_as_a_float
    ApplicationSetting['foo'] = 123.0
    assert_equal(ApplicationSetting['foo'].class, Float)
    assert_in_delta(123.0, ApplicationSetting['foo'], 0.00001)
  end
end

class ApplicationSettingWithAnArrayTestCase < Test::Unit::TestCase
  def setup
    ApplicationSetting.destroy_all
  end
  
  def test_should_read_and_write_as_a_float
    ApplicationSetting['foo'] = [1,2,3]
    assert_equal(ApplicationSetting['foo'], [1,2,3])
  end
end

class ApplicationSettingValidForANewInstanceCase < Test::Unit::TestCase
  def setup
    ApplicationSetting.destroy_all
  end
  
  def test_should_not_need_a_value_class_to_be_explicitly_set
    app_setting = ApplicationSetting.new :key => 'username', :value => 'bob'
    assert(app_setting.valid?)
  end
end

class CustomizedSettingCustomSerializationTestCase < Test::Unit::TestCase
  def setup
    CustomizedSetting.destroy_all
  end
  
  def test_should_save_and_load_with_a_custom_serialization
    value = WrapperModule::Custom.new('bar')
    CustomizedSetting['foo'] = value
    value_prime = CustomizedSetting['foo']
    # let's make sure there's no in-Ruby caching going on which could give this
    # test a false positive
    assert_not_equal(value.object_id, value_prime.object_id)
    assert_equal(value_prime.class, WrapperModule::Custom)
    assert_equal(value_prime.value, 'bar')
  end
  
  def test_should_not_try_to_mess_with_a_normal_value
    CustomizedSetting['baz'] = 'fiz'
    assert_equal(CustomizedSetting['baz'], 'fiz')
  end
  
  def test_should_use_custom_serialization_for_any_subclasses_of_Custom_too
    value = WrapperModule::SonOfCustom.new('bar')
    CustomizedSetting['foo'] = value
    value_prime = CustomizedSetting['foo']
    # let's make sure there's no in-Ruby caching going on which could give this
    # test a false positive
    assert_not_equal(value.object_id, value_prime.object_id)
    assert_equal(value_prime.class, WrapperModule::Custom)
    assert_equal(value_prime.value, 'bar')
  end
end
