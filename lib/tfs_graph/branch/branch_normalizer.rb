require 'tfs_graph/normalizer'

module TFSGraph
	class BranchNormalizer < Normalizer
	  class << self
	    def schema
	      Branch::SCHEMA
	    end
	  end
	end
end