module TFSGraph
  class Repository
    class Neo4jRepository < Repository

      def initialize(session_or_server)
        @repo = session_or_server.is_a?(String) ?
        Neo4j::Session.open(:server_db, session_or_server) :
        session_or_server
      end

      def relationship_type
        Neo4j::Relationship
      end

      class EntityMethods < Neo4j::NodeMixin
        def self.add_property
          property key, type: details[:type]
        end
      end
    end
  end
end