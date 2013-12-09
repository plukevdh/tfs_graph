require 'tfs_graph/changeset'

FactoryGirl.define do
  factory :changeset, class: TFSGraph::Changeset do
    comment "Doing fun things"
    committer "John Doe"
    created { Time.now }
    sequence :id
  end

  factory :branch do
    original_path "$>DefaultCollection>Project"
    path "$>DefaultCollection>Project"
    project "BFG"
    name "Project"
    root "$>DefaultCollection>Project"
    created { Time.now }
    type "master"
  end
end