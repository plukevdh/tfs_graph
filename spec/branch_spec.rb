require 'spec_helper'

require 'tfs_graph/branch'

describe TFSGraph::Branch do
  Given(:repo) { flexmock("FakeRepository") }

  context "estimates master and archive from name" do
    When(:branch) { TFSGraph::Branch.new(repo, {
      original_path: "$/Archived/Branch-A",
      root: "",
      path: "$/Branch-A",
      name: "Branch-A"})
    }
    Then { branch.should be_archived }
    And { branch.should be_master }
    And { branch.named_type.should == :master }
    And { branch.should_not be_branch }
  end

  context "estimates release from name" do
    When(:branch) { TFSGraph::Branch.new(repo, {
      original_path: "$/Branch-R44-1234",
      root: "$/Branch",
      path: "$/Branch-R44-1234",
      name: "Branch-R44-1234"})
    }
    Then { branch.should_not be_archived }
    And { branch.should be_release }
    And { branch.should_not be_rootless }
    And { branch.named_type.should == :release }
    And { branch.should be_branch }
  end

  context "estimates feature from name" do
    When(:branch) { TFSGraph::Branch.new(repo, {
      original_path: "$/Branch-My-Cool-Feature",
      root: "$/Branch",
      path: "$/Branch-My-Cool-Feature"})
    }
    Then { branch.should_not be_archived }
    And { branch.should be_active }
    And { branch.should be_feature }
    And { branch.named_type.should == :feature }
  end

  context "hidden state" do
    Given(:branch) { TFSGraph::Branch.new(repo, {
      original_path: "$/Branch-My-Cool-Feature",
      root: "$/Branch",
      path: "$/Branch-My-Cool-Feature"})
    }

    context "is not initially set" do
      Then { branch.should_not be_hidden }
      And { branch.should be_active }
    end

    context "can be set" do
      When { repo.should_receive(:save).with(branch) }
      When { branch.hide! }
      Then { branch.should be_hidden }
      And { branch.should_not be_active }
    end
  end

  context "archived state" do
    Given(:branch) { TFSGraph::Branch.new(repo, {
      original_path: "$/Branch-My-Cool-Feature",
      root: "$/Branch",
      path: "$/Branch-My-Cool-Feature"})
    }

    context "is not initially set" do
      Then { branch.should_not be_archived }
      And { branch.should be_active }
    end

    context "can be set" do
      When { repo.should_receive(:save).with(branch) }
      When { branch.archive! }
      Then { branch.should be_archived }
      And { branch.should_not be_active }
    end
  end
end
