module TFSGraph
  class Entity
    extend Comparable

    attr_reader :internal_id

    def self.inherited(klass)
      define_singleton_method :act_as_entity do
        attr_accessor *klass::SCHEMA.keys
      end
    end

    private
    def schema
      self.class::SCHEMA
    end
  end
end