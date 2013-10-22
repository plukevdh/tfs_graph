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
          project = Project.create project_attrs
          Related::Relationship.create(:projects, Related.root, project)

          project
        end
      end

      def all_cached
        Related.root.outgoing(:projects).options(model: Project).nodes.to_a
      end

      def find_cached(name)
        all_cached.detect {|p| p.name == name }
      end
    end
  end
end