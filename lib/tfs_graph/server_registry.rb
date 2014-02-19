require 'redis-namespace'

module TFSGraph
  class ServerRegistry
    include Singleton

    DEFAULT_REDIS = {url: "redis://localhost:6379", namespace: "tfs_graph" }

    def reset!
      @redis = nil
    end

    def self.register
      instance.reset!

      yield instance if block_given?
      instance
    end

    def initialize
      reset!
    end

    def server(server_obj=nil)
      return @server if @server && server_obj.nil?
      raise ArgumentError, "Need to register a server first" unless server_obj

      @server = server_obj
    end

    def redis(url: DEFAULT_REDIS[:url], namespace: DEFAULT_REDIS[:namespace])
      return @redis unless @redis.nil?

      @redis = Redis::Namespace.new(namespace, redis: Redis.connect(url: url))
    end

    define_singleton_method :redis do |url: DEFAULT_REDIS[:url], namespace: DEFAULT_REDIS[:namespace]|
      instance.redis url: url, namespace: namespace
    end

    define_singleton_method :server do |server_obj=nil|
      instance.server server_obj
    end
  end
end
