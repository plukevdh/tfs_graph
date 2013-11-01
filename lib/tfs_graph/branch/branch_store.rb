require 'tfs_graph/tfs_client'
require 'tfs_graph/helpers'

require 'tfs_graph/branch/branch_normalizer'
require 'tfs_graph/branch'

module TFSGraph
  class BranchStore
    include TFSClient
    include Helpers

    LIMIT = 150

    def initialize(project)
      @project = project
    end

    def cache_all
      persist(all)
    end

    def cache_since_last_update
      persist since_last_update
    end

    def all
      normalize root_query.run
    end

    def since_last_update
      normalize root_query.where("DateCreated gt DateTime'#{last_updated_on.iso8601}'").run
    end

    private
    def root_query
      tfs.projects(@project.name).branches.limit(LIMIT)
    end

    def normalize(branches)
      BranchNormalizer.normalize_many branches
    end

    def persist(branches)
      branches.map do |branch_attrs|
        branch = Branch.create branch_attrs
        Related::Relationship.create(:branches, @project, branch)
        branch
      end
    end
  end
end