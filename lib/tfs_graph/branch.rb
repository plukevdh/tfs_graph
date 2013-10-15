require 'tfs_graph/entity'
require 'tfs_graph/helpers'

module TFSGraph
  class Branch < Entity
    extend Helpers
    extend Comparable

    SCHEMA = {
      path: {key: "Path", converter: -> (path) { repath_archive(path) }, type: String},
      project: {converter: -> (path) { branch_project(path) }, key: "Path", type: String},
      name: {converter: -> (path) { branch_path_to_name(path) }, key: "Path", type: String},
      absolute_root: {converter: -> (path) { branch_base(path) if path }, key: "Path", type: String},
      root: {converter: -> (path) { server_path_to_name(path) if path }, key: "ParentBranch", type: String},
      created: {key: "DateCreated", type: DateTime}
      archived: {default: false, type: Boolean}
    }

    act_as_entity

    ARCHIVED_FLAGS = ["Archive"]
    RELEASE_MATCHER = /^(\w+)-r-(\d+)$/i

    def is_root?
      root.empty?
    end

    def is_branch?
      !is_root?
    end

    def is_release?
      !(name =~ RELEASE_MATCHER).nil?
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
    def self.repath_archive(path)
      return path unless ARCHIVED_FLAGS.any? {|flag| path.include? flag }

      #update the archived field
      archived = true
      save

      ARCHIVED_FLAGS.each {|flag| path.gsub!(/#{flag}>?(?:.*)>/, "") }
      path
    end
  end
end