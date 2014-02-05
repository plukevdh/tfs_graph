require 'tfs_graph/entity'

module TFSGraph
  class Project < Entity
    NeverUpdated = Class.new

    SCHEMA = {
      name: {key: "Name"},
      last_updated: {type: DateTime, default: NeverUpdated}
    }

    alias_method :id, :internal_id
    act_as_entity

    def <=>(other)
      id <=> other.id
    end

    def last_updated
      @last_updated || NeverUpdated
    end

    end

    def last_change
      branches.map {|b| b.last_changeset }
    def add_branch(branch)
      branch.project = self.name
      branch.save!

      @repo.relate(:branches, self, branch)
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
      @repo.get_nodes(db_object, :outgoing, :branches, Branch)
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