require 'tfs_graph/tree_creator'

module TFSGraph
	class BranchTreeCreator
		extend TreeCreator

		ROOT_GROUP = ""

		class << self
			def to_tree(branches)
				grouped = branches.group_by &:absolute_root

				roots = grouped.map {|k,x| x.detect {|b| b.path == "$>RJR>#{k}"}}.flatten.compact
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