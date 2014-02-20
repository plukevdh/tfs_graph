module TFSGraph
  class Behaviors
    class RelatedRepository
      module Branch
        def find_in_project(project, path)
          project.branches.detect {|b| b.path == path }
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
      end
    end
  end
end