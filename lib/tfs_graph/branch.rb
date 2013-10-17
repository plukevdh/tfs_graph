require 'tfs_graph/entity'
require 'tfs_graph/helpers'

module TFSGraph
  class Branch < Entity
    extend Helpers
    extend Comparable

    SCHEMA = {
      original_path: {key: "Path", type: String},
      path: {key: "Path", converter: -> (path) { repath_archive(path) }, type: String},
      project: {converter: -> (path) { branch_project(path) }, key: "Path", type: String},
      name: {converter: -> (path) { branch_path_to_name(path) }, key: "Path", type: String},
      root: {converter: -> (path) { repath_archive(server_path_to_odata_path(path)) if path }, key: "ParentBranch", type: String},
      created: {key: "DateCreated", type: DateTime},
      type: {default: "Feature", type: Integer},
      archived: {default: false, type: String}
    }

    BRANCH_TYPES = [
      :feature,
      :root,
      :release
    ]

    ARCHIVED_FLAGS = ["Archive"]
    RELEASE_MATCHER = /^(\w+)-r-(\d+)$/i

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

    def named_type
      BRANCH_TYPES[type]
    end

    def rootless?
      !root? && root.empty?
    end

    def type_index(name)
      BRANCH_TYPES.index(name.to_sym)
    end

    # returns a branch
    def absolute_root
      @absolute_root ||= begin
        item = self
        proj = ProjectStore.find_cached project

        until(item.root?) do
          item = proj.branches.detect {|branch| branch.path == item.root }
        end

        item
      end
    end

    def branch?
      !root?
    end

    def changesets
      @changesets ||= outgoing(:changesets).options(model: Changeset).nodes.to_a
    end

    def root_changeset
      @root ||= outgoing(:child).options(model: Changeset).nodes.to_a.first
    end

    def <=>(other)
      path <=> other.path
    end

    private
    def detect_type
      return self.type = type_index(:root) if (root.empty?)
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