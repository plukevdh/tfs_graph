module TFSGraph
  module Populators
    class Everything
      include Utilities

      def populate
        clean

        collect_projects.map do |project|
          branches = collect_branches(project)
          changesets = branches.map {|branch| collect_changesets(branch) }

          branches.each {|branch| collect_merges(branch) }
          ChangesetTreeBuilder.set_branch_merges(changesets)

          project.updated!
        end

        finalize
      end
    end
  end
end