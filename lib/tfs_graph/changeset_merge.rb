require 'tfs_graph/changeset'

module TFSGraph
  class ChangesetMerge < Entity

    SCHEMA = {
      target_version: {key: "TargetVersion", type: Integer},
      source_version: {key: "SourceVersion", type: Integer}
    }

    act_as_entity

    # overwrite the creator, and create a relationship between the
    # two changesets requested instead of a distinct object
    def self.create(attrs)
      begin
        merge = new(attrs)

        target, source = merge.get_relations
        return nil unless target.persisted? and source.persisted?

        merge.join :merges, target, source

        # relate the branches as well
        merge.join :related, source.branch, target.branch

        merge.join :included, source.branch, target if source.branch
        merge.join :included, target.branch, source if target.branch

        merge
      rescue TFSGraph::Repository::NotFound => ex
        # puts "Could not find a changeset to merge with: #{ex.message}"
      end
    end

    def get_relations
      return get_target, get_source
    end

    def get_source
      repo.find(source_version)
    end

    def get_target
      repo.find(target_version)
    end

    def join(relation, target, source)
      repo.relate(relation, target.db_object, source.db_object)
    end

    private
    def repo
      @repo ||= RepositoryRegistry.changeset_repository
    end
  end
end