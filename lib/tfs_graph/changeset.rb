require 'tfs_graph/persistable_entity'
require 'tfs_graph/tfs_helpers'

# FIXME: DRY along side the Branch class
module TFSGraph
  class Changeset < PersistableEntity
    extend TFSHelpers

    SCHEMA = {
      comment: {key: "Comment", type: String},
      committer: {key: "Committer", converter: ->(name) { base_username(name) }, type: String},
      created: {key: "CreationDate", type: Time},
      id: {key: "Id", type: Integer},
      branch_path: {type: String, default: nil},
      # tags: {type: Array, default: []},
      parent: {type: Integer, default: 0},
      merge_parent: {type: Integer, default: 0}
    }

    act_as_entity

    def <=>(other)
      id <=> other.id
    end

    # override for the & (intersect) operator
    def eql?(other)
      other.is_a?(self.class) && other == self
    end

    def hash
      @internal_id.hash
    end

    def id
      @id.to_i unless @id.nil?
    end

    def merge?
      !base? && @merge_parent != 0
    end

    def base?
      @parent == 0 || @parent == @merge_parent
    end

    def created
      return nil unless @created
      return @created unless @created.is_a? String
      @created = Time.parse @created
    end

    def add_child(changeset)
      @repo.relate(:child, self.db_object, changeset.db_object)
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
        @repo.get_nodes(db_object, directon, :merges, self.class)
      end

      define_method "#{type}_ids" do
        send(type).map &:id
      end
    end

    def as_json(options={})
      results = super

      [:merges_ids, :merged_ids].each do |key|
        results[key] = self.send key
      end

      results
    end
  end
end