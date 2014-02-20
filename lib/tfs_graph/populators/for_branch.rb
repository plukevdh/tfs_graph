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

        collect_merges(new_changesets)
        BranchAssociator.associate(new_changesets)
      end
    end
  end
end