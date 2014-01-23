require "tfs_graph/version"
require "tfs_graph/config"
require 'tfs_graph/graph_populator'

module TFSGraph
  class << self
    def config
      return @config unless block_given?

      @config ||= begin
        config = Config.new
        yield config
        config
      end
    end
  end
end
