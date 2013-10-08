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
      branch: {type: String, default: nil},
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

    def merges
      outgoing(:merges).options(model: self.class).nodes.to_a
    end
  end
end