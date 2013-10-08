module TFSGraph
  class BranchAssociator
    class << self
      def associate(changesets)
        changesets.each do |group|
          change = group.first
          root = change.merges.min

          next if root.nil?

          change.parent = root.id
          change.save
        end
      end
    end
  end
end