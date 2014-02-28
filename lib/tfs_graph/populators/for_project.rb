require 'tfs_graph/populators/for_branch'

module TFSGraph
  module Populators

    #incremental updates for a project, its branches, changesets and merges
    class ForProject
      include Utilities

      def initialize(project, since=Time.at(0).utc)
        @project = project
        @branch_store = BranchStore.new(@project)
      end

      def populate
        new_branches = @branch_store.fetch_since_last_update
        @branch_store.cache_all(new_branches)

        active_branches = @project.active_branches

        changesets = active_branches.map do |branch|
          ForBranch.new(@project, branch).populate
        end

        # Add merges
        active_branches.each {|branch| ChangesetMergeStore.new(branch).fetch_and_cache }
        ChangesetTreeBuilder.set_branch_merges(changesets.flatten)

        BranchArchiveHandler.hide_moved_archives_for_project(@project)
        @project.updated!
      end
    end
  end
end
