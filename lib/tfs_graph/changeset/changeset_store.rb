require 'tfs_graph/tfs_client'
require 'tfs_graph/store_helpers'

require 'tfs_graph/changeset/changeset_normalizer'
require 'tfs_graph/changeset'
# Wraps domain knowledge of changeset TFS access

module TFSGraph
  class ChangesetStore
    include TFSClient
    include StoreHelpers

    LIMIT = 10000

    def initialize(branch)
      @branch = branch
    end

    def cache_all
      persist all
    end

    def cache_since_last_update
      persist since_last_update
    end

    def all
      normalize root_query.run
    end

    def since_last_update
      normalize root_query.where("CreationDate gt DateTime'#{last_updated_on.iso8601}'").run
    end

    private
    def root_query
      tfs.branches(@branch.path).changesets.limit(LIMIT)
    end

    def normalize(changesets)
      ChangesetNormalizer.normalize_many changesets, @branch.path
    end

    def persist(changesets)
      changesets.map do |attrs|
        begin
          changeset = Changeset.create attrs
          Related::Relationship.create :changesets, @branch, changeset
          changeset
        rescue Related::ValidationsFailed => ex
          # puts ex.message
          next
        end
      end.compact
    end
  end
end
