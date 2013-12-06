module TFSGraph
  module Populators
    class Everything
      include Utilities

      def populate
        clean

        collect_projects.map do |project|
          branches = collect_branches(project)
          branches.map {|branch| collect_changesets(branch) }

          branches.each {|branch| collect_merges(branch) }
        end

        finalize
      end
    end
  end
end