require 'related'
require 'tfs_graph/repository'

module TFSGraph
  class Repository
    class RelatedRepository < Repository
      # updates or save the DB object
      def save(object)
        db_object = object.persisted? ? update(object) : persist(object)
        super object, db_object
      end

      def find(id)
        begin
          rebuild find_native(id)
        rescue Related::NotFound => e
          raise TFSGraph::Repository::NotFound, e.message
        end
      end

      def find_native(id)
        Related::Node.find(id)
      end

      def root
        Related.root
      end

      def relate(relationship, parent, child)
        Related::Relationship.create relationship, parent, child
      end

      def get_nodes(entity, direction, relation, type)
        get_nodes_for(get_relation(entity, direction, relation), type)
      end

      def get_nodes_for(relation, type)
        relation.nodes.map do |node|
          type.repository.rebuild node
        end
      end

      def get_relation(entity, direction, relation)
        entity.send(direction.to_sym, relation.to_sym)
      end

      private
      # persist and update both expose the DB object from Redis/Related
      # make methods private so we have to use save to persist

      # create the DB object
      def persist(object)
        Related::Node.create(object.to_hash)
      end

      # update the DB object
      def update(object)
        db_object = object.db_object

        object.attributes.each do |key, value|
          db_object.write_attribute key, value
        end

        db_object.save
        db_object
      end
    end
  end
end