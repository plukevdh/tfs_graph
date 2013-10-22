require 'tfs_graph/project'
require 'tfs_graph/normalizer'

module TFSGraph
  class ProjectNormalizer < Normalizer
    class << self
      def schema
        Project::SCHEMA
      end
    end
  end
end