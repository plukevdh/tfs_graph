# Domain knowledge of where to get branch data from and how to instantiate a Branch object
require 'tfs_graph/branch_store'
require 'tfs_graph/changeset_store'
require 'tfs_graph/changeset_merge_store'
require 'tfs_graph/branch_tree_creator'
require 'tfs_graph/changeset_tree_creator'

BranchNotFound = Class.new(Exception)

module TFSGraph
  class GraphPopulator
    class << self
      def populate_for_project(root_name)
        branches = BranchStore.fetch(root_name)

        BranchTreeCreator.to_tree branches

        branches.map do |branch|
          changesets = ChangesetStore.fetch(branch)
          ChangesetTreeCreator.to_tree changesets, branch

          merges = ChangesetMergeStore.fetch(branch)
        end
      end
    end
  end
end