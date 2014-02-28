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

        def branches_for_root(project, branch, archived=false, hidden=false)
          branches = session.query "#{root_branch_query(archived, hidden)} RETURN b as `branch`, ID(b) as `neo_id`",
            project: project.name,
            path: branch.path

          branches.each_slice(2).map do |data,id|
            RepositoryRegistry.branch_repository.rebuild_from_query data[:branch]['data'], id[:neo_id]
          end
        end

        def changesets_for_root(project, branch, archived=false, hidden=false)
          changesets = session.query "#{root_branch_query(archived, hidden)} MATCH b-[:changesets]->(c:changeset) RETURN c AS `changeset`, ID(b) as `neo_id` ORDER BY c.id",
            project: project.name,
            path: branch.path

          changesets.each_slice(2).map do |data,id|
            RepositoryRegistry.changeset_repository.rebuild_from_query data[:changeset]['data'], id[:neo_id]
          end
        end

        def activity(project)
          changesets = session.query "MATCH (a)-[:branches]->(b)-[:changesets]->(c) where a.name = {name} RETURN c as `changeset`, ID(b) as `neo_id`",
            name: project.name

          changesets.each_slice(2).map do |data,id|
            RepositoryRegistry.changeset_repository.rebuild_from_query data[:changeset]['data'], id[:neo_id]
          end
        end

        def activity_by_date(project, time)
          changesets = session.query "MATCH (a)-[:branches]->(b)-[:changesets]->(c) WHERE a.name = {name} AND c.created >= {time} RETURN c as `changeset`, ID(b) as `neo_id`",
            { name: project.name, time: time.utc.to_i }

          changesets.each_slice(2).map do |data,id|
            RepositoryRegistry.changeset_repository.rebuild_from_query data[:changeset]['data'], id[:neo_id]
          end
        end

        private
        def fetch_existing_record(obj)
          find_by_name(obj.name).db_object
        end

        def root_branch_query(include_archived=true, include_hidden=true)
          "MATCH (p:project {name: {project}})-[:branches]->(b:branch {archived: '#{include_archived}', hidden: '#{include_hidden}'}) WHERE b.original_path = {path} OR b.root = {path}"
        end
      end
    end
  end
end