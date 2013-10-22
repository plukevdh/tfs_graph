require 'spec_helper'
require 'branch/branch_cache'

# FIXME: integration spec. actually hits Redis
describe BranchCache do
  Given(:data) { %w(data fake some) }
  Given(:cache) { described_class }

  context "cached" do
    context "can store and retreive changeset data by branch as a set" do
      When { cache.store("Big Branch", data) }
      Then { cache.fetch("Big Branch").sort.should eq(data) }
    end
  end

  context "not cached" do
    context "cache miss should lookup and cache value, returning the data" do
      Given { flexmock(BranchStore).should_receive(:fetch).and_return(data) }
      When(:result) { cache.fetch("Fake Branch") }
      Then { result.should eq(data) }
    end

    context "returns NoBranch if lookup returns no data" do
      Given { flexmock(BranchStore).should_receive(:fetch).and_return(nil) }
      When(:result) { cache.fetch("No Branch") }
      Then { result.should eq BranchCache::NoBranch }
    end
  end
end
