require 'tfs_graph/tfs_client'
require 'tfs_graph/changeset_normalizer'
require 'tfs_graph/changeset'
# Wraps domain knowledge of changeset TFS access

module TFSGraph
	class ChangesetStore
	  extend TFSClient

	  class << self
	    def fetch(branch)
	      changesets = tfs.branches(branch.path).changesets.order_by("Id asc").limit(10000).run

	      normalized = ChangesetNormalizer.normalize_many changesets, branch.name
	      normalized.map do |attrs|
	      	begin
	      		Changeset.create attrs.dup
	      	rescue Related::ValidationsFailed => ex
	      		puts ex.message
	      		next
	      	end
	      end.compact
	    end
	  end
	end
end