require 'tfs_graph/entity'

module TFSGraph
  class Project < Entity
    extend Comparable
    SCHEMA = {
      name: {key: "Name"}
    }

    act_as_entity

    def <=>(other)
      name <=> other.name
    end

    def branches
      outgoing(:branches).options(model: Branch).nodes.to_a
    end

    def roots
      branches.select &:root?
    end
  end
end