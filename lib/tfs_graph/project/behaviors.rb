module TFSGraph
  class Project
    module Behaviors
      def create(args)
        obj = super
        relate :projects, root, obj.db_object

        obj
      end

      def all
        get_nodes(root, :outgoing, :projects, TFSGraph::Project)
      end

      def find_by_name(name)
        project = all.detect {|p| p.name == name }
        raise Repository::NotFound, "No project found for #{name}" if project.nil?

        project
      end
    end
  end
end