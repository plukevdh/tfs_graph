require 'spec_helper'
require 'tfs_graph/server_registry'

describe TFSGraph::ServerRegistry do
  before :all do
    TFSGraph::ServerRegistry.instance.reset!
  end

  context "should have reasonable defaults" do
    When(:redis) { TFSGraph::ServerRegistry.instance.redis }
    Then { redis.should be_a Redis::Namespace }
    And { redis.namespace.should == "tfs_graph" }
  end

  context "with a valid config" do
    Given!(:register) { TFSGraph::ServerRegistry.register {|r| r.server(url: "redis://localhost:6379", namespace: "test") }}

    context "can call redis on self" do
      When(:redis) { TFSGraph::ServerRegistry.redis }
      Then { redis.should be_a(Redis::Namespace) }
    end

    context "can get an instance of redis" do
      When(:redis) { register.redis }
      Then { redis.should be_a(Redis::Namespace) }
      And { redis.namespace.should == "test" }
      And { redis.should == Related.redis }
    end
  end

end