require 'related'
require 'tfs_graph/repository'

module TFSGraph
  class Repository
    class RelatedRepository < Repository
      def save(object)
        super object, Related::Node.create(object.to_hash)
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
    end
  end
end