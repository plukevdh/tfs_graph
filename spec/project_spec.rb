require 'spec_helper'

require 'tfs_graph/project'

describe TFSGraph::Project do
  Given(:repo) { flexmock("FakeRepository") }
  Given(:project) { TFSGraph::Project.new(repo, {name: "Fake Project"}) }

  context "last updated is not available if never updated" do
    Then { project.last_updated.should == nil }
  end

  context "last updated is a date if set" do
    Given(:time) { Time.now }
    Given(:project) { TFSGraph::Project.new(repo, {name: "Fake Project", last_updated: time }) }
    Then { project.last_updated.should == time }
  end

  context "can set last updated" do
    before { Timecop.freeze }
    after { Timecop.return }

    Given(:project) { TFSGraph::Project.new(repo, {name: "Fake Project"}) }
    Given { repo.should_receive(:save).with(project).and_return { project.persist flexmock(id: 1) }}
    When { project.updated! }
    Then { project.last_updated.should eq(Time.now.utc) }
    And { project.should be_persisted }
  end
end