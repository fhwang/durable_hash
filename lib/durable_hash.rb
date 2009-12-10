module DurableHash
  def self.included(includer)
    includer.validates_uniqueness_of :key
    includer.validates_presence_of :key, :value_class
    includer.serialize :value
  
    def includer.[](key)
      if record = find_by_key(key.to_s)
        record.value
      end
    end
    
    def includer.[]=(key, value)
      if record = find_by_key(key.to_s)
        record.value = value
        record.save!
      else
        create! :key => key.to_s, :value => value
      end
    end
    
    includer.before_validation :set_value_class
  end
  
  def after_find
    if value_class == 'Fixnum'
      self.value = self.value.to_i
    elsif value_class == 'Float'
      self.value = self.value.to_f
    end
  end
    
  def set_value_class
    self.value_class = self.value.class.name
  end
end
