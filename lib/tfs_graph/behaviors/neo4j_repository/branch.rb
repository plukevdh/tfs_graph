module TFSGraph
  class Behaviors
    class Neo4jRepository
      module Branch
        def find_in_project(project, path)
          # project.branches.detect {|b| b.path == path }
          rebuild Neo4j::Label.query(:branch, conditions: {path: path, project: project.name }).first
        end

        def find_by_path(path)
          branch = Neo4j::Label.query(:branch, conditions: {path: path}).first
          raise TFSGraph::Repository::NotFound, "No branch found for #{path}" if branch.nil?

          rebuild branch
        end

        def absolute_root_for(branch)
          root = branch
          proj = project_for_branch branch

          until(root.master?) do
            root = proj.branches.detect {|b| b.path == root.root }
          end

          root
        end

        def project_for_branch(branch)
          RepositoryRegistry.instance.project_repository.find_by_name branch.project
        end

        private
        def fetch_existing_record(obj)
          find_by_path(obj.path).db_object
        end
      end
    end
  end
end