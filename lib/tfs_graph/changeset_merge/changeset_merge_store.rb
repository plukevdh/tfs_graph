require 'tfs_graph/tfs_client'
require 'tfs_graph/changeset_merge/changeset_merge_normalizer'
require 'tfs_graph/changeset_merge'

module TFSGraph
  class ChangesetMergeStore
    include TFSClient

    LIMIT = 10000

    def initialize(branch)
      @branch = branch
    end

    def cache
      merges = tfs.branches(@branch.path).changesetmerges.limit(LIMIT).run
      normalized = ChangesetMergeNormalizer.normalize_many merges, @branch

      normalized.map do |attrs|
        ChangesetMerge.create(attrs)
      end.compact
    end
  end
end
