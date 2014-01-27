require 'spec_helper'

require 'tfs_graph/entity'

require 'tfs_graph/branch'
require 'tfs_graph/project'
require 'tfs_graph/changeset'

describe TFSGraph::Entity do
  Given(:repo) { flexmock("FakeRepository") }

  shared_examples "an entity" do
    context "knows when it is not persisted" do
      Then { entity.should_not be_persisted }
      And { repo.should_not have_received(:save) }
    end

    context "can be persisted" do
      Given { repo.should_receive(:save).with(entity).and_return(1) }
      When { entity.save! }
      Then { entity.should be_persisted }
      And { entity.internal_id.should == 1 }
    end

    context "can convert to a hash" do
      When(:result) { entity.to_hash }
      Then { result.keys.should == entity.send(:schema).keys }
    end
  end

  context "branch" do
    it_should_behave_like "an entity" do
      Given(:entity) { TFSGraph::Branch.new(repo, name: "Demo") }

      context "has properties" do
        Then { entity.name.should == "Demo" }
        And { entity.archived.should == false }
      end
    end
  end

  context "changeset" do
    it_should_behave_like "an entity" do
      Given(:entity) { TFSGraph::Changeset.new(repo, committer: "James") }

      context "has properties" do
        Then { entity.committer.should == "James" }
        And { entity.branch_path.should be_nil }
        And { entity.comment.should be_nil }
      end
    end
  end

  context "project" do
    it_should_behave_like "an entity" do
      Given(:entity) { TFSGraph::Project.new(repo, name: "FooBarge") }

      context "has properties" do
        Then { entity.name.should == "FooBarge" }
        And { entity.last_updated.should be_nil }
      end
    end
  end

end