module TFSGraph
  class Behaviors
    class Neo4jRepository
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
          project = Neo4j::Label.query(:project, conditions: {name: name}).first
          raise TFSGraph::Repository::NotFound, "No project found for #{name}" if project.nil?

          rebuild project
        end

        def activity(project)
          changesets = session.query "MATCH (a)-[:branches]->(b)-[:changesets]->(c) where a.name = {name} RETURN c as `changeset`",
            name: project.name

          changesets.map {|cs| RepositoryRegistry.changeset_repository.rebuild_from_query cs[:changeset]['data'] }
        end

        def activity_by_date(project, time)
          changesets = session.query "MATCH (a)-[:branches]->(b)-[:changesets]->(c) WHERE a.name = {name} AND c.created >= {time} RETURN c as `changeset`",
            { name: project.name, time: time.utc.to_i }

          changesets.map {|cs| RepositoryRegistry.changeset_repository.rebuild_from_query cs[:changeset]['data'] }
        end
      end
    end
  end
end