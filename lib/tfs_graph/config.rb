module TFSGraph
  class Config
    attr_accessor :tfs, :graph

    def graph(repo_type: nil, server: nil)
      raise ArgumentError unless (repo_type && server)
      RepositoryRegistry.register do |r|
        r.type repo_type
        r.server server
      end
    end
  end
end