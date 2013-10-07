require 'tfs_graph/normalizer'

module TFSGraph
  class ChangesetNormalizer < Normalizer
    class << self
      def normalize_many(data, branch)
        changesets = data.map {|item| normalize(item, branch) }
      end

      def normalize(item, branch)
        item = super(item)
        item[:branch] = branch
        item
      end

      def schema
        Changeset::SCHEMA
      end
    end
  end
end