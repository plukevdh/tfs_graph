module TFSGraph
  class Branch
    module Behaviors
      def absolute_root_for(branch)
        root = branch
        proj = RepositoryRegistry.project_repository.find_by_name, branch.project

        until(root.master?) do
          root = proj.branches.detect {|b| b.path == root.root }
        end

        root
      end
    end
  end
end