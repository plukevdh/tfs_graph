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

        # skip rebuilding tree or marking as updated if no new were found
        return all_changesets if new_changesets.empty?

        ChangesetTreeBuilder.to_tree(@branch, all_changesets)

        @branch.updated!
        all_changesets
      end
    end
  end
end