module TFSGraph
  module Populators
    class SinceDate
      include Utilities

      def initialize(since)
        @since = since
      end

      # could use the ForProject populator, except that we allow
      # specification of a date rather than using last updated.
      # also dumps all existing data
      def populate
        clean

        projects = ProjectStore.fetch_and_cache

        projects.each do |project|
          ForProject.new(project).populate
          branches = BranchStore.new(project).fetch_and_cache

          changesets = branches.select(&:active?).map do |branch|
            changesets = ChangesetStore.new(branch).fetch_since_date @since
            ChangesetTreeBuilder.to_tree(branch, changesets)

            branch.updated!
            changesets
          end

          # setup merges
          branches.each {|branch| ChangesetMergeStore.new(branch).fetch_and_cache }
          ChangesetTreeBuilder.set_branch_merges(changesets)

          BranchArchiveHandler.hide_moved_archives_for_project(@project)
          project.updated!
        end

        finalize
      end
    end
  end
end