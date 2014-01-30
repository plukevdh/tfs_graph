require 'active_support/inflector'

module TFSGraph
  module Extensions
    private

    def add_behavior(repo, additions)
      repo.extend additions
    end

    def constantize(string)
      string.constantize
    end
  end
end