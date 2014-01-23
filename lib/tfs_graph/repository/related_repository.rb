require 'related'

module TFSGraph
  class Repository
    class RelatedRepository < Repository
      def save(object)
        node = Related::Node.create object.to_hash
        super object, node.id
      end

      class EntityMethods < Related::Node
        def self.add_property
          property key, details[:type]
        end

        def get_nodes(direction, relation, type=self.class)
          get_nodes_for(get_relation(direction, relation), type)
        end

        def get_nodes_for(relation, type=self.class)
          relation.options(model: type).nodes.to_a
        end

        def get_relation(direction, relation)
          send(direction.to_sym, relation.to_sym)
        end
      end
    end
  end
end