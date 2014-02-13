module TFSGraph
  class Entity
    def self.inherited(klass)
      define_singleton_method :act_as_entity do
        attr_accessor *klass::SCHEMA.keys
      end
    end

    def initialize(args)
      schema.each do |key, details|
        value = (args[key] || details[:default])

        value = ressurect_time(value) if details[:type] == Time

        send "#{key}=", value
      end
    end

    def to_hash
      hash = {}
      schema.keys.each do |key|
        hash[key] = send key
      end

      hash.each do |k,v|
        next unless v.is_a? Time
        hash[k] = v.to_i
      end

      hash
    end
    alias_method :attributes, :to_hash

    def schema
      self.class::SCHEMA
    end

    private
    def ressurect_time(time)
      return time if (time.is_a?(Time) || time.nil?)
      Time::at time
    end
  end
end
