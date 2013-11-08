require 'tfs_graph/entity'
require 'tfs_graph/changeset'

module TFSGraph
  class ChangesetMerge < Entity

    SCHEMA = {
      target_version: {key: "TargetVersion", type: Integer},
      source_version: {key: "SourceVersion", type: Integer},
      branch: {default: nil, type: String}
    }

    act_as_entity

    # overwrite the creator, and create a relationship between the
    # two changesets requested instead of a distinct object
    def self.create(attrs)
      begin
        merge = new(attrs)

        target, source = merge.get_relations
        Related::Relationship.create :merges, target, source

        # relate the branches as well
        Related::Relationship.create :related, source.branch, target.branch

        Related::Relationship.create :included, source.branch, target
        Related::Relationship.create :included, target.branch, source
      rescue Related::NotFound => ex
        # puts "Could not find a changeset to merge with: #{ex.message}"
      rescue Related::ValidationsFailed => ex
        # puts "Couldn't create relationship for #{merge.source_version} to #{merge.target_version}"
      end
    end

    def save
      # nothing, no need to save
    end

    def get_relations
      return get_target, get_source
    end

    def get_source
      Changeset.find(source_version)
    end

    def get_target
      Changeset.find(target_version)
    end
  end
end