# Domain knowledge of where to get branch data from and how to instantiate a Branch object
require 'tfs_graph/branch_store'
require 'tfs_graph/branch'

BranchNotFound = Class.new(Exception)

module TFSGraph
  class GraphPopulator
    class << self
      def populate_for_project(root_name)
        raw_branches = BranchStore.fetch(root_name)

        branches = raw_branches.map {|branch_attrs| Branch.create branch_attrs }.group_by &:root

        roots = branches[""]
        roots.each do |branch|
          Related::Relationship.create(format_key(branch.name), Related.root, branch)
          children = branches[branch.name]
          next unless children

          children.each do |child|
            Related::Relationship.create(format_key(child.name), branch, child)
          end
        end
      end

      private

      def format_key(key)
        key.downcase.to_sym
      end
    end
  end
end