require 'tfs_graph/abstract_store'

require 'tfs_graph/changeset_merge/changeset_merge_normalizer'
require 'tfs_graph/changeset_merge'

module TFSGraph
  class ChangesetMergeStore < AbstractStore
    LIMIT = 10000

    def initialize(branch)
      @branch = branch
    end

    def cache
      ChangesetMerge.create(attrs)
    end

    private
    def root_query
      tfs.branches(@branch.path).changesetmerges.limit(LIMIT)
    end

    def normalize(merges)
      ChangesetMergeNormalizer.normalize_many merges, @branch
    end
  end
end
