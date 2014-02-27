require 'tfs_graph/tfs_client'
require 'tfs_graph/tfs_helpers'
require 'tfs_graph/store_helpers'

module TFSGraph
  class AbstractStore
    include TFSClient
    include TFSHelpers
    include StoreHelpers

    class << self
      def fetch_and_cache
        cache_all fetch_all
      end

      def fetch_all
        normalize root_query.run
      end

      def cache_all(attr_set)
        attr_set.map {|attrs| cache(attrs) }
      end
    end
  end
end