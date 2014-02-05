require 'tfs_graph/entity'
require 'tfs_graph/extensions'

module TFSGraph
  class PersistableEntity < Entity
    include Comparable
    include Extensions

    NotPersisted = Class.new(RuntimeError)

    attr_accessor :db_object

    def self.repository
      TFSGraph::RepositoryRegistry.instance.send "#{base_class_name}_repository"
    end

    def initialize(repo, args)
      @repo = repo

      super args
    end

    def persisted?
      !db_object.nil?
    end

    def save!
      @repo.save(self)
    end

    def persist(db_object)
      @db_object = db_object
      self
    end

    def internal_id
      raise NotPersisted unless persisted?
      db_object.id
    end
  end
end