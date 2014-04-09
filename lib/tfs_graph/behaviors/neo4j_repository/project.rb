module TFSGraph
  class Behaviors
    class Neo4jRepository
      module Project
        ROOT_BRANCH_QUERY = "MATCH (p:project {name: {project}})-[:branches]->(b:branch) WHERE (b.original_path = {path} OR b.root = {path})"
        ACTIVITY_QUERY = "MATCH (a:project)-[:branches]->(b:branch)-[:changesets]->(c:changeset) where a.name = {name}"

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

        def branches_for_root(project, branch)
          branches = session.query "#{ROOT_BRANCH_QUERY} RETURN b as `branch`, ID(b) as `neo_id`",
            project: project.name,
            path: branch.path

          rebuild_for_type RepositoryRegistry.branch_repository, branches, :branch
        end

        def active_branches_for_root(project, branch)
          branches = session.query "#{ROOT_BRANCH_QUERY} AND b.archived = 'false' AND b.hidden = 'false' RETURN b as `branch`, ID(b) as `neo_id`",
            project: project.name,
            path: branch.path

          rebuild_for_type RepositoryRegistry.branch_repository, branches, :branch
        end

        def changesets_for_root(project, branch)
          changesets = session.query "#{ROOT_BRANCH_QUERY} MATCH b-[:changesets]->(c:changeset) RETURN c AS `changeset`, ID(b) as `neo_id` ORDER BY c.id",
            project: project.name,
            path: branch.path

          rebuild_for_type RepositoryRegistry.changeset_repository, changesets, :changeset
        end

        def activity(project)
          changesets = session.query "#{ACTIVITY_QUERY} RETURN c as `changeset`, ID(b) as `neo_id`",
            name: project.name

          rebuild_for_type RepositoryRegistry.changeset_repository, changesets, :changeset
        end

        def activity_by_date(project, time)
          changesets = session.query "#{ACTIVITY_QUERY} AND c.created >= {time} RETURN c as `changeset`, ID(b) as `neo_id`",
            { name: project.name, time: time.utc.to_i }

          rebuild_for_type RepositoryRegistry.changeset_repository, changesets, :changeset
        end

        private
        def rebuild_for_type(repo, data, key)
          data.each_slice(2).map do |data,id|
            repo.rebuild_from_query data[key]['data'], id[:neo_id]
          end
        end

        def fetch_existing_record(obj)
          find_by_name(obj.name).db_object
        end
      end
    end
  end
end