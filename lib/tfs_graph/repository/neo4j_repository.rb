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
        attributes = HashWithIndifferentAccess.new db_object.props

        obj = build attributes
        obj.persist *decompose_db_object(db_object)
      end

      private
      # persist and update both expose the DB object from Redis/Related
      # make methods private so we have to use save to persist

      # create the DB object
      def persist(object)
        rescue_format_issues(object) do
          Neo4j::Node.create(object.to_hash, object.base_class_name.downcase)
        end
      end

      # update the DB object
      def update(object)
        rescue_format_issues(object) do
          object.db_object.update_props object.attributes
          object.db_object
        end
      end

      def rescue_format_issues(object, &block)
        begin
          block.call
        rescue Neo4j::Server::CypherResponse::ResponseError => e
          puts "Could not update #{object.inspect}: #{e.message}."
        end
      end

      def decompose_db_object(object)
        return nil, nil unless object
        return object.neo_id, object
      end
    end
  end
end