require 'tfs_graph/tree_creator'

module TFSGraph
	class BranchTreeCreator
		extend TreeCreator

		ROOT_GROUP = ""

		class << self
			def to_tree(branches)
				grouped = branches.group_by &:root

				roots = grouped[ROOT_GROUP]
				roots.each do |branch|
					Related::Relationship.create(:roots, Related.root, branch)
					children = grouped[branch.name]
					next unless children

					children.each do |child|
						Related::Relationship.create(:branches, branch, child)
					end
				end
			end
		end
	end
end