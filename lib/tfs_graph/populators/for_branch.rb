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
        populate_since(@branch.last_updated.iso8601)
      end

      def populate_since(time)
        new_changesets = @changeset_store.fetch_since_date(time)
        @changeset_store.cache_all new_changesets

        # skip rebuilding tree or marking as updated if no new were found
        return new_changesets if new_changesets.empty?

        ChangesetTreeBuilder.to_tree(@branch, @branch.changesets.sort)

        @branch.updated!
        new_changesets
      end
    end
  end
end