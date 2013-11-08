module TFSGraph
  class Config
    attr_accessor :tfs
    attr_reader :redis

    def redis=(redis)
      @redis = Related.redis = redis
    end
  end
end