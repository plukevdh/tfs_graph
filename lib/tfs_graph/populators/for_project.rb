module TFSGraph
  module Populators
    class ForProject
      include Utilities

      def initialize(project)
        @project = project
      end

      def populate
        branches = collect_branches(@project)
        branches.map {|branch| collect_changesets(branch) }

        branches.each {|branch| collect_merges(branch) }
        @project.updated!
      end
    end
  end
end