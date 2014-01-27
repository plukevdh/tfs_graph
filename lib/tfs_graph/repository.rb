require 'tfs_graph/extensions'

module TFSGraph
  class Repository
    include Extensions

    def initialize(type)
      @type = type
      add_behavior self, constantize("#{type}::Behaviors")
    end

    def save(object, db_object)
      object.internal_id = db_object.id
      object
    end

    def build(args={})
      @type.new self, args
    end

    def create(args)
      object = build(args)
      save(object)
    end
  end
end