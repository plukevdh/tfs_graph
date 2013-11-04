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
      include StoreHelpers

      def populate_all
        projects = ProjectStore.cache
        changesets = projects.map {|p| populate_for_project(p) }

        mark_as_updated
        changesets
      end

      def populate_for_project(project)
        branches = BranchStore.new(project).cache_all
        changesets = branches.map {|branch| cache_changesets branch }

        # can't associate merges until changesets are cached
        branches.each do |branch|
          ChangesetMergeStore.new(branch).cache
        end

        BranchAssociator.associate_groups(changesets)
        changesets
      end

      def incrementally_update_all
        changesets = ProjectStore.all_cached.map do |project|
          incrementally_update_project(project)
        end

        mark_as_updated
        changesets
      end

      def incrementally_update_project(project)
        new_changesets = project.branches.map {|branch| cache_changesets(branch, :cache_since_last_update) }
          new_branches = BranchStore.new(project).cache_since_last_update

          new_changesets.concat new_branches.map {|branch| cache_changesets(branch) }

          # recache and reassociate all merges for all branches.
          # should not lead to dupes thanks to Related
          new_branches.concat(project.branches).each do |branch|
            ChangesetMergeStore.new(branch).cache
            BranchAssociator.associate(branch.changesets)
          end

          new_changesets
        end
      end

      private
      def cache_changesets(branch, using=:cache_all)
        changesets = ChangesetStore.new(branch).send using
        ChangesetTreeCreator.to_tree branch
        changesets.compact
      end
    end
  end
end