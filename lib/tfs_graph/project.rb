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

    %w(master release feature).each do |type|
      define_method "#{type}s" do
        branches.select {|b| b.send "#{type}?" }
      end

      define_method "#{type}s_with_hidden" do
        branches_with_hidden.select {|b| b.send "#{type}?" }
      end

      define_method "archived_#{type}s" do
        branches.select {|b| b.send("#{type}?") && b.archived? }
      end
    end
  end
end