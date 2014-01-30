require 'tfs_graph/extensions'

module TFSGraph
  class RepositoryRegistry
    include Extensions

    TYPES = %w(branch changeset project)

    def initialize(repo)
      @base_repo = repo
    end

    TYPES.each do |type|
      define_method "#{type}_repository" do
        existing = instance_variable_get("@#{type}_repo")
        return existing unless existing.nil?

        repo = @base_repo.new constantize("TFSGraph::#{type.capitalize}")

        instance_variable_set("@#{type}_repo", repo)
        repo
      end
    end
  end
end