require 'spec_helper'
require 'tfs_graph/server_registry'

describe TFSGraph::ServerRegistry do
  before :each do
    TFSGraph::ServerRegistry.instance.reset!
  end

  context "should have reasonable defaults" do
    When(:redis) { TFSGraph::ServerRegistry.instance.redis }
    Then { redis.should be_a Redis::Namespace }
    And { redis.namespace.should == "tfs_graph" }
  end

  context "should be able to register redis settings" do
    When(:redis) { TFSGraph::ServerRegistry.redis(url: "redis://127.0.0.1:6379", namespace: "foo") }
    Then { redis.namespace.should eq("foo") }
    And { redis.should be_a Redis::Namespace }
  end

  context "with a valid config" do
    Given!(:register) { TFSGraph::ServerRegistry.register {|r| r.redis(url: "redis://localhost:6379", namespace: "test") }}

    context "can call redis on self" do
      When(:redis) { TFSGraph::ServerRegistry.redis }
      Then { redis.should be_a(Redis::Namespace) }
    end

    context "can get an instance of redis" do
      When(:redis) { register.redis }
      Then { redis.should be_a(Redis::Namespace) }
      And { redis.namespace.should == "test" }
    end
  end

end