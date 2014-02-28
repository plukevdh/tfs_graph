module TFSGraph
  module Populators
    class SinceLast
      include Utilities

      def populate
        projects = ProjectStore.new.fetch_all
        existing_projects = RepositoryRegistry.project_repository.all

        names = existing_projects.map(&:name)
        new_project_data = projects.reject {|project| names.include? project[:name]  }
        new_projects = ProjectStore.cache_all(new_project_data)

        existing_projects.concat(new_projects).each do |project|
          ForProject.new(project).populate
          branches = BranchStore.new(project).fetch_and_cache

          changesets = branches.select(&:active?).map do |branch|
            changesets = ChangesetStore.new(branch).fetch_since_date @since
            ChangesetTreeBuilder.to_tree(branch, changesets)

            branch.updated!
            changesets
          end

          # setup merges
          branches.each {|branch| ChangesetMergeStore.new(branch).fetch_and_cache }
          ChangesetTreeBuilder.set_branch_merges(changesets)

          BranchArchiveHandler.hide_moved_archives_for_project(@project)
          project.updated!
        end

        finalize
      end

    end
  end
end
