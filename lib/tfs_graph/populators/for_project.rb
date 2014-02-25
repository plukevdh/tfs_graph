module TFSGraph
  module Populators
    class ForProject
      include Utilities

      def initialize(project)
        @project = project
      end

      def populate
        # save all branches
        collect_branches(@project)
        branches = @project.active_branches
        changesets = branches.map {|branch| collect_changesets(branch) }

        branches.each {|branch| collect_merges(branch) }

        ChangesetTreeBuilder.set_branch_merges(changesets.flatten)

        @project.updated!
      end
    end
  end
end