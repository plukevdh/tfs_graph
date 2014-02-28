module TFSGraph
  module Populators
    module Utilities
      include StoreHelpers

      def clean
        flush_all
      end

      def finalize
        mark_as_updated
      end

      def find_project(name)
        TFSGraph::RepositoryRegistry.project_repository.find_by_name name
      end

      def find_branch(path)
        TFSGraph::RepositoryRegistry.branch_repository.find_by_path path
      end
    end
  end
end