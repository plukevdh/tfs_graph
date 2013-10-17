require 'tfs_graph/tfs_client'
require 'tfs_graph/branch_normalizer'
require 'tfs_graph/branch'

module TFSGraph
  class BranchStore
    extend TFSClient

    class << self
      def cache(project)
        branches = tfs.projects(project.name).branches.limit(150).run
        normalized = BranchNormalizer.normalize_many branches

        normalized.map do |branch_attrs|
          branch = Branch.create branch_attrs
          Related::Relationship.create(:branches, project, branch)
          branch
        end
      end
    end
  end
end