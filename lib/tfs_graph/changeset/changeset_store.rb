require 'tfs_graph/abstract_store'

require 'tfs_graph/changeset/changeset_normalizer'
require 'tfs_graph/changeset'

# Wraps domain knowledge of changeset TFS access

module TFSGraph
  class ChangesetStore < AbstractStore
    LIMIT = 10000

    def initialize(branch)
      @branch = branch
    end

    def fetch_since_last_update
      fetch_since_date(@branch.last_updated.iso8601)
    end

    def fetch_since_date(date)
      normalize root_query.where("CreationDate gt DateTime'#{date}'").run
    end

    def cache(attrs)
      changeset = RepositoryRegistry.changeset_repository.build attrs

      # add_changeset action runs save! on changeset
      @branch.add_changeset changeset

      changeset
    end

    private
    def root_query
      tfs.branches(@branch.path).changesets.order_by("Id asc").limit(LIMIT)
    end

    def normalize(changesets)
      ChangesetNormalizer.normalize_many changesets, @branch.path
    end
  end
end
