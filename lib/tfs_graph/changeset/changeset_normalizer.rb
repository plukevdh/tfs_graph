require 'tfs_graph/normalizer'

module TFSGraph
  class ChangesetNormalizer < Normalizer
    class << self
      def normalize_many(data, branch)
        changesets = data.map {|item| normalize(item, branch) }
      end

      def normalize(item, branch)
        item = super(item)
        item[:branch_path] = branch
        item[:comment] = item[:comment].gsub(/\\+/, "|")
        item
      end

      def schema
        Changeset::SCHEMA
      end
    end
  end
end