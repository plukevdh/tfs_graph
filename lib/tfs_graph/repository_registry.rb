require 'singleton'
require 'tfs_graph/extensions'

module TFSGraph
  class RepositoryRegistry
    include Extensions
    include Singleton

    TYPES = %w(branch changeset project)

    def self.register
      # assume re-registering means we want to clear existing repos
      instance.reset!
      yield instance if block_given?

      instance
    end

    def initialize
      reset!
    end

    def reset!
      @base_repo = nil

      TYPES.each do |type|
        instance_variable_set repo_memo(type), nil
      end
    end

    def identifier
      @base_repo.class.name =~ /Related/ ? "redis" : "neo4j"
    end

    def type(type)
      @base_repo = type
    end

    TYPES.each do |type|
      define_method "#{type}_repository" do
        existing = instance_variable_get repo_memo(type)
        return existing unless existing.nil?

        repo = @base_repo.new constantize("TFSGraph::#{type.capitalize}")

        instance_variable_set(repo_memo(type), repo)
        repo
      end

      define_singleton_method "#{type}_repository" do
        instance.send "#{type}_repository"
      end
    end

    private
    def repo_memo(type)
      "@#{type}_repo"
    end
  end
end