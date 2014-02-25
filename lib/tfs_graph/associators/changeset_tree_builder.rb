module TFSGraph
  class ChangesetTreeBuilder
    class << self
      def to_tree(branch, changesets)
        changesets.map.with_index do |changeset, i|
          parent = (i == 0) ? branch : changesets[i-1]

          if parent.is_a? TFSGraph::Changeset
            changeset.parent = parent.id
            changeset.save!
          end

          parent.add_child changeset
          changeset
        end
      end

      def set_branch_merges(changesets)
        changesets.each do |cs|
          from = cs.merges.max
          next unless from

          cs.merge_parent = from.id
          cs.save!
        end
      end
    end
  end
end