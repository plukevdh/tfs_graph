module TFSGraph
  class BranchAssociator
    class << self

      # sets up parent/child relationships
      def associate_groups(sets_by_branch)
        sets_by_branch.each do |group|
          associate(group)
        end
      end

      def associate(changesets)
        return if changesets.empty?

        change = changesets.first
        root = change.merges.max

        return if root.nil?

        change.parent = root.id
        change.save
      end
    end
  end
end