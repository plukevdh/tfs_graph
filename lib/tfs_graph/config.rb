module TFSGraph
  class Config
    attr_accessor :tfs, :graph

    def redis(url: url, namespace: namespace)
      ServerRegistry.register do |r|
        r.redis url: url, namespace: namespace
      end
    end

    def graph(repo_type: nil)
      raise ArgumentError unless repo_type
      RepositoryRegistry.register do |r|
        r.type repo_type
      end
    end
  end
end