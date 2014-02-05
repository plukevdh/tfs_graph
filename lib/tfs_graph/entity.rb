module TFSGraph
  class Entity
    def self.inherited(klass)
      define_singleton_method :act_as_entity do
        attr_accessor *klass::SCHEMA.keys
      end
    end

    def initialize(args)
      schema.each do |key, details|
        send "#{key}=", (args[key] || details[:default])
      end
    end

    def to_hash
      hash = {}
      schema.keys.each do |key|
        hash[key] = send key
      end

      hash
    end
    alias_method :attributes, :to_hash

    def schema
      self.class::SCHEMA
    end
  end
end
