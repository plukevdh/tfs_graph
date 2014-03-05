module TFSGraph
  module Populators

    # incremental updates for a branch and its changesets
    # does not update merges. have to do that once all changesets
    # for a project are fetched
    class ForArchivedBranch
      include Utilities

      def initialize(project, branch)
        @project = project
        @branch = branch

        @changeset_store = ChangesetStore.new(branch)
      end

      def populate
        return @branch.changesets unless @branch.changesets.empty?

        all_changesets = @changeset_store.fetch_and_cache
        ChangesetTreeBuilder.to_tree(@branch, all_changesets.sort)

        @branch.updated!
        all_changesets
      end
    end
  end
end