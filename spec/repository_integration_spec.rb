require 'spec_helper'
require 'active_support/core_ext/numeric/time'

require 'tfs_graph/repository/related_repository'
require 'tfs_graph/repository_registry'

require 'tfs_graph/associators/changeset_tree_builder'

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

    context "project's branches" do
      Given(:archived_branch) {
        branch_repo.create(
          path: "$/Root/Branch-Base",
          original_path: "$/Root/Archived/Branch-Base",
          project: "TestProject_Foo",
        )
      }
      Given(:hidden_branch) {
        branch_repo.create(
          path: "$/Root/Branch-Base",
          original_path: "$/Root/Branch-Boot",
          project: "TestProject_Foo",
          hidden: true
        )
      }
      Given { foo.add_branch(archived_branch) }
      Given { foo.add_branch(hidden_branch) }

      context "active branches for a project" do
        When(:active) { foo.active_branches }
        Then { active.size.should eq(3) }
      end

      context "all non-hidden branches for a project" do
        When(:visible) { foo.branches }
        Then { visible.size.should eq(4) }
      end

      context "all with hidden" do
        When(:all) { foo.branches_with_hidden }
        Then { all.size.should eq(5) }
      end
    end

    shared_examples "branch type" do |type, name, root|
      Given { Related.redis.flushall }
      Given(:normal) {
        branch_repo.create(
          path: "$/Root/#{name}",
          original_path: "$/Root/#{name}",
          root: root,
          name: name
        )
      }
      Given(:archived) {
        branch_repo.create(
          path: "$/Root/#{name}",
          original_path: "$/Root/Archived/#{name}",
          root: root,
          name: name
        )
      }
      Given(:hidden) {
        branch_repo.create(
          path: "$/Root/#{name}",
          original_path: "$/Root/#{name}",
          root: root,
          name: name,
          hidden: true
        )
      }
      Given { foo.add_branch(normal) }
      Given { foo.add_branch(archived) }
      Given { foo.add_branch(hidden) }

      context "can find the #{type}s" do
        When(:results) { foo.send "#{type}s" }
        Then { results.size.should eq(2) }
      end

      context "can find the hidden #{type}s" do
        When(:results) { foo.send "#{type}s_with_hidden" }
        Then { results.size.should eq(3) }
      end

      context "can find the archived #{type}s" do
        When(:results) { foo.send "archived_#{type}s" }
        Then { results.size.should eq(1) }
      end
    end

    context "can get the master branches" do
      it_should_behave_like "branch type", "master", "Branch-Cool", ""
    end

    context "can get the release branches" do
      it_should_behave_like "branch type", "release", "Branch-R22-1234", "Branch-Cool"
    end

    context "can get the feature" do
      it_should_behave_like "branch type", "feature", "Branch-Base-Boot", "Branch-Cool"
    end

    context "changeset lookups" do
      Given(:cs_repo) { register.changeset_repository }
      Given(:branch) { foo.branches.first }
      Given!(:changesets) {
        3.times.map do |i|
          cs = cs_repo.create(comment: "Never gonna let you down.", id: "123#{i}".to_i, committer: "John Gray the #{i}th", created: "#{i.days.ago}")
          branch.add_changeset(cs)
          cs
        end
      }
      Given!(:noise) {
        # some extra noise
        3.times.map do |i|
          cs = cs_repo.create(comment: "Never gonna give you up.", id: "323#{i}".to_i, commiter: "Jim Beam", created: "#{i.days.ago}")
          foo.branches[1].add_changeset(cs)
          cs
        end
      }

      context "paths are set" do
        When(:cs) { branch.changesets }
        Then { cs.map(&:branch_path).all? {|path| path == branch.path }.should be_true }
      end

      context "from a project" do
        context "all" do
          When(:activity) { foo.all_activity }
          Then { activity.size.should == 6 }
          And { expect(activity).to match_array(noise.concat(changesets)) }
        end

        context "all_activity_by_date" do
          When(:activity) { foo.all_activity_by_date(0.5.days.ago) }
          Then { activity.values.flatten.size.should == 2 }
          And { expect(activity.values.flatten.map(&:id)).to match_array([3230, 1230]) }
        end
      end

      context "from a branch" do
        context "branch accessors" do
          When(:authors) { branch.contributors }
          Then { expect(authors.keys).to match_array(["John Gray the 0th", "John Gray the 1th", "John Gray the 2th"]) }
        end

        context "as a tree" do
          Given { TFSGraph::ChangesetTreeBuilder.to_tree branch }

          context "branch can get it's root node" do
            When(:root) { branch.root_changeset }
            Then { root.id.should eq(1230) }
          end

          context "can get it's last node" do
            When(:last) { branch.last_changeset }
            Then { last.id.should eq(1232) }
          end
        end
      end

      context "within changesets" do
        Given { TFSGraph::ChangesetTreeBuilder.to_tree branch }
        Given(:changeset) { changesets.first }

        context "can walk the chain" do
          Given(:results) { [] }
          When {
            child = changeset.next
            loop do
              results << child.id
              child = child.next
            end
          }
          Then { results.should match_array([1231, 1232])}
        end

        context "can get branch" do
          When(:cs_branch) { changeset.branch }
          Then { cs_branch.should eq(branch) }
        end
      end
    end
  end
end