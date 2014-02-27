require 'tfs_graph/abstract_store'

require 'tfs_graph/branch/branch_normalizer'
require 'tfs_graph/branch'

module TFSGraph
  class BranchStore < AbstractStore
    LIMIT = 1000

    def initialize(project)
      @project = project
    end

    def fetch_since_last_update
      fetch_since_date(@project.last_updated.iso8601)
    end

    def fetch_since_date(date)
      normalize root_query.where("CreationDate gt DateTime'#{date}'").run
    end

    def cache(attrs)
      branch = RepositoryRegistry.branch_repository.build attrs

      # add_branch action runs save! on branch
      @project.add_branch(branch)

      branch
    end

    private
    def root_query
      tfs.projects(@project.name).branches.order_by('DateCreated desc').limit(LIMIT)
    end

    def normalize(branches)
      BranchNormalizer.normalize_many branches
    end
  end
end