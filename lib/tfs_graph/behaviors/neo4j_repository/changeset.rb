module TFSGraph
  class Behaviors
    class Neo4jRepository
      module Changeset
        private
        def fetch_existing_record(obj)
          find_native(obj.id)
        end
      end
    end
  end
end