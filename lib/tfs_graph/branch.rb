require 'tfs_graph/entity'
require 'tfs_graph/helpers'

module TFSGraph
  class Branch < Entity
    extend Helpers
    extend Comparable

    SCHEMA = {
      path: {key: "Path", type: String},
      project: {converter: -> (path) { branch_project(path) }, key: "Path", type: String},
      name: {converter: -> (path) { branch_path_to_name(path) }, key: "Path", type: String},
      absolute_root: {converter: -> (path) { branch_base(path) if path }, key: "Path", type: String},
      root: {converter: -> (path) { server_path_to_name(path) if path }, key: "ParentBranch", type: String},
      created: {key: "DateCreated", type: DateTime}
    }

    act_as_entity

    ARCHIVED_FLAGS = ["Archive"]
    RELEASE_MATCHER = /^(\w+)-r-(\d+)$/i

    def archived?
      ARCHIVED_FLAGS.any? {|flag| path.include? flag }
    end

    def is_root?
      !root
    end

    def is_branch?
      !is_root?
    end

    def is_release?
      !(name =~ RELEASE_MATCHER).nil?
    end

    def changesets
      @changesets ||= ChangesetRepository.by_branch self
    end

    def cache_merges
      return if ChangesetMergeCache.cached? self
      ChangesetMergeCache.cache self
    end

    def <=>(other)
      path <=> other.path
    end
  end
end