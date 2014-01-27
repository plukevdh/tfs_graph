module TFSGraph
  module Extensions
    private
    def add_behavior(repo, additions)
      repo.extend additions
    end

    def constantize(string)
      Object.const_get string.to_sym
    end
  end
end