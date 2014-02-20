require 'tfs_graph/entity'
require 'tfs_graph/extensions'

module TFSGraph
  class PersistableEntity < Entity
    include Comparable
    include Extensions

    NotPersisted = Class.new(RuntimeError)

    attr_accessor :db_object, :id

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

    def persist(id, db_object)
      @id ||= id
      @db_object = db_object

      self
    end

    def db_object
      return nil unless id

      begin
        @db_object ||= @repo.find_native(id)
      rescue Repository::NotFound
      end
    end

    def to_hash
      hash = super
      hash[:id] = id

      hash
    end
  end
end