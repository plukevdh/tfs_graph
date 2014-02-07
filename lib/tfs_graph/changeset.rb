require 'tfs_graph/persistable_entity'
require 'tfs_graph/tfs_helpers'

# FIXME: DRY along side the Branch class
module TFSGraph
  class Changeset < PersistableEntity
    extend TFSHelpers

    SCHEMA = {
      comment: {key: "Comment", type: String},
      committer: {key: "Committer", converter: ->(name) { base_username(name) }, type: String},
      created: {key: "CreationDate", type: DateTime},
      id: {key: "Id", type: Integer},
      branch_path: {type: String, default: nil},
      # tags: {type: Array, default: []},
      parent: {type: Integer, default: nil},
      merge_parent: {type: Integer, default: nil}
    }

    act_as_entity

    def <=>(other)
      id <=> other.id
    end

    def id
      @id.to_i
    end

    def created
      return nil unless @created
      return @created unless @created.is_a? String
      @created = DateTime.parse @created
    end

    def add_child(changeset)
      @repo.relate(:child, self, changeset)
    end

    def next
      child = @repo.get_nodes(db_object, :outgoing, :child, self.class).first
      raise StopIteration unless child
      child
    end

    def branch
      @repo.get_nodes(db_object, :incoming, :changesets, Branch).first
    end

    def formatted_created
      created.strftime("%m/%d/%Y")
    end

    %w(merges merged).each do |type|
      directon = (type == "merges") ? :outgoing : :incoming
      define_method type do
        get_merges_for @repo.get_relation(db_object, directon, :merges)
      end

      define_method "#{type}_ids" do
        send(type).map &:id
      end
    end

    def as_json(options={})
      options.merge! methods: [:merges_ids, :merged_ids]
      super
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
      @repo.get_nodes_for(merge, self.class)
    end
  end
end