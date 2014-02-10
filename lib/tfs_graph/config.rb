module TFSGraph
  class Config
    attr_accessor :tfs, :graph

    def graph(repo_type:, server_path:)
      RepositoryRegistry.register do |r|
        r.type repo_type
        r.server server_path
      end
    end
  end
end