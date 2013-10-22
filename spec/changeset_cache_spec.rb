require 'spec_helper'
require 'branch'
require 'changeset/changeset_cache'

describe ChangesetCache do
  Given!(:data) { [{id: 12345, name: "hello world"}, {id: 5678, name: "goodbye"}] }
  Given(:branch) { flexmock(name: "BigBranch", path: "$>RJR>FakeBranch", on: Branch) }

  context "cached" do
    context "can store and retreive changeset data by branch as a set" do
      When { ChangesetCache.store(branch.name, data) }
      When(:results) { ChangesetCache.fetch(branch) }
      Then { results.should eq(data) }
      And { results.count.should eq(2) }
    end
  end
end