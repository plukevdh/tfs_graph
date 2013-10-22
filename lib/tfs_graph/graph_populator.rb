# Domain knowledge of where to get branch data from and how to instantiate a Branch object
require 'tfs_graph/project/project_store'
require 'tfs_graph/branch/branch_store'
require 'tfs_graph/changeset/changeset_store'
require 'tfs_graph/changeset_merge/changeset_merge_store'

require 'tfs_graph/associators/changeset_tree_creator'
require 'tfs_graph/associators/branch_associator'

BranchNotFound = Class.new(Exception)

module TFSGraph
  class GraphPopulator
    class << self
      def populate_all
        projects = ProjectStore.cache
        projects.map {|p| populate_for_project(p) }
      end

      def populate_for_project(project)
        branches = BranchStore.new(project).cache

        changesets = branches.map do |branch|
          changesets = ChangesetStore.new(branch).cache
          ChangesetTreeCreator.to_tree changesets, branch
          changesets
        end

        # can't associate merges until changesets are cached
        branches.each do |branch|
          ChangesetMergeStore.new(branch).cache
        end

        BranchAssociator.associate(changesets)
      end
    end
  end
end