# Domain knowledge of where to get branch data from and how to instantiate a Branch object
require 'tfs_graph/project_store'
require 'tfs_graph/branch_store'
require 'tfs_graph/changeset_store'
require 'tfs_graph/changeset_merge_store'

require 'tfs_graph/branch_tree_creator'
require 'tfs_graph/changeset_tree_creator'
require 'tfs_graph/branch_associator'

BranchNotFound = Class.new(Exception)

module TFSGraph
  class GraphPopulator
    class << self
      def populate_all
        projects = ProjectStore.cache
        projects.map {|p| populate_for_project(p) }
      end

      def populate_for_project(project)
        branches = BranchStore.cache(project)

        changesets = branches.map do |branch|
          changesets = ChangesetStore.fetch(branch)
          ChangesetTreeCreator.to_tree changesets, branch
          changesets
        end

        branches.each do |branch|
          merges = ChangesetMergeStore.fetch(branch)
        end

        BranchAssociator.associate(changesets)
      end

      def populate_for_project_name(project_name)
        project = ProjectStore.find_cached(project_name)
        populate_for_project(project)
      end
    end
  end
end