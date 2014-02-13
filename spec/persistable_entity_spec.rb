require 'spec_helper'

require 'tfs_graph/repository'
require 'tfs_graph/repository_registry'
require 'tfs_graph/persistable_entity'

require 'tfs_graph/branch'
require 'tfs_graph/project'
require 'tfs_graph/changeset'

describe TFSGraph::PersistableEntity do
  Given(:repo_class) { flexmock("FakeRepository") }
  Given(:repo) { flexmock("fake repository instance") }
  Given { TFSGraph::RepositoryRegistry.register {|r| r.type repo_class } }

  Given { repo_class.should_receive(:new).and_return(repo) }

  shared_examples "an entity" do
    context "knows when it is not persisted" do
      Then { entity.should_not be_persisted }
      And { repo.should_not have_received(:save) }
    end

    context "can be persisted" do
      Given { repo.should_receive(:save).with(entity).and_return { entity.persist flexmock(id: 1) } }
      When { entity.save! }
      Then { entity.should be_persisted }
      And { entity.id.should == 1 }
    end

    context "can convert to a hash" do
      When(:result) { entity.to_hash }
      Then { result.keys.should == (entity.send(:schema).keys << :id).uniq }
    end

    context "can get repo for self" do
      When(:me) { entity.class.repository }
      Then { me.should eq repo }
    end
  end

  context "branch" do
    it_should_behave_like "an entity" do
      Given(:entity) { TFSGraph::Branch.new(repo, name: "Demo", created: Time.now) }

      context "has properties" do
        Then { entity.name.should == "Demo" }
        And { entity.archived.should == "false" }
        And { entity.created.should be_a Time }
      end
    end

    context "time converter" do
      Given(:time) { Time.now }

      context "can rebuild time from unixtime" do
        When(:entity) { TFSGraph::Branch.new(repo, name: "Demo", created: time.to_i) }
        Then { entity.created.to_i.should eq(time.to_i) }
      end

      context "can rebuild time from Time" do
        When(:entity) { TFSGraph::Branch.new(repo, name: "Demo", created: time) }
        Then { entity.created.to_i.should eq(time.to_i) }
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