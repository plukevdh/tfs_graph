require 'tfs_graph/entity'
require 'tfs_graph/tfs_helpers'

module TFSGraph
  class Branch < Entity
    extend TFSHelpers
    extend Comparable

    SCHEMA = {
      original_path: {key: "Path", type: String},
      path: {key: "Path", converter: ->(path) { repath_archive(path) }, type: String},
      project: {converter: ->(path) { branch_project(path) }, key: "Path", type: String},
      name: {converter: ->(path) { branch_path_to_name(path) }, key: "Path", type: String},
      root: {converter: ->(path) { repath_archive(server_path_to_odata_path(path)) if path }, key: "ParentBranch", type: String},
      created: {key: "DateCreated", type: DateTime},
      type: {default: "Feature", type: Integer},
      archived: {default: false, type: String},
      hidden: {default: false, type: String}
    }

    BRANCH_TYPES = [
      :master,
      :release,
      :feature
    ]

    ARCHIVED_FLAGS = ["Archive"]
    RELEASE_MATCHER = /^(.+)-r-(\d+)$/i

    act_as_entity

    before_create :detect_type, :detect_archived

    BRANCH_TYPES.each do |t|
      define_method "#{t}?".to_sym do
        BRANCH_TYPES.at(type) == t
      end
    end

    def archived?
      archived.to_s == "true"
    end

    def hidden?
      hidden.to_s == "true"
    end

    def named_type
      BRANCH_TYPES[type]
    end

    def hide!
      self.hidden = true
      save
    end

    def archive!
      self.archived = true
      save
    end

    def rootless?
      !master? && root.empty?
    end

    def type_index(name)
      BRANCH_TYPES.index(name.to_sym)
    end

    # returns a branch
    def absolute_root
      @absolute_root ||= begin
        item = self
        proj = ProjectStore.find_cached project

        until(item.master?) do
          item = proj.branches.detect {|branch| branch.path == item.root }
        end

        item
      end
    end

    def branch?
      !master?
    end

    # branches this one touches or is touched
    def related_branches
      incoming(:related).options(model: Branch).nodes.to_a.map &:id
    end

    def changesets
      outgoing(:changesets).options(model: Changeset).nodes.to_a
    end

    def contributors
      changesets.group_by(&:committer)
    end

    def root_changeset
      @root ||= outgoing(:child).options(model: Changeset).nodes.to_a.first
    end

    def last_changeset
      changesets.last
    end

    def ahead_of_master
      return 0 unless absolute_root
      self.outgoing(:changesets)
        .diff(absolute_root.outgoing(:included)
          .intersect(self.outgoing(:changesets)))
        .to_a.count
    end

    # gets the set of changesets that exist in both root and self
    # then gets a diff of that set and the root.
    def behind_master
      return 0 unless absolute_root
      absolute_root.outgoing(:changesets)
        .diff(self.outgoing(:included)
          .intersect(absolute_root.outgoing(:changesets)))
        .to_a.count
    end

    def <=>(other)
      path <=> other.path
    end

    def as_json(options={})
      options.merge! methods: :related_branches
      super
    end

    private
    def detect_type
      return self.type = type_index(:master) if (root.empty?)
      return self.type = type_index(:release) if !(name =~ RELEASE_MATCHER).nil?
      self.type = type_index(:feature)
      nil
    end

    def detect_archived
      self.archived = ARCHIVED_FLAGS.any? {|flag| original_path.include? flag }
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