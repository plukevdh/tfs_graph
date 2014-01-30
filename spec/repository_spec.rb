require 'spec_helper'

require 'tfs_graph/repository'
require 'tfs_graph/repository/related_repository'

require 'tfs_graph/branch'
require 'tfs_graph/project'
require 'tfs_graph/changeset'

require "tfs_graph/branch/behaviors"
require "tfs_graph/changeset/behaviors"
require "tfs_graph/project/behaviors"

describe TFSGraph::Repository do
  before(:each) do
    Related.redis.flushall
  end

  context "Related" do

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
      it_should_behave_like "a repo" do
        Given(:type) { TFSGraph::Changeset }
        Given(:data) { {} }
      end
    end
  end
end