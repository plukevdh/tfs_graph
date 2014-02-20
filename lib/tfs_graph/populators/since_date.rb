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
          branches.map do |branch|
            collect_changesets(branch, :cache_since_date, @since)
          end

          branches.each {|branch| collect_merges(branch) }
          project.updated!
        end

        finalize
      end
    end
  end
end