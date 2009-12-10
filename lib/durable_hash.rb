module DurableHash
  def self.included(includer)
    def includer.[](key)
      if record = find_by_key(key.to_s)
        record.value
      end
    end
    
    def includer.[]=(key, value)
      if record = find_by_key(key.to_s)
        record.value = value
        record.save
      else
        create! :key => key.to_s, :value => value
      end
    end
  end
end
