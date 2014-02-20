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