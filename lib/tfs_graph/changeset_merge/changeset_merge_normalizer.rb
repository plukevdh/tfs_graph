require 'tfs_graph/normalizer'

module TFSGraph
  class ChangesetMergeNormalizer < Normalizer
    class << self
      def normalize_many(data, branch)
        changesets = data.map {|item| normalize(item, branch) }
      end

      def normalize(item, branch)
        item = super(item)
        item[:branch] = branch.name
        item
      end

      def schema
        ChangesetMerge::SCHEMA
      end
    end
  end
end