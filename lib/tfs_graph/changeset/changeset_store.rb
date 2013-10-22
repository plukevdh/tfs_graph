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

    def cache
      changesets = root_query.run
      persist(changesets)
    end

    def cache_since_last_update
    	changesets = root_query.where("CreationDate gt DateTime'#{last_updated_on.iso8601}'").run
    	persist(changesets)
    end

    private
    def root_query
    	tfs.branches(@branch.path).changesets.limit(LIMIT)
    end

    def persist(changesets)
      normalized = ChangesetNormalizer.normalize_many changesets, @branch.path
      normalized.map do |attrs|
      	begin
      		changeset = Changeset.create attrs
					Related::Relationship.create :changesets, @branch, changeset
					changeset
      	rescue Related::ValidationsFailed => ex
      		puts ex.message
      		next
      	end
      end.compact
    end
	end
end