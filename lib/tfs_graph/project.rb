require 'tfs_graph/persistable_entity'

module TFSGraph
  class Project < PersistableEntity
    SCHEMA = {
      name: {key: "Name"},
      last_updated: {type: Time, default: Time.at(0).utc},
      hidden: {default: false, type: String}
    }

    act_as_entity

    def <=>(other)
      id <=> other.id
    end

    def updated!
      @last_updated = Time.now.utc
      save!
    end

    # force string
    def hidden
      @hidden.to_s
    end

    def hidden?
      @hidden.to_s == "true"
    end

    def add_branch(branch)
      branch.project = self.name
      branch.save!

      @repo.relate(:branches, db_object, branch.db_object)
    end

    def all_activity
      @repo.activity(self)
    end

    def all_activity_by_date(limiter=nil)
      raise InvalidArgument("parameter must be a Date") unless limiter.nil? || limiter.is_a?(Time)

      @repo.activity_by_date(self, limiter).group_by(&:formatted_created)
    end

    def active_branches
      branches.reject(&:archived?)
    end

    def branches
      branches_with_hidden.reject(&:hidden?)
    end

    def branches_for_root(root)
      @repo.branches_for_root(self, root)
    end

    def changesets_for_root(root)
      @repo.changesets_for_root(self, root)
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

      define_method "active_#{type}s" do
        active_branches.select {|b| b.send("#{type}?") }
      end

      define_method "archived_#{type}s" do
        branches.select {|b| b.send("#{type}?") && b.archived? }
      end
    end
  end
end