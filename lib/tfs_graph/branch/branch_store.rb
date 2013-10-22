require 'tfs_graph/tfs_client'
require 'tfs_graph/store_helpers'

require 'tfs_graph/branch/branch_normalizer'
require 'tfs_graph/branch'

module TFSGraph
  class BranchStore
    include TFSClient
    include StoreHelpers

    LIMIT = 150

    def initialize(project)
      @project = project
    end

    def cache
      branches = root_query.run
      persist(branches)
    end

    def cache_since_last_update
      branches = root_query.where("CreatedDate gt DateTime'#{last_updated_on.iso8601}'").run
      persist(branches)
    end

    private
    def root_query
      tfs.projects(@project.name).branches.limit(LIMIT)
    end

    def persist(branches)
      normalized = BranchNormalizer.normalize_many branches

      saved = normalized.map do |branch_attrs|
        branch = Branch.create branch_attrs
        Related::Relationship.create(:branches, @project, branch)
        branch
      end

      mark_as_updated

      saved
    end
  end
end