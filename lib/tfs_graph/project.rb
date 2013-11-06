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

    def last_change
      branches.map {|b| b.last_changeset }
    end

    def all_activity
      branches.map {|b| b.changesets }.flatten
    end

    def all_activity_by_date
      all_activity.group_by(&:formatted_created)
    end

    def branches
      branches_with_hidden.reject(&:hidden?)
    end

    def branches_with_hidden
      outgoing(:branches).options(model: Branch).nodes.to_a
    end

    def roots
      branches.select &:master?
    end
  end
end