require 'tfs_graph/extensions'

module TFSGraph
  class Entity
    include Comparable
    include Extensions

    NotPersisted = Class.new(RuntimeError)

    attr_accessor :db_object

    def self.inherited(klass)
      define_singleton_method :act_as_entity do
        attr_accessor *klass::SCHEMA.keys
      end
    end

    def self.repository
      TFSGraph::RepositoryRegistry.instance.send "#{base_class_name}_repository"
    end

    def initialize(repo, args)
      @repo = repo

      schema.each do |key, details|
        send "#{key}=", (args[key] || details[:default])
      end
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

    def to_hash
      hash = {}
      schema.keys.each do |key|
        hash[key] = send key
      end

      hash
    end

    def internal_id
      raise NotPersisted unless persisted?
      db_object.id
    end

    def schema
      self.class::SCHEMA
    end
  end
end