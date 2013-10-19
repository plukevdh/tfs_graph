require 'tfs_graph/entity'
require 'tfs_graph/helpers'

# FIXME: DRY along side the Branch class
module TFSGraph
  class Changeset < Entity
    extend Helpers
    extend Comparable

    SCHEMA = {
      comment: {key: "Comment", type: String},
      committer: {key: "Committer", converter: -> (name) { base_username(name) }, type: String},
      created: {key: "CreationDate", type: DateTime},
      id: {key: "Id", type: Integer},
      branch_path: {type: String, default: nil},
      tags: {type: Array, default: []},
      parent: {type: Integer, default: nil},
      merge_parent: {type: Integer, default: nil}
    }

    act_as_entity

    def <=>(other)
      id <=> other.id
    end

    def next
      child = outgoing(:child).options(model: self.class).nodes.to_a.first
      raise StopIteration unless child
      child
    end

    def branch
      incoming(:changesets).options(model: Branch).nodes.to_a.first
    end

    def merges
      get_merges_for outgoing(:merges)
    end

    def merged
      get_merges_for incoming(:merges)
    end

    def set_merging_to
      into = merged.max
      self.merge_parent = into.id if into
    end

    def set_merging_from
      from = merges.max
      self.merge_parent = from.id if from
    end

    private
    def get_merges_for(merge)
      merge.options(model: self.class).nodes.to_a
    end
  end
end