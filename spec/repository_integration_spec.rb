require 'spec_helper'
require 'tfs_graph/repository/related_repository'

# Integration testing between:
# - different repos
# - the registry
# - objects the repo returns

describe "Related repo integration" do
  Given(:register) { TFSGraph::RepositoryRegistry.new(TFSGraph::Repository::RelatedRepository) }
  Given(:project_repo) { register.project_repository }
  Given { 3.times {|i| project_repo.create(name: "TestProject_#{i}") }}
  Given(:foo) { project_repo.create(name: "TestProject_Foo") }

  context "project lookups" do
    context "can lookup all projects" do
      When(:all) { project_repo.all }
      Then { all.count.should == 3 }
      And { all.all? {|p| p.is_a? TFSGraph::Project }.should be_true }
    end

    context "can lookup by id" do
      When(:project) { project_repo.find foo.id }
      Then { project.should == foo }
    end

    context "can lookup project by name" do
      When(:project) { project_repo.find_by_name foo.name }
      Then { project.name.should == foo.name }
    end

    context "throws not found error if id not found" do
      When(:result) { project_repo.find 123 }
      Then { result.should have_failed(TFSGraph::Repository::NotFound)}
    end

    context "throws not found error if name found" do
      When(:result) { project_repo.find "FakeProject" }
      Then { result.should have_failed(TFSGraph::Repository::NotFound)}
    end
  end

  context "branches" do
    Given(:project_repo) { TFSGraph::RepositoryRegistry.branch_repository }
  end
end