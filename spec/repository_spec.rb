require 'spec_helper'

require 'tfs_graph/repository'
require 'tfs_graph/repository/related_repository'
require 'tfs_graph/server_registry'

require 'tfs_graph/branch'
require 'tfs_graph/project'
require 'tfs_graph/changeset'

describe TFSGraph::Repository do
  context "Related" do
    before :all do
      TFSGraph::ServerRegistry.register {|r|
        r.redis url: "redis://localhost:6379", namespace: "test"
      }
    end

    before(:each) do
      TFSGraph::ServerRegistry.redis.flushall
    end

    shared_examples "a repo" do
      context "with related" do
        Given(:repo) { TFSGraph::Repository::RelatedRepository.new type }

        context "can build an entity (no persist)" do
          When(:object) { repo.build(data) }
          Then { object.should be_a type }
          And { object.should_not be_persisted }
        end

        context "can create an entity (persist)" do
          When(:object) { repo.create(data) }
          Then { object.should be_a type }
          And { object.should be_persisted }
        end
      end
    end

    context "Branch" do
      it_should_behave_like "a repo" do
        Given(:type) { TFSGraph::Branch }
        Given(:data) { {} }
      end
    end

    context "Changeset" do
      Given(:type) { TFSGraph::Changeset }

      it_should_behave_like "a repo" do
        Given(:data) { {} }
      end

      context "with changesets" do
        Given(:repo) { TFSGraph::Repository::RelatedRepository.new type }
        Given { 3.times {|i| repo.create({id: i+1, comment: "Commit #{i+1}, Because Tests"}) }}

        context "can find changesets by id" do
          When(:result) { repo.find 2 }
          Then { result.should_not be_nil }
          And { result.should be_a TFSGraph::Changeset }
          And { result.id.should == 2 }
        end

        context "should raise an error if not found" do
          When(:result) { repo.find 7 }
          Then { result.should have_failed(TFSGraph::Repository::NotFound) }
        end
      end
    end
  end
end