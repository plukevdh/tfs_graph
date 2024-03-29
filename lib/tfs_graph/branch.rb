require 'tfs_graph/persistable_entity'
require 'tfs_graph/tfs_helpers'

module TFSGraph
  class Branch < PersistableEntity
    extend TFSHelpers

    SCHEMA = {
      original_path: {key: "Path", type: String},
      path: {key: "Path", converter: ->(path) { repath_archive(path) }, type: String},
      project: {converter: ->(path) { branch_project(path) }, key: "Path", type: String},
      name: {converter: ->(path) { branch_path_to_name(path) }, key: "Path", type: String},
      root: {converter: ->(path) { repath_archive(server_path_to_odata_path(path)) if path }, key: "ParentBranch", type: String},
      created: {key: "DateCreated", type: Time},
      type: {default: "Feature", type: Integer},
      archived: {default: false, type: String},
      hidden: {default: false, type: String},
      last_updated: {type: Time, default: Time.at(0).utc}
    }

    BRANCH_TYPES = [
      :master,
      :release,
      :feature
    ]

    ARCHIVED_FLAGS = ["Archive"]
    RELEASE_MATCHER = /^(.+)-r(\d+)-(\d+)$/i

    act_as_entity

    def initialize(repo, args)
      super

      detect_type
      detect_archived
    end

    BRANCH_TYPES.each do |t|
      define_method "#{t}?".to_sym do
        BRANCH_TYPES.at(type) == t
      end
    end

    def archived
      @archived.to_s
    end

    def hidden
      @hidden.to_s
    end

    def archived?
      archived.to_s == "true"
    end

    def hidden?
      hidden.to_s == "true"
    end

    def active?
      !hidden? && !archived?
    end

    def named_type
      BRANCH_TYPES[type]
    end

    def updated!
      @last_updated = Time.now.utc
      save!
    end

    def updated_since?(date)
      @last_updated > date
    end

    def hide!
      self.hidden = true
      save!
    end

    def archive!
      self.archived = true
      save!
    end

    def rootless?
      !master? && root.empty?
    end

    # returns a branch
    def absolute_root
      @absolute_root ||= @repo.absolute_root_for(self)
    end

    def branch?
      !master?
    end

    # branches this one touches or is touched
    def related_branches
      @repo.get_nodes(db_object, :incoming, :related, Branch).map &:id
    end

    def merged_changesets
      @repo.get_nodes(db_object, :outgoing, :included, Changeset)
    end

    def add_changeset(changeset)
      # attach branch path
      changeset.branch_path = self.path
      changeset.save!

      @repo.relate(:changesets, self.db_object, changeset.db_object)
    end

    def add_child(changeset)
      @repo.relate(:child, self.db_object, changeset.db_object)
    end

    def changesets
      @repo.get_nodes(db_object, :outgoing, :changesets, Changeset)
    end

    def contributors
      changesets.group_by(&:committer)
    end

    def root_changeset
      @root = @repo.get_nodes(db_object, :outgoing, :child, Changeset).first if (@root.nil? || @root.empty?)
    end

    def last_changeset
      changesets.last
    end

    def ahead_of_master
      return 0 unless absolute_root
      my_changes = changesets
      root_changes = absolute_root.merged_changesets

      # get intersection between root and this branch
      intersect = root_changes & my_changes
      # get difference of intersect with my changes
      diff = my_changes - intersect

      diff.count
    end

    # gets the set of changesets that exist in both root and self
    # then gets a diff of that set and the root.
    def behind_master
      return 0 unless absolute_root
      my_changes = merged_changesets
      root_changes = absolute_root.changesets

      # get intersect between my changes and the root
      intersect = my_changes & root_changes
      # get diff of root changes to intersect
      diff = root_changes - intersect

      diff.count
    end

    def <=>(other)
      path <=> other.path
    end

    def as_json(options={})
      results = super
      results[:related_branches] = related_branches
      results[:id] = id

      results
    end

    def type_index(name)
      BRANCH_TYPES.index(name.to_sym)
    end

    private

    def detect_type
      return self.type = type_index(:master) if (root.nil? || root.empty?)
      return self.type = type_index(:release) if !(name =~ RELEASE_MATCHER).nil?
      self.type = type_index(:feature)
      nil
    end

    def detect_archived
      self.archived = ARCHIVED_FLAGS.any? {|flag| original_path && original_path.include?(flag) }
      nil
    end

    def self.repath_archive(path)
      path = path.dup
      return path unless ARCHIVED_FLAGS.any? {|flag| path.include? flag }

      ARCHIVED_FLAGS.each {|flag| path.gsub!(/#{flag}>?(?:.*)>/, "") }
      path
    end
  end
end