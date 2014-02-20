require 'spec_helper'

require "tfs_graph/branch"
require "tfs_graph/changeset"
require "tfs_graph/project"

require 'tfs_graph/repository'
require 'tfs_graph/repository_registry'

describe TFSGraph::RepositoryRegistry do
  Given(:repo) { flexmock(TFSGraph::Repository) }
  Given(:register) { TFSGraph::RepositoryRegistry.register {|r|
    r.type repo
  }}

  def constantize(string)
    Object.const_get(string)
  end

  class TFSGraph::Behaviors::Repository
    module Branch; end
    module Project; end
    module Changeset; end
  end

  shared_examples "a repository builder" do |type|
    Given {
      repo.should_receive(:new).
        with(constantize("TFSGraph::#{type.capitalize}")).pass_thru
    }
    When(:entity_repo) { register.send "#{type}_repository" }
    Then { entity_repo.should be_a(TFSGraph::Repository) }
    And { register.instance_variable_get("@#{type}_repo").should_not be_nil }
    And { register.send("#{type}_repository").should == entity_repo }
  end

  context "Branch" do
    it_should_behave_like "a repository builder", "branch"
  end

  context "Changeset" do
    it_should_behave_like "a repository builder", "changeset"
  end

  context "Project" do
    it_should_behave_like "a repository builder", "project"
  end
end