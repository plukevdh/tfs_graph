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

        # this will throw an error if one of the relations is not found
        # this is the desired condition as it will throw out the merge if there aren't two endpoints found
        target, source = merge.get_relations

        create_relationship :merges, target, source

        # relate the branches as well
        create_relationship :related, source.branch, target.branch

        create_relationship :included, source.branch, target
        create_relationship :included, target.branch, source

        merge
      rescue TFSGraph::Entity::NotFound => ex
        # puts "Could not find a changeset to merge with: #{ex.message}"
      rescue Related::ValidationsFailed => ex
        # puts "Couldn't create relationship for #{merge.source_version} to #{merge.target_version}"
      end
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