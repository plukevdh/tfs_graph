require 'tfs_graph/project/project_store'
require 'tfs_graph/branch/branch_store'
require 'tfs_graph/changeset/changeset_store'
require 'tfs_graph/changeset_merge/changeset_merge_store'

require 'tfs_graph/associators/changeset_tree_creator'
require 'tfs_graph/associators/branch_associator'
require 'tfs_graph/branch/branch_archive_handler'

require 'tfs_graph/populators'

BranchNotFound = Class.new(Exception)

module TFSGraph
  class GraphPopulator
    include Populators

    class << self
      include StoreHelpers

      def populate_graph(type=Everything, *args)
        populator = type.new *args
        populator.populate
      end
    end
  end
end