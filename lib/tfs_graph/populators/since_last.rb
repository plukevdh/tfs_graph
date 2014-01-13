module TFSGraph
  module Populators
    class SinceLast
      include Utilities

      def populate
        ProjectStore.all_cached.map do |project|
          new_changesets = project.active_branches.map {|branch| collect_changesets branch, :cache_since_last_update}
          new_branches = BranchStore.new(project).cache_since_last_update

          new_changesets.concat new_branches.map {|branch| collect_changesets branch }

          # recache and reassociate all merges for all branches.
          # should not lead to dupes thanks to Related
          new_branches.concat(project.branches).each do |branch|
            collect_merges(branch)
            BranchAssociator.associate(branch.changesets)
          end
        end

        finalize
      end

    end
  end
end
