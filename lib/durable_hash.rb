module DurableHash
  def self.included(includer)
    def includer.acts_as_durable_hash
      self.validates_uniqueness_of :key
      self.validates_presence_of :key, :value_class
      self.serialize :value
    
      def self.[](key)
        if record = find_by_key(key.to_s)
          record.value
        end
      end
      
      def self.[]=(key, value)
        if record = find_by_key(key.to_s)
          record.value = value
          record.save!
        else
          create! :key => key.to_s, :value => value
        end
      end
      
      self.before_validation do |record|
        record.value_class = record.value.class.name
      end
      
      define_method(:after_find) do
        if attributes['value_class']
          if value_class == 'Fixnum'
            self.value = self.value.to_i
          elsif value_class == 'Float'
            self.value = self.value.to_f
          end
        end
      end
    end
  end
end

class ActiveRecord::Base
  include DurableHash
end
