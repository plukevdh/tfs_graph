require 'active_support/hash_with_indifferent_access'
require 'tfs_graph/extensions'

require 'tfs_graph/project'
require 'tfs_graph/branch'
require 'tfs_graph/changeset'

require 'tfs_graph/behaviors'

module TFSGraph
  class Repository
    include Extensions
    attr_reader :type

    NotFound = Class.new(RuntimeError)

    def initialize(type)
      @type = type

      add_behavior self, constantize("TFSGraph::Behaviors::#{self.base_class_name}::#{type.base_class_name}")

      # register self as the server type
      ServerRegistry.server(self)
    end

    def find(id)
      rebuild find_native(id)
    end

    def exists?(id)
      begin
        find_native(id)
        true
      rescue NotFound
        false
      end
    end

    def related?(node1, node2, type)
      node1.rels(dir: :outgoing, between: node2, type: type).any?
    end

    def save(object)
      db_object = object.persisted? ? update(object) : persist(object)
      object.persist get_id(db_object), db_object
    end

    def build(args={})
      @type.new self, args
    end

    def rebuild(db_object)
      attributes = HashWithIndifferentAccess.new db_object.attributes

      obj = build attributes
      obj.persist get_id(db_object)
    end

    def create(args)
      object = build(args)
      save(object)
    end

    def inspect
      type
    end

    private
    def normalize(attrs)
      HashWithIndifferentAccess.new attrs
    end
  end
end