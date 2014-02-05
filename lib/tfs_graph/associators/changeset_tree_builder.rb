module TFSGraph
  class ChangesetTreeBuilder
    class << self
      def to_tree(branch)
        changesets = branch.changesets
        changesets.each.with_index do |changeset, i|
          parent = (i == 0) ? branch : changesets[i-1]

          changeset.parent = parent.internal_id
          changeset.save!

          parent.add_child changeset
        end
      end
    end
  end
end