require 'tfs_graph/entity'

module TFSGraph
  class Project < Entity
    SCHEMA = {
      name: {key: "Name"},
      last_updated: {type: DateTime}
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

    def all_activity_by_date(limiter=nil)
      raise InvalidArgument("parameter must be a Date") unless limiter.nil? || limiter.is_a?(Time)

      activity = all_activity
      activity = activity.select {|c| c.created > limiter } unless limiter.nil?

      activity.group_by(&:formatted_created)
    end

    def active_branches
      branches.reject(&:archived?)
    end

    def branches
      branches_with_hidden.reject(&:hidden?)
    end

    def branches_with_hidden
      get_nodes(:outgoing, :branches, Branch)
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