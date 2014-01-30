require 'spec_helper'

require 'tfs_graph/repository/related_repository'
require 'tfs_graph/repository_registry'

# Integration testing between:
# - different repos
# - the registry
# - objects the repo returns

describe "Related repo integration" do
  before(:each) do
    Related.redis.flushall
  end

  Given(:register) { TFSGraph::RepositoryRegistry.register {|r| r.type TFSGraph::Repository::RelatedRepository }}
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
    Given(:branch_repo) { register.branch_repository }
    Given { 3.times do |i|
        branch = branch_repo.create(path: "$/Root/Branch-#{i}", original_path: "$/Root/Branch-#{i}")
        foo.add_branch(branch)
      end
    }


    context "can find project for branch" do
      Given(:branch) {
        branch_repo.create(
          path: "$/Root/Branch-Base",
          original_path: "$/Root/Branch-Base",
          project: "TestProject_Foo"
        )
      }
      When(:project) { branch_repo.project_for_branch branch}
      Then { project.should eq(foo) }
    end

    context "branch lookups through a project" do
      When(:branches) { foo.branches }
      Then { branches.size.should eq(3) }
      And { branches.all? {|p| p.is_a? TFSGraph::Branch }.should be_true }
    end

    context "can get specific branch for a project by path" do
      When(:branch) { branch_repo.find_in_project(foo, "$/Root/Branch-1") }
      Then { branch.should_not be_nil }
      And { branch.path.should eq("$/Root/Branch-1") }
    end
  end
end