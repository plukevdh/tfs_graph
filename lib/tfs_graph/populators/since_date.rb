module TFSGraph
  module Populators
    class SinceDate
      include Utilities

      def initialize(since)
        @since = since
      end

      def populate
        clean

        collect_projects.map do |project|
          branches = collect_branches(project)
          new_changesets = branches.map do |branch|
            collect_changesets(branch, :cache_since_date, @since)
          end

          branches.each {|branch| collect_merges(branch) }

          ChangesetTreeBuilder.set_branch_merges(new_changesets)
          project.updated!
        end

        finalize
      end
    end
  end
end