module TFSGraph
  class Behaviors
    class RelatedRepository
      module Project
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
          raise TFSGraph::Repository::NotFound, "No project found for #{name}" if project.nil?

          project
        end

        def branches_for_root(project, root)
          project.branches.select {|b| b.root == branch.path || b.original_path == branch.path}
        end

        def changesets_for_root(project, root)
          branches_for_root(project, root).map(&:changesets).flatten.sort
        end

        def activity(project)
          project.branches.map {|b| b.changesets }.flatten
        end

        def activity_by_date(project, date)
          activity = activity(project)
          activity = activity.select {|c| c.created > date } unless date.nil?

          activity
        end
      end
    end
  end
end