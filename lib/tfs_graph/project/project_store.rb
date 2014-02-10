require 'tfs_graph/tfs_client'
require 'tfs_graph/project/project_normalizer'

module TFSGraph
  class ProjectStore
    extend TFSClient

    class << self
      def cache
        projects = tfs.projects.run
        normalized = ProjectNormalizer.normalize_many projects

        normalized.map do |project_attrs|
          RepositoryRegistry.project_repository.create project_attrs
        end
      end
    end
  end
end