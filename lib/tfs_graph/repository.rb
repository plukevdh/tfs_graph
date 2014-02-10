require 'active_support/hash_with_indifferent_access'
require 'tfs_graph/extensions'

require 'tfs_graph/project'
require 'tfs_graph/branch'
require 'tfs_graph/changeset'

require 'tfs_graph/project/behaviors'
require 'tfs_graph/branch/behaviors'
require 'tfs_graph/changeset/behaviors'

module TFSGraph
  class Repository
    include Extensions
    attr_reader :type

    NotFound = Class.new(RuntimeError)

    def initialize(type, server)
      @type = type
      @server = server
      add_behavior self, constantize("#{type}::Behaviors")
    end

    def save(object, db_object)
      object.persist db_object
    end

    def build(args={})
      @type.new self, args
    end

    def rebuild(db_object)
      attributes = HashWithIndifferentAccess.new db_object.attributes

      obj = build attributes
      obj.persist db_object
    end

    def create(args)
      object = build(args)
      save(object)
    end

    def inspect
      type
    end
  end
end