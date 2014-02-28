module TFSGraph
  module Populators
    class Everything
      include Utilities

      def populate
        clean

        projects = ProjectStore.fetch_and_cache

        projects.each do |project|
          branches = BranchStore.new(project).fetch_and_cache

          changesets = branches.select(&:active?).map do |branch|
            changesets = ChangesetStore.new(branch).fetch_and_cache
            ChangesetTreeBuilder.to_tree(branch, changesets)

            branch.updated!
            changesets
          end

          ChangesetTreeBuilder.set_branch_merges(changesets)

          project.updated!
        end

        BranchArchiveHandler.hide_moved_archives_for_project(projects)
        finalize
      end
    end
  end
end