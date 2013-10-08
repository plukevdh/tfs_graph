module TFSGraph
	class ChangesetTreeCreator
		class << self
			def to_tree(changesets, branch)
				changesets.each.with_index do |changeset, i|
					# relate a changeset to a branch
					Related::Relationship.create :changesets, branch, changeset

					# get the current changeset's parent (the branch if first)
					parent = (i == 0) ? branch : changesets[i-1]

					if Changeset.find parent.id
						changeset.parent = parent.id
						changeset.save
					end

					Related::Relationship.create :child, parent, changeset
				end
			end
		end
	end
end