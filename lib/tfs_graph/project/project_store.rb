require 'tfs_graph/abstract_store'

require 'tfs_graph/project/project_normalizer'
require 'tfs_graph/abstract_store'

module TFSGraph
  class ProjectStore < AbstractStore
    def cache(project)
      RepositoryRegistry.project_repository.create project
    end

    private
    def root_query
      tfs.projects
    end

    def normalize(projects)
      ProjectNormalizer.normalize_many projects
    end
  end
end