module TFSGraph
  module Populators
    module Utilities
      include StoreHelpers

      def clean
        ServerRegistry.server.flush
      end

      def finalize
        BranchArchiveHandler.hide_all_archives
        mark_as_updated
      end

      def collect_projects
        ProjectStore.cache
      end

      def collect_branches(project)
        BranchStore.new(project).cache_all
      end

      def collect_changesets(branch, method=:cache_all, *args)
        changesets = ChangesetStore.new(branch).send(method, *args)
        generate_branch_tree(branch)
        changesets.compact
      end

      def generate_branch_tree(branch)
        ChangesetTreeBuilder.to_tree branch
      end

      def collect_merges(branch)
        ChangesetMergeStore.new(branch).cache
      end
    end
  end
end