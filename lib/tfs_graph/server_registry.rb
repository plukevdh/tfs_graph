require 'related'

module TFSGraph
  class ServerRegistry
    include Singleton

    DEFAULT_SERVER = {url: "redis://localhost:6379", namespace: "tfs_graph" }

    def reset!
      @server = DEFAULT_SERVER
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

    def server(server)
      @server = server
    end

    def redis
      return @redis unless @redis.nil?

      @redis = Redis::Namespace.new(@server[:namespace], redis: Redis.connect(url: @server[:url]))
      Related.redis = @redis
    end

    define_singleton_method :redis do
      instance.redis
    end
  end
end
