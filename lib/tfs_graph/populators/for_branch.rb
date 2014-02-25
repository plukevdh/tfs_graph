module TFSGraph
  module Populators
    class ForBranch
      include Utilities

      def initialize(project, branch)
        @project = project
        @branch = branch
      end

      def populate
        new_changesets = collect_changesets @branch, :cache_since_last_update

        collect_merges(@branch)
        BranchAssociator.associate(new_changesets.flatten)
      end
    end
  end
end