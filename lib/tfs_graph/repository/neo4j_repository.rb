require 'neo4j-core'
require 'tfs_graph/repository'

module TFSGraph
  class Repository
    class Neo4jRepository < Repository
      def find_native(id)
        node = Neo4j::Label.query(type.base_class_name.to_sym, conditions: {id: id}).to_a.first
        node ||= find_by_neo_id(id)

        raise NotFound, id unless node
        node
      end

      def find_by_neo_id(id)
        Neo4j::Node.load(id)
      end

      def root
        @root ||= Neo4j::Node.create({name: "Root node"}, :root)
      end

      def relate(relationship, parent, child)
        Neo4j::Relationship.create relationship, parent, child unless related?(parent, child, relationship)
      end

      def get_nodes(entity, direction, relation, type)
        entity.nodes(dir: direction.to_sym, type: relation.to_sym).map do |node|
          type.repository.rebuild node
        end
      end

      def get_relation(entity, direction, relation)
        entity.rels(dir: direction.to_sym, type: relation.to_sym).first
      end

      def get_nodes_for(relation, type)
        nodes = []

        Neo4j::Transaction.run do
          nodes = relation.nodes.map do |node|
            type.repository.rebuild node
          end
        end

        nodes
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
        Neo4j::Node.create(object.to_hash, object.base_class_name)
      end

      # update the DB object
      def update(object)
        db_object = object.db_object
      end

        db_object.update_props  object.attributes
        db_object
      def decompose_db_object(object)
        return nil, nil unless object
        return object.neo_id, object
      end
    end
  end
end