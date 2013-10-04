require 'tfs_graph/tfs_client'
require 'tfs_graph/branch_normalizer'
# Wraps domain knowledge of branch TFS access

module TFSGraph
  class BranchStore
    extend TFSClient

    class << self
      def fetch(project)
        query = tfs.projects(project).branches.limit(150)

        branches = add_filters(query, Branch::ARCHIVED_FLAGS).run

        BranchNormalizer.normalize_many branches
      end

      private
      def add_filters(query, flags)
        flags.each do |flag|
          query.where("substringof('#{flag}',Path) eq false")
        end
        query
      end
    end
  end
end