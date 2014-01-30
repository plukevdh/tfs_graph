require 'active_support/hash_with_indifferent_access'
require 'tfs_graph/extensions'

module TFSGraph
  class Repository
    include Extensions

    NotFound = Class.new(RuntimeError)

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

    def rebuild(db_object)
      attributes = HashWithIndifferentAccess.new db_object.attributes

      obj = build attributes
      obj.internal_id = db_object.id
      obj
    end

    def create(args)
      object = build(args)
      save(object)
    end
  end
end