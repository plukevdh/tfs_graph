module TFSGraph
  class BranchArchiveHandler
    # Archives == moving a branch from root to an archive folder
    # The actual history is attached to the old branch path in TFS,
    # but now we have a "ghost" branch (with the important history attached)
    # and an "archived" branch (by rename in TFS). Since the "archived" branch
    # is fairly useless, we'll hide it in favor of the "ghost" branch.
    class << self
      def hide_all_archives
        RepositoryRegistry.project_repository.all.map {|project| hide_moved_archives_for_project(project) }
      end

      def hide_moved_archives_for_project(project)
        project.branches.group_by(&:path).map do |path, group|
          next unless group.size > 1

          group.each do |branch|
            branch.hide! if branch.archived?
            branch.archive! unless branch.archived?
          end

          group
        end
      end
    end
  end
end