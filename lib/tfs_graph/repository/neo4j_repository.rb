require 'neo4j-core'
require 'tfs_graph/repository'

module TFSGraph
  class Repository
    class Neo4jRepository < Repository
      def find_native(id)
        node = Neo4j::Node.load(id)
        raise NotFound, id unless node
        node
      end

      def root
        @root ||= Neo4j::Node.create({name: "Root node"}, :root)
      end

      def relate(relationship, parent, child)
        Neo4j::Relationship.create relationship, parent, child
      end

      def get_nodes(entity, direction, relation, type)
        entity.nodes(dir: direction.to_sym, type: relation.to_sym).map do |node|
          type.repository.rebuild node
        end
      end

      def rebuild(db_object)
        attributes = HashWithIndifferentAccess.new db_object.props

        obj = build attributes
        obj.persist db_object
      end

      private
      # persist and update both expose the DB object from Redis/Related
      # make methods private so we have to use save to persist

      # create the DB object
      def persist(object)
        Neo4j::Node.create(object.to_hash, object.class.name)
      end

      # update the DB object
      def update(object)
        db_object = object.db_object
        db_object.update_props object.attributes

        db_object
      end
    end
  end
end