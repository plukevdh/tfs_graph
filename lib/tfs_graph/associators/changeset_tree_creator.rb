module TFSGraph
	class ChangesetTreeCreator
		class << self
			def to_tree(branch)
				changesets = branch.changesets
				changesets.each.with_index do |changeset, i|
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