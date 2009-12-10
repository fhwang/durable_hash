module DurableHash
  def self.included(includer)
    def includer.[](key)
      if record = find_by_key(key.to_s)
        record.value
      end
    end
  end
end
