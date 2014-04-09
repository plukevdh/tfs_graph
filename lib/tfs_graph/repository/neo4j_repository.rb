require 'neo4j-core'
require 'tfs_graph/repository'

module TFSGraph
  class Repository
    class Neo4jRepository < Repository
      def find_native(id)
        node = Neo4j::Label.query(type.base_class_name.downcase.to_sym, conditions: {id: id}).to_a.first
        node ||= find_by_neo_id(id)

        raise NotFound, id unless node
        node
      end

      def find_by_neo_id(id)
        Neo4j::Node.load(id)
      end

      def session
        Neo4j::Session.current
      end

      def flush
        @root = nil
      end
      def drop_all
        flush
        session.query("MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r")
      end

      def root
        @root ||= begin
          node = Neo4j::Label.find_all_nodes(:root).first
          node = Neo4j::Node.create({name: "Root node"}, :root) if node.nil?
          node
        end
      end

      def relate(relationship, parent, child)
        Neo4j::Relationship.create relationship, parent, child unless related?(parent, child, relationship)
      end

      def get_nodes(entity, direction, relation, type)
        begin
          entity.nodes(dir: direction.to_sym, type: relation.to_sym).map do |node|
            type.repository.rebuild node
          end
        rescue Neo4j::Server::CypherResponse::ResponseError => e
          []
        end
      end

      def rebuild(db_object)
        attributes = normalize db_object.props

        obj = build attributes
        obj.persist get_id(db_object), db_object
      end

      def rebuild_from_query(attrs, id)
        obj = build normalize(attrs)
        obj.persist id, nil
      end

      private
      # persist and update both expose the DB object from Neo4j
      # make methods private so we have to use save to persist

      # create the DB object
      def persist(object)
        begin
          Neo4j::Node.create(object.to_hash, object.base_class_name.downcase)
        rescue Neo4j::Server::CypherResponse::ResponseError => e
          # assume all errors come from constraint errors... probably a bad idea
          fetch_existing_record(object)
        end
      end

      # update the DB object
      def update(object)
        object.db_object.update_props object.attributes
        object.db_object
      end

      def get_id(object)
        return 0 if object.nil?
        object.neo_id
      end
    end
  end
end