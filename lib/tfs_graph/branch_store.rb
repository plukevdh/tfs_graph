require 'tfs_graph/tfs_client'
require 'tfs_graph/branch_normalizer'
require 'tfs_graph/branch'

module TFSGraph
  class BranchStore
    extend TFSClient

    class << self
      def fetch(project)
        query = tfs.projects(project).branches.limit(150)

        branches = add_filters(query, Branch::ARCHIVED_FLAGS).run
        normalized = BranchNormalizer.normalize_many branches

        normalized.map {|branch_attrs| Branch.create branch_attrs }
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