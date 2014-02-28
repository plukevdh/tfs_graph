module TFSGraph
  module Populators

    # incremental updates for a branch and its changesets
    # does not update merges. have to do that once all changesets
    # for a project are fetched
    class ForBranch
      include Utilities

      def initialize(project, branch)
        @project = project
        @branch = branch

        @changeset_store = ChangesetStore.new(branch)
      end

      def populate
        new_changesets = @changeset_store.fetch_since_last_update
        @changeset_store.cache_all new_changesets

        all_changesets = @branch.changesets
        ChangesetTreeBuilder.to_tree(@branch, all_changesets)

        @branch.updated!
        all_changesets
      end
    end
  end
end