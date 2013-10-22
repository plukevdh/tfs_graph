module TFSGraph
  class BranchAssociator
    class << self
      def associate(changesets)
        changesets.each do |group|
          next if group.empty?

          change = group.first
          root = change.merges.max

          next if root.nil?

          change.parent = root.id
          change.save
        end
      end
    end
  end
end